---
title: java tips
date: 2019-08-06 10:50:37
categories: java
tags:
  - java
  - tips
---

控制台`console`乱码

`java`启动参数添加 `-Dfile.encoding=utf-8`

将常量放在接口中，通过继承该接口，调用常量

```java
public interface ClassConstants{
   int CONSUMER = 1;//接口中变量默认为 static final
   int DISPLAY = 2;
}
```

查看 Class 是否是基本类型

```java
clasz.isPrimitive();
```

查看类是否为基本类型或包装类型

```java
import org.apache.commons.lang3.ClassUtils;
ClassUtils.isPrimitiveOrWrapper(klass)
```

读取 properties 中文乱码解决

```java
properties.load(new InputStreamReader(AutoConfig.class.getResourceAsStream("/application.properties"),"utf-8"));
```

判断类是否为数组

```java
klass.isArray();
```

判断类是否继承自

```java
Father.class.isAssignableFrom(Son.class)
```

流快速删除,`Collection`提供了方法

```java
Collection.removeIf(Predicate<? super E> filter)
```

获取当前执行的方法名,通过方法内的内部类来实现的

```java
new Object(){}.getClass().getEnclosingMethod().getName();
```

设置`SAXReader`的`feature`属性，禁止校验`dtd`文件,读取`String`为`DOMDocument`

```java
import com.sun.org.apache.xerces.internal.impl.Constants;

/**
 * 在读取文件时，去掉dtd的验证，可以缩短运行时间
 */
public static SAXReader getSAXReader(){
    SAXReader saxReader = new SAXReader(DOMDocumentFactory.getInstance(),false);
     try {
         saxReader.setFeature(Constants.XERCES_FEATURE_PREFIX + Constants.LOAD_EXTERNAL_DTD_FEATURE, false);  //设置不需要校验头文件
     } catch (Exception e) {
         e.printStackTrace();
     }
     return saxReader;
 }

String xml = "...xml...";
DOMDocument document = (DOMDocument) getSAXReader().read(new StringReader(xml));

```

切割字符串

```java
String value = "Notice:4001";
StringTokenizer st = new StringTokenizer(value, ":");
if(st.hasMoreElements()){
  System.out.println(st.nextToken());
}
```

`String` 替换 正则匹配组

```java
String s = "HelloWorldMyNameIsCarl".replaceAll("(.)([A-Z])", "$1_$2");
String s = "1.1".replaceAll("(\\.\\d)$", "$10");//$1表示前面正则表达式组1所捕获到的字符
```

`Spring`注入文件

```java
 import org.springframework.core.io.Resource;

 @Value("classpath:rootxml.js")
 private Resource cert;

 @Test
 public void test() throws ScriptException, IOException {
    System.out.println(StreamUtils.copyToString(cert.getInputStream(), StandardCharsets.UTF_8));
 }
```

`@Autowired(required = false)`若`Spring`容器中没有对应的`BeanDefinition`时不会注入值，可赋值一个默认值避免空指针的情况。

`Spring`的`@Scheduled`  可使用`crontab`语法，但是不同于`unix`的标准语法，它第一位是秒

```java
@Scheduled(cron = "1 22 22 * * *")
public void log() {
    logger.info("--------------------" + index++);
}
```

`cron`规则一定是 6 位以空白字符间隔的字符串，其中每位代表的含义如下

```shell
秒     分   小时    日    月    星期
0-59 0-59  0-23  1-31  1-12  0-6

记住几个特殊符号的含义:
*  代表取值范围内的数字
*/x  代表每x
x-y  代表从x到y
,  分开几个离散的数字
```

使用 shell

```java
//获取当前系统名称，可根据不同系统调用不同的命令
String os = System.getProperty("os.name");
//命令行的参数
String [] para = new String[]{"-l"}
//执行命令
Process ls = Runtime.getRuntime().exec("ls",para, new File("/Users/li/Downloads"));



//获取命令执行结果的inputstream流
String getLs = new BufferedReader(new InputStreamReader(ls.getInputStream())).lines().collect(Collectors.joining(System.lineSeparator()));

//在目录下执行具体的命令
//因为java执行shell无法进行连续性的交互命令，通过封装的bash或者python脚本执行一系列命令是比较好的选择
Process process = Runtime.getRuntime().exec("python test.py", null, new File("/Users/li/Downloads"));
// 部分os需要先输出outputStream流，才能正确取得shell执行结果
Outputstream out = process.getOutputStream();
out.flush();
out.close();

//使用构造器模式
ProcessBuilder builder = new ProcessBuilder();
builder.command("more","test.py");
builder.directory(new File("/Users/li/Downloads"));
//重定向错误流，即System.Err
builder.redirectErrorStream(true);
Process process = builder.start();
```

