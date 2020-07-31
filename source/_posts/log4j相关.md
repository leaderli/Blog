---
title: log4j相关
date: 2019-08-27 23:30:03
categories: java
tags:
  - log4j
---

## DEBUG 模式运行

`log4j`的配置文件中配置`log4j.debug=true`即可开启

## 概述

`log4j`的`looger`是层级结构的，例如`com.li`是`com.li.springboot`的父类`logger`  
可使用如下方式取出`logger`

```java
package com.li.springboot.advice.log4j;


import org.apache.log4j.Logger;

public class LevelTest {
    Logger logger= Logger.getLogger(LevelTest.class);
    Logger logger= Logger.getLogger("com.li.springboot.advice.log4j.LevelTest");
}

```

`getLogger`根据参数`name`，在任意处取出的`logger`都是同一个
`root logger`是所有`logger`的父类，一定存在但是它不能直接使用`getLogger`通过`name`取出。可使用如下方式取出

```java
Logger.getRootLogger()
```

可使用的日志级别`org.apache.log4j.Level`

> `TRACE`,`DEBUG`,`INFO`,`WARN`,`ERROR` and `FATAL`

当指定`name`的`logger`日志请求时，同时会将该请求转发至父类`logger`
当`logger`没有对应的配置时，会找最近的父类配置，默认情况下`logger`配置会继承父类的配置，可通过设置`log4j.additivity.xxx=false`使其不继承(xxx 是 logger 的 name)

## 配置

1. 初始化 Logger 容器 Hierarchy,设置根节点为 RootLogger

2. 初始 LoggerRepositorySelector(容器选择器)为默认的 DefaultRepositorySelector,容器为 Hierarchy

3. 读取系统属性 log4j.defaultInitOverride,如果没有设置或者为 false 进行初始化,否则跳过初始化

4. 读取系统属性 log4j.configuration(log4j 文件路径配置),如果存在对应的文件,则得到 URL.如果没有对应的文件,首先检查是否存在 log4j.xml 文件,如果存在,得到 Log4j 配置文件 URL,如果不存在 log4j.xml,继续检查是否存在 log4j.properties 文件,如果存在该文件,得到 log4j 配置文件的 URL,否则提示没有发现配置文件。

5. 读取系统属性 log4j.configuratorClass(自定义 Configurator 配置类全路径,一般不自定义)

6. 调用 OptionConverter.selectAndConfigure(url, configuratorClassName,LogManager.getLoggerRepository()),初始化 logger 容器

### 扩展配置

可使用`BasicConfigurator.resetConfiguration()`重置配置
可使用`PropertyConfigurator.configure`指定其他配置文件

### `tomcat`下的`log4j`

当`log4j`的`jar`包在`tomcat`目录下的时候，使用`BasicConfigurator.resetConfiguration()`重置配置时，会修改`tomcat`下所有应用的日志打印，一般情况下
我们在主应用里做配置，忽略其他应用的配置即可。但是当你发布其他应用时，触发`log4j`的初始化配置，则会影响到主应用，可能造成主应用日志不打印。这个时候我们通过`HierarchyEventListener`来监听`log4j`的配置是否被修改，来在其他应用重置配置时，重新触发主应用的配置加载过程即可。

```java
static {
    Logger.getRootLogger().getLoggerRepository().addHierarchyEventListener(new HierarchyEventListener() {
        @Override
        public void addAppenderEvent(Category cat, Appender appender) {
            LogLog.debug("add " + cat.getName() + "  " + appender);
            flag = false;
        }
        @Override
        public void removeAppenderEvent(Category cat, Appender appender) {
            //log4j配置被移除前的回调，此时配置还是生效的，所以这里重新加载是无效的，回调后就
            //被重置了，所以需要在外面去重新加载，这里仅打一个标记
            LogLog.debug("remove " + cat.getName() + "  " + appender);
            flag = true;
        }
    });
}

public static void initLog4j() {
    BasicConfigurator.resetConfiguration();
    Properties properties = new Properties();
    try {
        properties.load(ClassLoader.getSystemResourceAsStream("mylog4j.properties"));
    } catch (IOException e) {
        e.printStackTrace();
    }
    PropertyConfigurator.configure(properties);
}

for (int i = 0; i < cycle; i++) {
    Thread.sleep(RandomUtils.nextInt(500, 1500));
        if (flag) {
            initLog4j();
        }
    logger.debug("123");
}
```

### `MDC`

打造日志链路，`MDC`类似`ThreadLocal`类，根据线程存入一些数据，以供打印日志的时候输出(`%X{name}`)

```java
MDC.clear();
MDC.put("session", "xxxx");

```

```properties
log4j.appender.consoleAppender.layout.ConversionPattern= %X{session} %m%n
```
