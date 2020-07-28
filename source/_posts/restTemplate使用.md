---
title: restTemplate使用
date: 2019-08-09 14:22:45
categories: spring
tags:
  - spring
  - restTemplate
---

## 基础

推荐使用`RestTemplateBuilder`构建`RestTemplate`

我们看下`RestTemplate`的基础成员变量

- `requestFactory: ClientHttpRequestFactory`
- `defaultUriVariables: Map<String, ?>`
- `uriTemplateHandler: UriTemplateHandler`
- `interceptors: List<ClientHttpRequestInterceptor>`
- `messageConverters: List<HttpMessageConverter<?>>`
- `errorHandler: ResponseErrorHandler`

下面我们主要针对这些属性做一些分析

## requestFactory

指定使用的`HTTP`请求方式，
设置`http`请求工厂类，处理超时，线程，异常处理等情况。

```java
RestTemplate restTemplate() {
    return new RestTemplateBuilder().requestFactory(requestFactory()).build();
}

private Supplier<ClientHttpRequestFactory> requestFactory() {
    return () -> {
        HttpComponentsClientHttpRequestFactory requestFactory = new HttpComponentsClientHttpRequestFactory();
        requestFactory.setConnectionRequestTimeout(3000);
        requestFactory.setConnectTimeout(3000);
        requestFactory.setReadTimeout(8000);
        requestFactory.setHttpClient(httpClient());
        return requestFactory;
    };
}

private HttpClient httpClient() {
    HttpClientBuilder httpClientBuilder = HttpClientBuilder.create();
    httpClientBuilder.setMaxConnTotal(50);
    httpClientBuilder.setMaxConnPerRoute(5);
    return HttpClientBuilder.create().build();
}
```

## defaultUriVariables

当被赋值时就不能使用自定义`uriTemplateHandler`。这是就使用默认的`uriTemplateHandler`即`DefaultUriBuilderFactory`。
假设现在`defaultUriVariables`包含`default=demo`。

例如：

```java
String url = "http://localhost:8080/{default}/{replace}"

Map<String,String> uriVariables = new HashMap<>();
uriVariables.put("replace","someuri");

public <T> T postForObject(String url, @Nullable Object request, Class<T> responseType,
        Map<String, ?> uriVariables)
```

在实际请求时:
`{default}`会被替换为`demo`  
`{replace}`会被替换为`someuri`  
 替换后的值中包含`/`会无法正常解析。

## uriTemplateHandler

默认的 uriTemplateHandler 会将 uriVariables 中的 value 进行转译，因此无法'/'会被解析为 ascii 符号。根据需要，生成满足自己需要的 URI。

```java
public interface UriTemplateHandler {
    URI expand(String uriTemplate, Map<String, ?> uriVariables);
    URI expand(String uriTemplate, Object... uriVariables);
}
```

返回的 URI 经过自定义处理器会将`{xxx}`,替换为`uriVariables`中对应的值，这个可以正常解析`/`

```java
RestTemplate rest = restTemplate();
    rest.setUriTemplateHandler(new UriTemplateHandler() {
        @Override
        public URI expand(String uriTemplate, Map<String, ?> uriVariables) {
            return new UriTemplate(uriTemplate).expand(uriVariables);
        }

        @Override
        public URI expand(String uriTemplate, Object... uriVariables) {
            return new UriTemplate(uriTemplate).expand(uriVariables);
        }
    });

    Map<String, Object> uriVariables = new HashMap<>();
    uriVariables.put("replace", "response/test");
    String hello = rest.postForObject("http://localhost:8080/{replace}", "", String.class, uriVariables);
```

## interceptors

类似`AOP`切面，在`HTTP`请求前后进行拦截，比如统一加`headers

```java
public interface ClientHttpRequestInterceptor {

    ClientHttpResponse intercept(HttpRequest request, byte[] body, ClientHttpRequestExecution execution)
            throws IOException;
}

 ClientHttpRequestInterceptor interceptor = (request, body, execution) -> {
            return execution.execute(request, body);
        };
```

## messageConverters

与`SpringMVC`的`messageConverters`原理是一样的。`HTTP`交易时数据传递是通过二进制`byte`传递的。而我们使用`RestTemplate`时，一般请求返回都使用`javaBean`,那就需要`messageConverters`来统一处理。

我们看下`RestTemplate`的静态方法

```java
private static boolean romePresent;

