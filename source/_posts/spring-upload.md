---
title: Spring上传文件
date: 2019-08-21 19:39:37
categories: spring
tags:
  - 上传文件
  - resttemplate
  - EnableConfigurationProperties
---

## MultipartResolver

`DispatcherServlet`用于处理所有请求 ，`doDispatch`方法中会判断请求参数中是否包含文件。

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

            // Determine handler for the current request.
            mappedHandler = getHandler(processedRequest);
            if (mappedHandler == null) {
                noHandlerFound(processedRequest, response);
                return;
            }

    ...
}
```

查看`checkMultipart`细节

```java
protected HttpServletRequest checkMultipart(HttpServletRequest request) throws MultipartException {
    if (this.multipartResolver != null && this.multipartResolver.isMultipart(request)) {
        if (WebUtils.getNativeRequest(request, MultipartHttpServletRequest.class) != null) {
            if (request.getDispatcherType().equals(DispatcherType.REQUEST)) {
                logger.trace("Request already resolved to MultipartHttpServletRequest, e.g. by MultipartFilter");
            }
        }
        else if (hasMultipartException(request)) {
            logger.debug("Multipart resolution previously failed for current request - " +
                    "skipping re-resolution for undisturbed error rendering");
        }
        else {
            try {
                return this.multipartResolver.resolveMultipart(request);
            }
            catch (MultipartException ex) {
                if (request.getAttribute(WebUtils.ERROR_EXCEPTION_ATTRIBUTE) != null) {
                    logger.debug("Multipart resolution failed for error dispatch", ex);
                    // Keep processing error dispatch with regular request handle below
                }
                else {
                    throw ex;
                }
            }
        }
    }
    // If not returned before: return original request.
    return request;
}
```

首先我们了解下`this.multipartResolver`是如何被加载的

我们可以看到`DispatcherServlet`的方法中有初始化

```java
private void initMultipartResolver(ApplicationContext context) {
    try {
        this.multipartResolver = context.getBean(MULTIPART_RESOLVER_BEAN_NAME, MultipartResolver.class);
        if (logger.isTraceEnabled()) {
            logger.trace("Detected " + this.multipartResolver);
        }
        else if (logger.isDebugEnabled()) {
            logger.debug("Detected " + this.multipartResolver.getClass().getSimpleName());
        }
    }
    catch (NoSuchBeanDefinitionException ex) {
        // Default is no multipart resolver.
        this.multipartResolver = null;
        if (logger.isTraceEnabled()) {
            logger.trace("No MultipartResolver '" + MULTIPART_RESOLVER_BEAN_NAME + "' declared");
        }
    }
}
```

通过查看`MultipartResolver`的实现类，我们可以看到如下两个实现类

1. `CommonsMultipartResolver`
2. `StandardServletMultipartResolver`

其中`StandardServletMultipartResolver`在下述自动配置类中有被加载

```java
package org.springframework.boot.autoconfigure.web.servlet;

import javax.servlet.MultipartConfigElement;
import javax.servlet.Servlet;

import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.autoconfigure.condition.ConditionalOnWebApplication;
import org.springframework.boot.autoconfigure.condition.ConditionalOnWebApplication.Type;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.web.servlet.context.ServletWebServerApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.multipart.MultipartResolver;
import org.springframework.web.multipart.commons.CommonsMultipartResolver;
import org.springframework.web.multipart.support.StandardServletMultipartResolver;
import org.springframework.web.servlet.DispatcherServlet;

@Configuration
@ConditionalOnClass({ Servlet.class, StandardServletMultipartResolver.class, MultipartConfigElement.class })
@ConditionalOnProperty(prefix = "spring.servlet.multipart", name = "enabled", matchIfMissing = true)
@ConditionalOnWebApplication(type = Type.SERVLET)
@EnableConfigurationProperties(MultipartProperties.class)
public class MultipartAutoConfiguration {

private final MultipartProperties multipartProperties;

    public MultipartAutoConfiguration(MultipartProperties multipartProperties) {
        this.multipartProperties = multipartProperties;
    }

    @Bean
    @ConditionalOnMissingBean({ MultipartConfigElement.class, CommonsMultipartResolver.class })
    public MultipartConfigElement multipartConfigElement() {
        return this.multipartProperties.createMultipartConfig();
    }

    @Bean(name = DispatcherServlet.MULTIPART_RESOLVER_BEAN_NAME)
    @ConditionalOnMissingBean(MultipartResolver.class)
    public StandardServletMultipartResolver multipartResolver() {
        StandardServletMultipartResolver multipartResolver = new StandardServletMultipartResolver();
        multipartResolver.setResolveLazily(this.multipartProperties.isResolveLazily());
        return multipartResolver;
    }

}

```

可以看出若没有指定`MultipartResolver`时，会默认加载`StandardServletMultipartResolver`。我们查看其`isMultipart`方法可知
当请求`ContentType`类型是以`multipart/`开头则会认为是文件上传操作。

```java
@Override
public boolean isMultipart(HttpServletRequest request) {
    return StringUtils.startsWithIgnoreCase(request.getContentType(), "multipart/");
}
```

## 解决上传文件大小限制

同时我们也可以得出，若没有指定的`MultipartConfigElement`时，会使用默认的`this.multipartProperties.createMultipartConfig()`

通过查看`this.multipartProperties`

```java
@ConfigurationProperties(prefix = "spring.servlet.multipart", ignoreUnknownFields = false)
public class MultipartProperties {
    ...
}
```

`MultipartProperties`被自动`EnableConfigurationProperties`所引用

```java
@Configuration
@ConditionalOnClass({ Servlet.class, StandardServletMultipartResolver.class, MultipartConfigElement.class })
@ConditionalOnProperty(prefix = "spring.servlet.multipart", name = "enabled", matchIfMissing = true)
@ConditionalOnWebApplication(type = Type.SERVLET)
@EnableConfigurationProperties(MultipartProperties.class)
public class MultipartAutoConfiguration {
}
```

则可通过修改对应`SpringBoot`可以配置`application.yml`

```yaml
spring:
  servlet:
    multipart:
      max-file-size: 150MB
      max-request-size: 150MB
```

## `EnableConfigurationProperties`原理

通过查看注解`EnableConfigurationProperties`被调用处，即查找`EnableConfigurationProperties.class`出现处。我们可以看到在`EnableConfigurationPropertiesImportSelector`的方法

```java
private List<Class<?>> getTypes(AnnotationMetadata metadata) {
        MultiValueMap<String, Object> attributes = metadata
                .getAllAnnotationAttributes(EnableConfigurationProperties.class.getName(), false);
        return collectClasses((attributes != null) ? attributes.get("value") : Collections.emptyList());
    }
```

所有注解了`EnableConfigurationProperties`的类被自动注入到容器中了。

```java
@Override
public void registerBeanDefinitions(AnnotationMetadata metadata, BeanDefinitionRegistry registry) {
    getTypes(metadata).forEach((type) -> register(registry, (ConfigurableListableBeanFactory) registry, type));
}
```

```java
private void register(BeanDefinitionRegistry registry, ConfigurableListableBeanFactory beanFactory,
            Class<?> type) {
        String name = getName(type);
        if (!containsBeanDefinition(beanFactory, name)) {
            registerBeanDefinition(registry, name, type);
        }
    }

```

一步一步回溯可以最终可以看到被`AbstractApplicationContext`的`refresh`方法调用。
