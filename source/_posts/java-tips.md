---
title: java tips
date: 2019-08-06 10:50:37
categories: java
tags:
  - java
  - tips
---

### 将常量放在接口中，通过继承该接口，调用常量

```java
public interface ClassConstants{
   int CONSUMER = 1;//接口中变量默认为 static final
   int DISPLAY = 2;
}
```

### 查看 Class 是否是基本类型

```java
clasz.isPrimitive();
```

### 查看类是否为基本类型或包装类型

```java
import org.apache.commons.lang3.ClassUtils;
ClassUtils.isPrimitiveOrWrapper(klass)
```

### 读取 properties 中文乱码解决

```java
properties.load(new InputStreamReader(AutoConfig.class.getResourceAsStream("/application.properties"),"utf-8"));
```

### 判断类是否为数组

```java
klass.isArray();
```

### 判断类是否继承自

```java
Father.class.isAssignableFrom(Son.class)
```

### 获取当前执行的方法名,通过方法内的内部类来实现的

```java
new Object(){}.getClass().getEnclosingMethod().getName();
```

### 使用 shell

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

### 基本类型零值

对基本数据类型来说，对于类变量`static`和全局变量，如果不显式地对其赋值而直接使用，则系统会为其赋予默认的零值，可以根据这个特性，直接用静态类常量来获取基本变量的初始值

```java
public class Primitive {
  public static int i; //默认值0
  public static char c; //默认值'\u0000'
}
```

### 反射工具类

第三方反射工具类

```xml
<dependency>
    <groupId>org.reflections</groupId>
    <artifactId>reflections</artifactId>
    <version>0.9.10</version>
</dependency>
```

扫描类在某个包下的所有子类

```java
Reflections reflections = new Reflections("my.project");
Set<Class<? extends SomeType>> subTypes = reflections.getSubTypesOf(SomeType.class);

```

扫描在某个包下的被注解了某个注解的所有类

```java
Set<Class<?>> annotated = reflections.getTypesAnnotatedWith(SomeAnnotation.class);
```

### `Comparator.comparing`

可是使用 lambda 快速实现`comparable`

```java
Comparator<Player> byRanking
 = (Player player1, Player player2) -> player1.getRanking() - player2.getRanking();
```

类似`Collectors`提供了快捷的`Comparator`方法

```java
Comparator<Player> byRanking = Comparator
  .comparing(Player::getRanking);
Comparator<Player> byAge = Comparator
  .comparing(Player::getAge);
```

### 批量反编译 jar 包

```shell
ls *.jar|xargs -I {} jadx {} -d src
```

### 问题

`NoSuchMethodError`一般是由版本冲突造成的

### 进制

```java
int x = 0b11;// 二进制
int x = 0B11;// 二进制
int x = 0x11;// 十六进制
int x = 0X11;// 十六进制
int x = 011; //  八进制
```
