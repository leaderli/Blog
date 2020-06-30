---
title: java-配置相关
date: 2020-06-04 22:28:28
categories: java
tags:
  - tips
---

### 1. `加载资源文件`

一般加载资源文件可以使用如下方法

```java
ClassLoader.getSystemResourceAsStream("xxx.properties")
SomeClass.class.getResourceAsStream("xxx.properties")
```

但是注意，第一种方法是有缺陷的，因为不同的类加载器会造成读取不到文件的情况，典型的就是`tomcat`的类加载读取不到应用路径下的文件

### 2. 查看 java 启动变量

```java
System.getenv();//系统级别环境变量，可以在~/.bash_profile中配置
System.getProperties();//java环境变量，一般可以用-Dkey=value来指定
System.setProperty(key,value) //临时指定java环境变量
```

### 3. InetAddress.getLocalHost() java.net.UnknownHostException 异常

问题原因是在系统的 /etc/Hostname 中配置了“zw_65_43” 作为主机名，而在/etc/hosts 文件中没有 相应的“zw_65_43”。简单的解决办法是

对应关系配好就可以，甚至删除/etc/Hostname 这个文件也可以。

深层的原因： 在大多数 Linux 操作系统中，都是以/etc/hosts 中的配置查找主机名的，但是 Detian based system 用/etc/Hostname 文件中的配置做主机名。
结论：

1. 设置本机名称：hostname mName xxx 最好不是写 IP 地址的形式，若写则必须是本机的完全 IP 形式(不要只写一半)
2. 在/etc/hosts 里加一行 本机 IP mName
3. 用 InetAddress.getLocalHost().getHostAddress()测试一下结果是否是与本机 IP 一致

也可以在`shell`中执行`echo $HOSTNAME`查看主机名，通过`ping $HOSTNAME`查看是否问题已经解决了

### 4. logback 日志

logback 日志在开始阶段会输出一些自身的日志，通过配置`NopStatusListener`即可以清除

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>

    <!-- Stop output INFO at start -->
    <statusListener class="ch.qos.logback.core.status.NopStatusListener" />

    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <layout class="ch.qos.logback.classic.PatternLayout">
            <Pattern>
                %d{yyyy-MM-dd HH:mm:ss} %-5level %logger{36} - %msg%n
            </Pattern>
        </layout>
    </appender>

    <root level="error">
        <appender-ref ref="STDOUT"/>
    </root>

</configuration>
```

### 5. `tomcat`使用`java`启动变量作为端口

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

### 6. 控制台`console`乱码

`java`启动参数添加 `-Dfile.encoding=utf-8`
