---
title: java-字符串
date: 2020-06-04 22:15:48
categories: java
tags:
---

### 切割字符串

```java
String value = "Notice:4001";
StringTokenizer st = new StringTokenizer(value, ":");
if(st.hasMoreElements()){
  System.out.println(st.nextToken());
}
```

### `String` 替换 正则匹配组

```java
String s = "HelloWorldMyNameIsCarl".replaceAll("(.)([A-Z])", "$1_$2");
String s = "1.1".replaceAll("(\\.\\d)$", "$10");//$1表示前面正则表达式组1所捕获到的字符
```

### java 字符串占位符

```java
String msg = "hello{0},hello{1}";
String format = MessageFormat.format(msg, new ArrayList<>(), 100);
System.out.println("format = " + format);

```

可以使用 Apache Common 工具类

```java
import org.apache.commons.lang.text.StrSubstitutor;
...

String template = "Welcome to {theWorld}. My name is {myName}.";

Map<String, String> values = new HashMap<>();
values.put("theWorld", "Stackoverflow");
values.put("myName", "Thanos");

String message = StrSubstitutor.replace(template, values, "{", "}");

System.out.println(message)
```

输出结果

> format = hello[],hello100

### html 特殊字符转译

```java
import org.apache.commons.lang3.StringEscapeUtils;
...
StringEscapeUtils.unescapeHtml4（str）
```

### URL 中文转议

```java
URLEncoder.encode("中文", StandardCharsets.UTF_8.name())
URLDecoder.decode("%E4%B8%AD%E6%96%87", StandardCharsets.UTF_8.name())
```

### 规范输出数字

当数字位数不够时，自动在前段补 0

```java
String.format("%03d",num)
```