private static final boolean jaxb2Present;

private static final boolean jackson2Present;

private static final boolean jackson2XmlPresent;

private static final boolean jackson2SmilePresent;

private static final boolean jackson2CborPresent;

private static final boolean gsonPresent;

private static final boolean jsonbPresent;

static {
    ClassLoader classLoader = RestTemplate.class.getClassLoader();
    romePresent = ClassUtils.isPresent("com.rometools.rome.feed.WireFeed", classLoader);
    jaxb2Present = ClassUtils.isPresent("javax.xml.bind.Binder", classLoader);
    jackson2Present =
            ClassUtils.isPresent("com.fasterxml.jackson.databind.ObjectMapper", classLoader) &&
                    ClassUtils.isPresent("com.fasterxml.jackson.core.JsonGenerator", classLoader);
    jackson2XmlPresent = ClassUtils.isPresent("com.fasterxml.jackson.dataformat.xml.XmlMapper", classLoader);
    jackson2SmilePresent = ClassUtils.isPresent("com.fasterxml.jackson.dataformat.smile.SmileFactory", classLoader);
    jackson2CborPresent = ClassUtils.isPresent("com.fasterxml.jackson.dataformat.cbor.CBORFactory", classLoader);
    gsonPresent = ClassUtils.isPresent("com.google.gson.Gson", classLoader);
    jsonbPresent = ClassUtils.isPresent("javax.json.bind.Jsonb", classLoader);
}
```

再看下`RestTemplate`构造器，当`classpath`中有对应的`class`时，可以看到`RestTemplate`会自动加载

```java
public RestTemplate() {
    this.messageConverters.add(new ByteArrayHttpMessageConverter());
    this.messageConverters.add(new StringHttpMessageConverter());
    this.messageConverters.add(new ResourceHttpMessageConverter(false));
    try {
        this.messageConverters.add(new SourceHttpMessageConverter<>());
    }
    catch (Error err) {
        // Ignore when no TransformerFactory implementation is available
    }
    this.messageConverters.add(new AllEncompassingFormHttpMessageConverter());

    if (romePresent) {
        this.messageConverters.add(new AtomFeedHttpMessageConverter());
        this.messageConverters.add(new RssChannelHttpMessageConverter());
    }

    if (jackson2XmlPresent) {
        this.messageConverters.add(new MappingJackson2XmlHttpMessageConverter());
    }
    else if (jaxb2Present) {
        this.messageConverters.add(new Jaxb2RootElementHttpMessageConverter());
    }

    if (jackson2Present) {
        this.messageConverters.add(new MappingJackson2HttpMessageConverter());
    }
    else if (gsonPresent) {
        this.messageConverters.add(new GsonHttpMessageConverter());
    }
    else if (jsonbPresent) {
        this.messageConverters.add(new JsonbHttpMessageConverter());
    }

    if (jackson2SmilePresent) {
        this.messageConverters.add(new MappingJackson2SmileHttpMessageConverter());
    }
    if (jackson2CborPresent) {
        this.messageConverters.add(new MappingJackson2CborHttpMessageConverter());
    }

    this.uriTemplateHandler = initUriTemplateHandler();
}
```

## errorHandler

仅在`HTTP`成功返回后才会被执行，决定当前`HTTP`请求是否成功。`hasError`返回`true`时才会调用`handleError`方法。

```java
public interface ResponseErrorHandler {
    boolean hasError(ClientHttpResponse response) throws IOException;
    void handleError(ClientHttpResponse response) throws IOException;
    default void handleError(URI url, HttpMethod method, ClientHttpResponse response) throws IOException {
        handleError(response);
    }
}
```

## rootUri

通过`RestTemplateBuilder`设置`rootUri`,进行`HTTP`请求时，若非`http`开头，则会自动加上`rootUri`

```java
RestTemplate rest = new RestTemplateBuilder().rootUri("http://localhost:8080").build();
rest.postForObject("/test", "", String.class, variables);
```

## POST 请求参数

上传文件的请求模拟

```java
RestTemplate restTemplate = new RestTemplate();
MultiValueMap multiValueMap = new LinkedMultiValueMap();
FileSystemResource resource = new FileSystemResource(new File("/Users/li/Documents/Blog/db.json"));
multiValueMap.add("file",resource);
String msg = restTemplate.postForObject("http://localhost:8082/upload/any", multiValueMap, String.class);
```

## 上传文件的错误

错误信息

> The request was rejected because no multipart boundary was found

通过查找该报错信息打印处可以定位

```java
FileItemIteratorImpl(RequestContext ctx)
        throws FileUploadException, IOException {
    if (ctx == null) {
        throw new NullPointerException("ctx parameter");
    }

    String contentType = ctx.getContentType();
    if ((null == contentType)
            || (!contentType.toLowerCase(Locale.ENGLISH).startsWith(MULTIPART))) {
        throw new InvalidContentTypeException(String.format(
                "the request doesn't contain a %s or %s stream, content type header is %s",
                MULTIPART_FORM_DATA, MULTIPART_MIXED, contentType));
    }


    final long requestSize = ((UploadContext) ctx).contentLength();

    InputStream input; // N.B. this is eventually closed in MultipartStream processing
    if (sizeMax >= 0) {
        if (requestSize != -1 && requestSize > sizeMax) {
            throw new SizeLimitExceededException(String.format(
                    "the request was rejected because its size (%s) exceeds the configured maximum (%s)",
                    Long.valueOf(requestSize), Long.valueOf(sizeMax)),
                    requestSize, sizeMax);
        }
        // N.B. this is eventually closed in MultipartStream processing
        input = new LimitedInputStream(ctx.getInputStream(), sizeMax) {
            @Override
            protected void raiseError(long pSizeMax, long pCount)
                    throws IOException {
                FileUploadException ex = new SizeLimitExceededException(
                String.format("the request was rejected because its size (%s) exceeds the configured maximum (%s)",
                        Long.valueOf(pCount), Long.valueOf(pSizeMax)),
                        pCount, pSizeMax);
                throw new FileUploadIOException(ex);
            }
        };
    } else {
        input = ctx.getInputStream();
    }

    String charEncoding = headerEncoding;
    if (charEncoding == null) {
        charEncoding = ctx.getCharacterEncoding();
    }

    boundary = getBoundary(contentType);
    if (boundary == null) {
        IOUtils.closeQuietly(input); // avoid possible resource leak
        throw new FileUploadException("the request was rejected because no multipart boundary was found");
    }

    notifier = new MultipartStream.ProgressNotifier(listener, requestSize);
    try {
        multi = new MultipartStream(input, boundary, notifier);
    } catch (IllegalArgumentException iae) {
        IOUtils.closeQuietly(input); // avoid possible resource leak
        throw new InvalidContentTypeException(
                String.format("The boundary specified in the %s header is too long", CONTENT_TYPE), iae);
    }
    multi.setHeaderEncoding(charEncoding);

    skipPreamble = true;
    findNextItem();
}
```

通过查看`getBoundary`

```java
protected byte[] getBoundary(String contentType) {
    ParameterParser parser = new ParameterParser();
    parser.setLowerCaseNames(true);
    // Parameter parser can handle null input
    Map<String,String> params =
            parser.parse(contentType, new char[] {';', ','});
    //Content-Type中包含boundary=xxx字段
    String boundaryStr = params.get("boundary");

    if (boundaryStr == null) {
        return null;
    }
    byte[] boundary;
    boundary = boundaryStr.getBytes(StandardCharsets.ISO_8859_1);
    return boundary;
}
```

根据上一节的说明，我们知道上送文件是使用`MultiValueMap`来上送的，那么我们只要知道`MultiValueMap`请求的`Content-Type`是什么即可。

根据前面章节`messageConverters`的加载介绍，我们知道`RestTemplate`会选择一个合适的处理器来处理，
其中`AllEncompassingFormHttpMessageConverter`的父类`FormHttpMessageConverter`

```java
public void doWithRequest(ClientHttpRequest httpRequest) throws IOException {
    super.doWithRequest(httpRequest);
    Object requestBody = this.requestEntity.getBody();
    if (requestBody == null) {
        HttpHeaders httpHeaders = httpRequest.getHeaders();
        HttpHeaders requestHeaders = this.requestEntity.getHeaders();
        if (!requestHeaders.isEmpty()) {
            requestHeaders.forEach((key, values) -> httpHeaders.put(key, new LinkedList<>(values)));
        }
        if (httpHeaders.getContentLength() < 0) {
            httpHeaders.setContentLength(0L);
        }
    }
    else {
        //request的类型需要继承自MultiValueMap或者HttpEntity<MultiValueMap>
        Class<?> requestBodyClass = requestBody.getClass();
        Type requestBodyType = (this.requestEntity instanceof RequestEntity ?
                ((RequestEntity<?>)this.requestEntity).getType() : requestBodyClass);
        HttpHeaders httpHeaders = httpRequest.getHeaders();
        HttpHeaders requestHeaders = this.requestEntity.getHeaders();
        MediaType requestContentType = requestHeaders.getContentType();
        for (HttpMessageConverter<?> messageConverter : getMessageConverters()) {
            if (messageConverter instanceof GenericHttpMessageConverter) {
                GenericHttpMessageConverter<Object> genericConverter =
                        (GenericHttpMessageConverter<Object>) messageConverter;
                if (genericConverter.canWrite(requestBodyType, requestBodyClass, requestContentType)) {
                    if (!requestHeaders.isEmpty()) {
                        requestHeaders.forEach((key, values) -> httpHeaders.put(key, new LinkedList<>(values)));
                    }
                    logBody(requestBody, requestContentType, genericConverter);
                    genericConverter.write(requestBody, requestBodyType, requestContentType, httpRequest);
                    return;
                }
            }
            //requestContentType需满足如下之一
            // null
            // multipart/form-data
            // */*
            //application/x-www-form-urlencoded
            else if (messageConverter.canWrite(requestBodyClass, requestContentType)) {
                if (!requestHeaders.isEmpty()) {
                    requestHeaders.forEach((key, values) -> httpHeaders.put(key, new LinkedList<>(values)));
                }
                logBody(requestBody, requestContentType, messageConverter);
                ((HttpMessageConverter<Object>) messageConverter).write(
                        requestBody, requestContentType, httpRequest);
                return;
            }
        }
        String message = "No HttpMessageConverter for " + requestBodyClass.getName();
        if (requestContentType != null) {
            message += " and content type \"" + requestContentType + "\"";
        }
        throw new RestClientException(message);
    }
}
```

查看具体`FormHttpMessageConverter`的`write`方法

```java
public void write(MultiValueMap<String, ?> map, @Nullable MediaType contentType, HttpOutputMessage outputMessage)
        throws IOException, HttpMessageNotWritableException {
    //上送文件肯定使用的writeMultipart
    if (!isMultipart(map, contentType)) {
        writeForm((MultiValueMap<String, Object>) map, contentType, outputMessage);
    }
    else {
        writeMultipart((MultiValueMap<String, Object>) map, outputMessage);
    }
}
```

```java
private void writeMultipart(final MultiValueMap<String, Object> parts, HttpOutputMessage outputMessage)
        throws IOException {

    final byte[] boundary = generateMultipartBoundary();
    Map<String, String> parameters = new LinkedHashMap<>(2);
    if (!isFilenameCharsetSet()) {
        parameters.put("charset", this.charset.name());
    }
    //这里我们可以看到生成的boundary信息
    parameters.put("boundary", new String(boundary, StandardCharsets.US_ASCII));

    MediaType contentType = new MediaType(MediaType.MULTIPART_FORM_DATA, parameters);
    HttpHeaders headers = outputMessage.getHeaders();
    headers.setContentType(contentType);

    if (outputMessage instanceof StreamingHttpOutputMessage) {
        StreamingHttpOutputMessage streamingOutputMessage = (StreamingHttpOutputMessage) outputMessage;
        streamingOutputMessage.setBody(outputStream -> {
            writeParts(outputStream, parts, boundary);
            writeEnd(outputStream, boundary);
        });
    }
    else {
        writeParts(outputMessage.getBody(), parts, boundary);
        writeEnd(outputMessage.getBody(), boundary);
    }
}
```

所以我们定位一下具体发生错误的情况下使用的是何种`messageConverter`即可

## `messageConverter`有关问题

当请求的`api`返回的`content-type`不是标准的`application/json`时，默认的`messageConverter`不支持处理

```java
List<HttpMessageConverter<?>> messageConverters = new ArrayList<HttpMessageConverter<?>>();
//Add the Jackson Message converter
MappingJackson2HttpMessageConverter converter = new MappingJackson2HttpMessageConverter();

// Note: here we are making this converter to process any kind of response,
// not only application/*json, which is the default behaviour
converter.setSupportedMediaTypes(Collections.singletonList(MediaType.ALL));
messageConverters.add(converter);
restTemplate.setMessageConverters(messageConverters);
```