获取`tomcat`运行端口

```java
//通过classpath定位tomcat配置文件conf/server.xml，使用xpath去解析
File serverXml = new File("/Users/li/java/apache-tomcat-7.0.70/conf/server.xml");
DocumentBuilderFactory domFactory = DocumentBuilderFactory.newInstance();
domFactory.setNamespaceAware(true); // never forget this!
DocumentBuilder builder = domFactory.newDocumentBuilder();
Document doc = builder.parse(serverXml);
XPathFactory factory = XPathFactory.newInstance();
XPath xpath = factory.newXPath();
XPathExpression expr = xpath.compile("/Server/Service[@name='Catalina']/Connector[starts-with(@protocol,'HTTP')]/@port[1]");
String result = (String) expr.evaluate(doc, XPathConstants.STRING);
port = result != null && result.length() > 0 ? Integer.valueOf(result) : null;
```

## `tomcat`使用`java`启动变量作为端口

tomcat 默认会加载`bin`目录下新建`setenv.sh`作为启动环境，若无则新建即可

```shell
#!/bin/sh
#JAVA-OPTIONS

JAVA_OPTS="$JAVA_OPTS -Dtomcat.port=9999"
```

`tomcat`的端口配置文件`conf/server.xml`中，将默认端口替换为如下

```xml
 <Service name="Catalina">

<Connector port="{tomcat.port}" protocol="HTTP/1.1"
    ...
```

## stream 一些方法

`reduce`

```java
 List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6);
String join= numbers.stream().map(String::valueOf).reduce((total, element) -> total + element+"").get();
System.out.println("join= " + join);
```

`groupingBy`

```java
 List<String> items =
            Arrays.asList("apple", "apple", "banana",
                "apple", "orange", "banana", "papaya");
Map<String, Long> result =
    items.stream().collect(
        Collectors.groupingBy(
            Function.identity(), Collectors.counting()
        )
    );
System.out.println("result = " + result);
Map<Object, Set<String>> collect = items.stream().collect(Collectors.groupingBy(String::length, Collectors.mapping(e -> e,
    Collectors.toSet())));

System.out.println("collect = " + collect);
```

`join`

```java
String join = items.stream().collect(Collectors.joining(","));

```

## EventBus

`maven`

```xml
<dependency>
    <groupId>com.google.guava</groupId>
    <artifactId>guava</artifactId>
    <version>21.0</version>
</dependency>
```

`post`事件，注册的 listener 中注解了`@Subscribe`的方法会被执行，该方法的参数的类型需要与`event`类型一致，若没有类型一致的`@Subscribe`，则由参数类型`DeadEvent`的`listener`统一处理

```java
public class EventBusTest {
    @Test
    public void test() {
        EventBus eventBus = new EventBus();
        EventListener eventListener = new EventListener();
        eventBus.register(eventListener);
        eventBus.post("hello");
        eventBus.post(123);
    }
    public static class EventListener {
        @Subscribe
        public void stringEvent(String event) {
            System.out.println("event = " + event);
        }
        @Subscribe
        public void handleDeadEvent(DeadEvent deadEvent) {
            System.out.println("deadEvent = " + deadEvent);
        }
    }
}

```

## `dom4j`直接获取值

```java
System.out.println(doc.selectObject("substring(/root/name/text(),2)"));
```

## `junit` 断言异常

```java
public class Student {
    public boolean canVote(int age) {
        if (i<=0) throw new IllegalArgumentException("age should be +ve");
        if (i<18) return false;
        else return true;
    }
}
public class TestStudent{

    @Rule
    public ExpectedException thrown= ExpectedException.none();

    @Test
    public void canVote_throws_IllegalArgumentException_for_zero_age() {
        Student student = new Student();
        thrown.expect(IllegalArgumentException.class);
        thrown.expectMessage("age should be +ve");
        student.canVote(0);
    }
}
```

## 基本类型零值

对基本数据类型来说，对于类变量`static`和全局变量，如果不显式地对其赋值而直接使用，则系统会为其赋予默认的零值，可以根据这个特性，直接用静态类常量来获取基本变量的初始值

```java
public class Primitive {
  public static int i; //默认值0
  public static char c; //默认值'\u0000'
}
```
