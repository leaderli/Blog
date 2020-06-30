---
title: spring ControllerAdvice源码分析
date: 2019-08-06 23:33:10
categories: spring
tags:
  - springboot
  - ControllerAdvice
---

## 版本说明

`jdk`:1.8.0_131  
`springboot`:2.1.6.RELEAS  
`maven`:3.6.1  
`database`:mysql-5.7.14  
`lombok插件`

## 源码分析

仅仅针对被`@ControllerAdvice`注解的且实现接口`ResponseBodyAdvice`的类，进行源码分析，了解一下当`controller`中被`@ResponseBody`注解的方法的返回值，是如何被解析成前端需要的值的。
至于`RequestBodyAdvice`和`@ExceptionHandler`等实现原理是差不多的。

根据{% post_link Spring自定义ReturnValueHandlers %}中的分析，我们了解了实际调用`controller`类中的被`@ResponseBody`注解方法时，实际使用`RequestResponseBodyMethodProcessor`处理器去处理。

我们查看下`RequestResponseBodyMethodProcessor`的`handleReturnValue`

```java
@Override
public void handleReturnValue(@Nullable Object returnValue, MethodParameter returnType,
        ModelAndViewContainer mavContainer, NativeWebRequest webRequest)
        throws IOException, HttpMediaTypeNotAcceptableException, HttpMessageNotWritableException {

    mavContainer.setRequestHandled(true);
    ServletServerHttpRequest inputMessage = createInputMessage(webRequest);
    ServletServerHttpResponse outputMessage = createOutputMessage(webRequest);

    writeWithMessageConverters(returnValue, returnType, inputMessage, outputMessage);
}
```

`writeWithMessageConverters`节选片段

```java
if (selectedMediaType != null) {
        selectedMediaType = selectedMediaType.removeQualityValue();
        for (HttpMessageConverter<?> converter : this.messageConverters) {
            GenericHttpMessageConverter genericConverter = (converter instanceof GenericHttpMessageConverter ?
                    (GenericHttpMessageConverter<?>) converter : null);
            if (genericConverter != null ?
                    ((GenericHttpMessageConverter) converter).canWrite(targetType, valueType, selectedMediaType) :
                    converter.canWrite(valueType, selectedMediaType)) {
                body = getAdvice().beforeBodyWrite(body, returnType, selectedMediaType,
                        (Class<? extends HttpMessageConverter<?>>) converter.getClass(),
                        inputMessage, outputMessage);
                if (body != null) {
                    Object theBody = body;
                    LogFormatUtils.traceDebug(logger, traceOn ->
                            "Writing [" + LogFormatUtils.formatValue(theBody, !traceOn) + "]");
                    addContentDispositionHeader(inputMessage, outputMessage);
                    if (genericConverter != null) {
                        genericConverter.write(body, targetType, selectedMediaType, outputMessage);
                    }
                    else {
                        ((HttpMessageConverter) converter).write(body, selectedMediaType, outputMessage);
                    }
                }
                else {
                    if (logger.isDebugEnabled()) {
                        logger.debug("Nothing to write: null body");
                    }
                }
                return;
            }
        }
    }

```

`this.messageConverters`的循环调用，其实就是用合适的`HttpMessageConverter`来解析返回报文，默认情况下我们用的就是`SpringBoot`内容的`MappingJackson2HttpMessageConverter`处理器

`MappingJackson2HttpMessageConverter`的`canWrite`就是查看`MediaType`是否满足

```java
protected boolean canWrite(@Nullable MediaType mediaType) {
    if (mediaType == null || MediaType.ALL.equalsTypeAndSubtype(mediaType)) {
        return true;
    }
    for (MediaType supportedMediaType : getSupportedMediaTypes()) {
        if (supportedMediaType.isCompatibleWith(mediaType)) {
            return true;
        }
    }
    return false;
}
```

重点的是`getAdvice()`的加载

```java
RequestResponseBodyAdviceChain getAdvice() {
    return this.advice;
}
```

用`Debug`模式一步步回溯最终发现`RequestMappingHandlerAdapter`中

