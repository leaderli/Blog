---
title: spring静态资源加载源码浅析
date: 2019-08-04 01:28:59
categories: spring
tags:
  - springboot
  - springmvc
  - 源码
---

## 自定义资源处理器

`DispatcherServlet`会拦截所有请求，针对`js`,`css`等静态资源文件，我们不期望被`controller`拦截，通过重写`WebMvcConfigurationSupport`的`addResourceHandlers`方法，由拦截指定规则的请求 url。代码如下

```java
package com.li.springboot.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurationSupport;

@Configuration
@EnableWebMvc
public class WebMvc extends WebMvcConfigurationSupport {
    @Override
    protected void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/static").addResourceLocations("classpath:/static");
    }
}
```

## 源码分析

`SpringBoot`拦截 url，根据`HandlerMapping`找到对应的`Handler`去执行相关操作。

`DispatcherServlet`初始化时会调用初始化方法时会加载`HandlerMapping`

```java
private void initHandlerMappings(ApplicationContext context) {
    this.handlerMappings = null;

    if (this.detectAllHandlerMappings) {
        // 查找所有HandlerMapping实现类
        Map<String, HandlerMapping> matchingBeans =
                BeanFactoryUtils.beansOfTypeIncludingAncestors(context, HandlerMapping.class, true, false);
        if (!matchingBeans.isEmpty()) {
            this.handlerMappings = new ArrayList<>(matchingBeans.values());
            // We keep HandlerMappings in sorted order.
            AnnotationAwareOrderComparator.sort(this.handlerMappings);
        }
    }
...
```

`WebMvcConfigurationSupport`的方法`resourceHandlerMapping`中注解了`@Bean`，所以自定义的资源处理器类得以被加载

```java
@Bean
@Nullable
public HandlerMapping resourceHandlerMapping() {
    Assert.state(this.applicationContext != null, "No ApplicationContext set");
    Assert.state(this.servletContext != null, "No ServletContext set");

    ResourceHandlerRegistry registry = new ResourceHandlerRegistry(this.applicationContext,
            this.servletContext, mvcContentNegotiationManager(), mvcUrlPathHelper());
    // 我们重写的方法
    addResourceHandlers(registry);

    AbstractHandlerMapping handlerMapping = registry.getHandlerMapping();
    if (handlerMapping == null) {
        return null;
    }
    handlerMapping.setPathMatcher(mvcPathMatcher());
    handlerMapping.setUrlPathHelper(mvcUrlPathHelper());
    handlerMapping.setInterceptors(getInterceptors());
    handlerMapping.setCorsConfigurations(getCorsConfigurations());
    return handlerMapping;
}

```

重写的方法`new`了`ResourceHandlerRegistration`

```java
public ResourceHandlerRegistration addResourceHandler(String... pathPatterns) {
    ResourceHandlerRegistration registration = new ResourceHandlerRegistration(pathPatterns);
    this.registrations.add(registration);
    return registration;
}
```

返回到`WebMvcConfigurationSupport`方法`resourceHandlerMapping`的`registry.getHandlerMapping()`中，

```java
protected AbstractHandlerMapping getHandlerMapping() {
    if (this.registrations.isEmpty()) {
        return null;
    }

    Map<String, HttpRequestHandler> urlMap = new LinkedHashMap<>();
    for (ResourceHandlerRegistration registration : this.registrations) {
        for (String pathPattern : registration.getPathPatterns()) {
            //找到实际handler
            ResourceHttpRequestHandler handler = registration.getRequestHandler();
            if (this.pathHelper != null) {
                handler.setUrlPathHelper(this.pathHelper);
            }
            if (this.contentNegotiationManager != null) {
                handler.setContentNegotiationManager(this.contentNegotiationManager);
            }
            handler.setServletContext(this.servletContext);
            handler.setApplicationContext(this.applicationContext);
            try {
                handler.afterPropertiesSet();
            }
            catch (Throwable ex) {
                throw new BeanInitializationException("Failed to init ResourceHttpRequestHandler", ex);
            }
            urlMap.put(pathPattern, handler);
        }
    }

    SimpleUrlHandlerMapping handlerMapping = new SimpleUrlHandlerMapping();
    handlerMapping.setOrder(this.order);
    handlerMapping.setUrlMap(urlMap);
    return handlerMapping;
}
```

