---
title: springboot静态资源定义mime类型
date: 2019-08-02 23:52:43
categories: spring
tags:
  - springboot
  - mime
  - 问题
---

## 问题描述

项目中需要访问静态资源文件`xxx.ccxml`,这个文件不属于标准的文件格式。浏览器访问时，默认下载该文件。我们是期望可以直接在页面上查看的。

## 背景知识

> MIME(Multipurpose Internet Mail Extensions)多用途互联网邮件扩展类型。是设定某种扩展名的文件用一种应用程序来打开的方式类型，当该扩展名文件被访问的时候，浏览器会自动使用指定应用程序来打开。多用于指定一些客户端自定义的文件名，以及一些媒体文件打开方式。

详情可参考[MIME 参考文档](https://baike.baidu.com/item/MIME/2900607?fr=aladdin)

## 解决方案

我们注册关于`ccxml`扩展类型的默认打开方式即可。

一般情况下，在`tomcat`目录下的`conf/web.xml`修改或新增

```xml
 <mime-mapping>
        <extension>ccxml</extension>
        <mime-type>application/xml</mime-type>
 </mime-mapping>
```

针对于`SpringBoot`的内置容器，提供了接口以供修改

Spring Boot 1:

```java
@Configuration
public class HbbtvMimeMapping implements EmbeddedServletContainerCustomizer {

    @Override
    public void customize(ConfigurableEmbeddedServletContainer container) {
        MimeMappings mappings = new MimeMappings(MimeMappings.DEFAULT);
        mappings.add("ccxml", "application/xml; charset=utf-8");
        container.setMimeMappings(mappings);
    }

}
```

Spring Boot 2:

```java
@Configuration
public class HbbtvMimeMapping implements WebServerFactoryCustomizer<ConfigurableServletWebServerFactory> {
    @Override
    public void customize(ConfigurableServletWebServerFactory factory) {
        MimeMappings mappings = new MimeMappings(MimeMappings.DEFAULT);
        mappings.add("ccxml", "application/xml; charset=utf-8");
        factory.setMimeMappings(mappings);
    }
}
```

## Spring 加载静态资源的`mime`源码分析

针对`SpringBoot2`，一般我们使用的是`tomcat`容器,我们自定义的加载`mimeType`的类注入了`ConfigurableServletWebServerFactory`实现类中`TomcatServletWebServerFactory`，其方法`configureContext`将自定义的`mimeType`存储到集合中
节选片段

```java
for (MimeMappings.Mapping mapping : getMimeMappings()) {
    //getMimeMappings即为用自定义添加的扩展
    //context实现类StandardContext
    context.addMimeMapping(mapping.getExtension(), mapping.getMimeType());
}
```

`StandardContext`

```java
@Override
public void addMimeMapping(String extension, String mimeType) {

    synchronized (mimeMappings) {
        //对外暴露的接口findMimeMapping
        mimeMappings.put(extension.toLowerCase(Locale.ENGLISH), mimeType);
    }
    fireContainerEvent("addMimeMapping", extension);

}
```

根据{% post_link spring静态资源加载源码浅析 %}中的分析，找到`ResourceHttpRequestHandler`，实际执行方法`handleRequest`节选代码片段

```java
MediaType mediaType = getMediaType(request, resource);

if (METHOD_HEAD.equals(request.getMethod())) {
    setHeaders(response, resource, mediaType);
    return;
}
```

我们先看下`MediaType`的加载，

```java
protected MediaType getMediaType(HttpServletRequest request, Resource resource) {
    return (this.contentNegotiationStrategy != null ?
            this.contentNegotiationStrategy.getMediaTypeForResource(resource) : null);
}
```

`this.contentNegotiationStrategy`有方法`initContentNegotiationStrategy`来加载

```java
protected PathExtensionContentNegotiationStrategy initContentNegotiationStrategy() {
    Map<String, MediaType> mediaTypes = null;
    if (getContentNegotiationManager() != null) {
        PathExtensionContentNegotiationStrategy strategy =
                getContentNegotiationManager().getStrategy(PathExtensionContentNegotiationStrategy.class);
        if (strategy != null) {
            mediaTypes = new HashMap<>(strategy.getMediaTypes());
        }
    }
    //可以看出一般情况下加载ServletPathExtensionContentNegotiationStrategy
    return (getServletContext() != null ?
            new ServletPathExtensionContentNegotiationStrategy(getServletContext(), mediaTypes) :
            new PathExtensionContentNegotiationStrategy(mediaTypes));
}
```

我们追踪`PathExtensionContentNegotiationStrategy`的`getMediaTypeForResource`方法中

```java
public MediaType getMediaTypeForResource(Resource resource) {
    MediaType mediaType = null;
    //我们可以看到mimeType和servletcontext上下文有关
    String mimeType = this.servletContext.getMimeType(resource.getFilename());
    if (StringUtils.hasText(mimeType)) {
        mediaType = MediaType.parseMediaType(mimeType);
    }
    if (mediaType == null || MediaType.APPLICATION_OCTET_STREAM.equals(mediaType)) {
        MediaType superMediaType = super.getMediaTypeForResource(resource);
        if (superMediaType != null) {
            mediaType = superMediaType;
        }
    }
    return mediaType;
}

```

那么我们看下具体的`servletContext.getMimeType`实现，针对`SpringBoot2`，一般我们使用的是`tomcat`容器，
我们可定位到`ApplicationContext`

```java
@Override
public String getMimeType(String file) {

    if (file == null)
        return null;
    int period = file.lastIndexOf('.');
    if (period < 0)
        return null;
    String extension = file.substring(period + 1);
    if (extension.length() < 1)
        return null;
    //此处context既是一开始提到的StandardContext，即可得到上文中我们自定义添加的mimetype
    return context.findMimeMapping(extension);

}
```

最后可以看到`response`的`ContentType`和`mediaType`息息相关。

```java
protected void setHeaders(HttpServletResponse response, Resource resource, @Nullable MediaType mediaType)
        throws IOException {

    long length = resource.contentLength();
    if (length > Integer.MAX_VALUE) {
        response.setContentLengthLong(length);
    }
    else {
        response.setContentLength((int) length);
    }

    if (mediaType != null) {
        //实际返回content-Type和MediaType有关
        response.setContentType(mediaType.toString());
    }
    if (resource instanceof HttpResource) {
        HttpHeaders resourceHeaders = ((HttpResource) resource).getResponseHeaders();
        resourceHeaders.forEach((headerName, headerValues) -> {
            boolean first = true;
            for (String headerValue : headerValues) {
                if (first) {
                    response.setHeader(headerName, headerValue);
                }
                else {
                    response.addHeader(headerName, headerValue);
                }
                first = false;
            }
        });
    }
    response.setHeader(HttpHeaders.ACCEPT_RANGES, "bytes");
}
```