```java
public void afterPropertiesSet() {
    //扫描所有@ControllerAdvice
    initControllerAdviceCache();

    if (this.argumentResolvers == null) {
        //
        List<HandlerMethodArgumentResolver> resolvers = getDefaultArgumentResolvers();
        this.argumentResolvers = new HandlerMethodArgumentResolverComposite().addResolvers(resolvers);
    }
    if (this.initBinderArgumentResolvers == null) {
        List<HandlerMethodArgumentResolver> resolvers = getDefaultInitBinderArgumentResolvers();
        this.initBinderArgumentResolvers = new HandlerMethodArgumentResolverComposite().addResolvers(resolvers);
    }
    if (this.returnValueHandlers == null) {
        List<HandlerMethodReturnValueHandler> handlers = getDefaultReturnValueHandlers();
        this.returnValueHandlers = new HandlerMethodReturnValueHandlerComposite().addHandlers(handlers);
    }
}
```

节选`initControllerAdviceCache`

```java
List<ControllerAdviceBean> adviceBeans = ControllerAdviceBean.findAnnotatedBeans(getApplicationContext());
...
if (!requestResponseBodyAdviceBeans.isEmpty()) {
    this.requestResponseBodyAdvice.addAll(0, requestResponseBodyAdviceBeans);
}

```

节选方法`getDefaultArgumentResolvers`细节

```java
resolvers.add(new RequestResponseBodyMethodProcessor(getMessageConverters(), this.requestResponseBodyAdvice));

```

`RequestResponseBodyMethodProcessor`构造方法最终指向父类`AbstractMessageConverterMethodArgumentResolver`,那么我们看到`@ControllerAdvice`注解的且实现接口`ResponseBodyAdvice`的类被加载到`this.advice`中

```java
public AbstractMessageConverterMethodArgumentResolver(List<HttpMessageConverter<?>> converters,
        @Nullable List<Object> requestResponseBodyAdvice) {

    Assert.notEmpty(converters, "'messageConverters' must not be empty");
    this.messageConverters = converters;
    this.allSupportedMediaTypes = getAllSupportedMediaTypes(converters);
    this.advice = new RequestResponseBodyAdviceChain(requestResponseBodyAdvice);
}
```

那么我们看下`this.advice`的类`RequestResponseBodyAdviceChain`方法`beforeBodyWrite`细节

```java
@Override
@Nullable
public Object beforeBodyWrite(@Nullable Object body, MethodParameter returnType, MediaType contentType,
        Class<? extends HttpMessageConverter<?>> converterType,
        ServerHttpRequest request, ServerHttpResponse response) {

    return processBody(body, returnType, contentType, converterType, request, response);
}

    private <T> Object processBody(@Nullable Object body, MethodParameter returnType, MediaType contentType,
        Class<? extends HttpMessageConverter<?>> converterType,
        ServerHttpRequest request, ServerHttpResponse response) {

    for (ResponseBodyAdvice<?> advice : getMatchingAdvice(returnType, ResponseBodyAdvice.class)) {
        //决定自定义@ControllerAdvice是否启用
        if (advice.supports(returnType, converterType)) {
            //调用我们的返回值处理类
            body = ((ResponseBodyAdvice<T>) advice).beforeBodyWrite((T) body, returnType,
                    contentType, converterType, request, response);
        }
    }
    return body;
}
```

最后贴下`@ControllerAdvice`实现类

```java
package com.li.springboot.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.core.MethodParameter;
import org.springframework.http.MediaType;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.servlet.mvc.method.annotation.ResponseBodyAdvice;

@ControllerAdvice
@Slf4j
public class MyControllerAdvice implements ResponseBodyAdvice{
   @Override
   public boolean supports(MethodParameter returnType, Class converterType) {
       return true;
   }

   @Override
   public Object beforeBodyWrite(Object body, MethodParameter returnType, MediaType selectedContentType, Class selectedConverterType, ServerHttpRequest request, ServerHttpResponse response) {
       log.debug("MyControllerAdvice beforeBodyWrite");
       return body;
   }
}
```