`ResourceHandlerRegistration`的`getRequestHandler`

```java
protected ResourceHttpRequestHandler getRequestHandler() {
    ResourceHttpRequestHandler handler = new ResourceHttpRequestHandler();
    if (this.resourceChainRegistration != null) {
        handler.setResourceResolvers(this.resourceChainRegistration.getResourceResolvers());
        handler.setResourceTransformers(this.resourceChainRegistration.getResourceTransformers());
    }
    handler.setLocationValues(this.locationValues);
    if (this.cacheControl != null) {
        handler.setCacheControl(this.cacheControl);
    }
    else if (this.cachePeriod != null) {
        handler.setCacheSeconds(this.cachePeriod);
    }
    return handler;
}
```

那么我们现在只需要搞清楚`ResourceHttpRequestHandler`中的方法是如何被调用即可。

`SpringBoot`或者`SpringMVC`的请求由`DispatcherServlet`拦截所有请求，实现了`Servlet`标准。那么我们从`service`方法入口即可

`DispatcherServlet`的父类`FrameworkServlet`重写了`service`方法

```java
protected void service(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    HttpMethod httpMethod = HttpMethod.resolve(request.getMethod());
    if (httpMethod == HttpMethod.PATCH || httpMethod == null) {
        //
        processRequest(request, response);
    }
    else {
        super.service(request, response);
    }
}
```

`processRequest`方法中，实际由`DispatcherServlet`实现的方法`doService`去处理。而`doService`最终调用`doDispatch`方法

```java
protected void doDispatch(HttpServletRequest request, HttpServletResponse response) throws Exception {
    HttpServletRequest processedRequest = request;
    HandlerExecutionChain mappedHandler = null;
    boolean multipartRequestParsed = false;

    WebAsyncManager asyncManager = WebAsyncUtils.getAsyncManager(request);

    try {
        ModelAndView mv = null;
        Exception dispatchException = null;

        try {
            processedRequest = checkMultipart(request);
            multipartRequestParsed = (processedRequest != request);

            //查找合适的handlerMapping
            mappedHandler = getHandler(processedRequest);
            if (mappedHandler == null) {
                noHandlerFound(processedRequest, response);
                return;
            }

            // Determine handler adapter for the current request.
            HandlerAdapter ha = getHandlerAdapter(mappedHandler.getHandler());

            // Process last-modified header, if supported by the handler.
            String method = request.getMethod();
            boolean isGet = "GET".equals(method);
            if (isGet || "HEAD".equals(method)) {
                long lastModified = ha.getLastModified(request, mappedHandler.getHandler());
                if (new ServletWebRequest(request, response).checkNotModified(lastModified) && isGet) {
                    return;
                }
            }

            if (!mappedHandler.applyPreHandle(processedRequest, response)) {
                return;
            }

            // ha实际使用HttpRequestHandlerAdapter，mappedHandler.getHandler()则为ResourceHttpRequestHandler
            mv = ha.handle(processedRequest, response, mappedHandler.getHandler());

            if (asyncManager.isConcurrentHandlingStarted()) {
                return;
            }

            applyDefaultViewName(processedRequest, mv);
            mappedHandler.applyPostHandle(processedRequest, response, mv);
        }
        catch (Exception ex) {
            dispatchException = ex;
        }
        catch (Throwable err) {
            // As of 4.3, we're processing Errors thrown from handler methods as well,
            // making them available for @ExceptionHandler methods and other scenarios.
            dispatchException = new NestedServletException("Handler dispatch failed", err);
        }
        processDispatchResult(processedRequest, response, mappedHandler, mv, dispatchException);
    }
    catch (Exception ex) {
        triggerAfterCompletion(processedRequest, response, mappedHandler, ex);
    }
    catch (Throwable err) {
        triggerAfterCompletion(processedRequest, response, mappedHandler,
                new NestedServletException("Handler processing failed", err));
    }
    finally {
        if (asyncManager.isConcurrentHandlingStarted()) {
            // Instead of postHandle and afterCompletion
            if (mappedHandler != null) {
                mappedHandler.applyAfterConcurrentHandlingStarted(processedRequest, response);
            }
        }
        else {
            // Clean up any resources used by a multipart request.
            if (multipartRequestParsed) {
                cleanupMultipart(processedRequest);
            }
        }
    }
}
```

我们查看具体查找`mappedHandler`的具体实现,

```java
protected HandlerExecutionChain getHandler(HttpServletRequest request) throws Exception {
    //handlerMappings的加载在上文中有详细解释，这里就加载了ResourceHttpRequestHandler
    if (this.handlerMappings != null) {
        for (HandlerMapping mapping : this.handlerMappings) {
            HandlerExecutionChain handler = mapping.getHandler(request);
            if (handler != null) {
                return handler;
            }
        }
    }
    return null;
}
```

接着我们查看查找具体`handlerAdapter`的具体实现

```java
protected HandlerAdapter getHandlerAdapter(Object handler) throws ServletException {
    //和handlerMappings的加载代码细节一样，这里加载了HttpRequestHandlerAdapter
    if (this.handlerAdapters != null) {
        for (HandlerAdapter adapter : this.handlerAdapters) {
            if (adapter.supports(handler)) {
                return adapter;
            }
        }
    }
    throw new ServletException("No adapter for handler [" + handler +
            "]: The DispatcherServlet configuration needs to include a HandlerAdapter that supports this handler");
}
```

`handlerAdapter`调用`handle`,对于`HttpRequestHandlerAdapter`来说，

```java
@Override
@Nullable
public ModelAndView handle(HttpServletRequest request, HttpServletResponse response, Object handler)
        throws Exception {

    ((HttpRequestHandler) handler).handleRequest(request, response);
    return null;
}
```

那么根据`doDispatch`中传入的`handler`即则为`ResourceHttpRequestHandler`,我们可以看到资源文件的具体加载过程。

```java
@Override
public void handleRequest(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    // For very general mappings (e.g. "/") we need to check 404 first
    Resource resource = getResource(request);
    if (resource == null) {
        logger.debug("Resource not found");
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
        return;
    }

    if (HttpMethod.OPTIONS.matches(request.getMethod())) {
        response.setHeader("Allow", getAllowHeader());
        return;
    }

    // Supported methods and required session
    checkRequest(request);

    // Header phase
    if (new ServletWebRequest(request, response).checkNotModified(resource.lastModified())) {
        logger.trace("Resource not modified");
        return;
    }

    // Apply cache settings, if any
    prepareResponse(response);

    // Check the media type for the resource
    MediaType mediaType = getMediaType(request, resource);

    // Content phase
    if (METHOD_HEAD.equals(request.getMethod())) {
        setHeaders(response, resource, mediaType);
        return;
    }

    ServletServerHttpResponse outputMessage = new ServletServerHttpResponse(response);
    if (request.getHeader(HttpHeaders.RANGE) == null) {
        Assert.state(this.resourceHttpMessageConverter != null, "Not initialized");
        setHeaders(response, resource, mediaType);
        this.resourceHttpMessageConverter.write(resource, mediaType, outputMessage);
    }
    else {
        Assert.state(this.resourceRegionHttpMessageConverter != null, "Not initialized");
        response.setHeader(HttpHeaders.ACCEPT_RANGES, "bytes");
        ServletServerHttpRequest inputMessage = new ServletServerHttpRequest(request);
        try {
            List<HttpRange> httpRanges = inputMessage.getHeaders().getRange();
            response.setStatus(HttpServletResponse.SC_PARTIAL_CONTENT);
            this.resourceRegionHttpMessageConverter.write(
                    HttpRange.toResourceRegions(httpRanges, resource), mediaType, outputMessage);
        }
        catch (IllegalArgumentException ex) {
            response.setHeader("Content-Range", "bytes */" + resource.contentLength());
            response.sendError(HttpServletResponse.SC_REQUESTED_RANGE_NOT_SATISFIABLE);
        }
    }
}
```
