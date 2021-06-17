---
title: log4j
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
    //配置logger时，已有的同名Category会被remove掉，即可以触发removeAppenderEvent事件
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

## 问题

### 日志输出问题

应用中需要将多个`logger`的日志输出到同一个文件中，且需要根据时间每天自动分割文件。我们使用`DailyRollingFileAppender`
配置如下

```properties
# 开启log4j的日志
log4j.debug=true
log4j.rootLogger=error, stdout
log4j.logger.l1=DEBUG, fuck1
log4j.logger.l2=DEBUG, fuck2

#l1
log4j.appender.fuck1=org.apache.log4j.DailyRollingFileAppender
log4j.appender.fuck1.DatePattern='.'-yyyy-MM-dd-HH-mm
log4j.appender.fuck1.layout=org.apache.log4j.PatternLayout
log4j.appender.fuck1.File=/Users/li/Downloads/log4j/log4j.log
log4j.appender.fuck1.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss} %-5p %c{1}:%L - %m%n

#l2
log4j.appender.fuck2=org.apache.log4j.DailyRollingFileAppender
log4j.appender.fuck2.DatePattern='.'-yyyy-MM-dd-HH-mm
log4j.appender.fuck2.layout=org.apache.log4j.PatternLayout
log4j.appender.fuck2.File=/Users/li/Downloads/log4j/log4j.log
log4j.appender.fuck2.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss} %-5p %c{1}:%L - %m%n

```

测试代码我使用`Spring`的`Scheduled`

```java
package com.li.springboot.util;

import org.apache.log4j.Logger;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class ScheduledTask {

    Logger logger = Logger.getLogger("l1");
    Logger logger2 = Logger.getLogger("l2");
    private int index = 0;

    @Scheduled(cron = "*/1 * * * * *")
    public void log() {
        logger.info("--------------------" + index++);
        logger2.debug("--------------------" + index++);
    }

}

```

`*/1 * * * * *`表示每秒执行一次

`log4j.appender.fuck1.DatePattern='.'-yyyy-MM-dd-HH-mm`表示每分钟分割一次文件

在执行定时任务到底切割点时，我们可以观察到日志输出

`log4j`自身的日志一定输出在`System.out`中

```log
2019-09-05 21:16:59 DEBUG l2:22 - --------------------44
log4j: /Users/li/Downloads/log4j/log4j.log -> /Users/li/Downloads/log4j/log4j.log.-2019-09-05-21-16
log4j: setFile called: /Users/li/Downloads/log4j/log4j.log, true
log4j: setFile ended
2019-09-05 21:17:00 INFO  l1:21 - --------------------45
log4j: /Users/li/Downloads/log4j/log4j.log -> /Users/li/Downloads/log4j/log4j.log.-2019-09-05-21-16
log4j: setFile called: /Users/li/Downloads/log4j/log4j.log, true
log4j: setFile ended
2019-09-05 21:17:00 DEBUG l2:22 - --------------------46
```

我们观察下源码分析下这个过程

```java
  protected void subAppend(LoggingEvent event) {
    long n = System.currentTimeMillis();
    //检测当前时间点是否需要分割文件
    if (n >= nextCheck) {
      now.setTime(n);
      nextCheck = rc.getNextCheckMillis(now);
      try {
        rollOver();
      }
      catch(IOException ioe) {
          if (ioe instanceof InterruptedIOException) {
              Thread.currentThread().interrupt();
          }
        LogLog.error("rollOver() failed.", ioe);
      }
    }
    super.subAppend(event);
   }
}

void rollOver() throws IOException {

    /* Compute filename, but only if datePattern is specified */
    if (datePattern == null) {
      errorHandler.error("Missing DatePattern option in rollOver().");
      return;
    }

    String datedFilename = fileName+sdf.format(now);
    // It is too early to roll over because we are still within the
    // bounds of the current interval. Rollover will occur once the
    // next interval is reached.
    if (scheduledFilename.equals(datedFilename)) {
      return;
    }

    // close current file, and rename it to datedFilename
    this.closeFile();
    //如果存在其他分割后的文件，则删除
    File target  = new File(scheduledFilename);
    if (target.exists()) {
      target.delete();
    }

    File file = new File(fileName);
    //将当前日志文件改名为代日期的文件
    boolean result = file.renameTo(target);
    if(result) {
      LogLog.debug(fileName +" -> "+ scheduledFilename);
    } else {
      LogLog.error("Failed to rename ["+fileName+"] to ["+scheduledFilename+"].");
    }

    try {
      // This will also close the file. This is OK since multiple
      // close operations are safe.
      //将log4j日志的输出重定向为不带日期的文件
      this.setFile(fileName, true, this.bufferedIO, this.bufferSize);
    }
    catch(IOException e) {
      errorHandler.error("setFile("+fileName+", true) call failed.");
    }
    scheduledFilename = datedFilename;
  }

```

1. `logger`的日志在`logger2`之前，因此先触发`rollOver`,此时没有文件`log4j.log.-2019-09-05-21-16`,将`log4j.log`重命名为`log4j.log.-2019-09-05-21-16`,并将`logger`的日志流重定向为`log4j.log`

2. 紧接着`logger2`的日志流触发`rollOver`,此时会将`log4j.log.-2019-09-05-21-16`删除，同时将`log4j.log`重命名为`log4j.log.-2019-09-05-21-16`，并将`logger2`的日志流重定向为`log4j.log`。此时`logger`的日志流就的文件名被改名了。

3. 我们可以看出第一轮的日志被`logger2`触发的`rollOver`删除了，而`logger`的日志流输出到`上一轮`

### 解决方案

根据分析，我们确保`target.delete()`和`ile.renameTo(target)`只被执行一次，且其他`logger`在指定时间重新将日志流指向到最新的`log4j.log`即可。

比如说简单的重写`DailyRollingFileAppender`,在`rollOver`代码处稍作修改

```java
this.closeFile();

//此处必须得停止一会，确保所有线程都没有连接到日志文件
try{
  Thread.sleep(3000);
}catch(Exception e){

}
File target = new File(scheduledFilename);
//当目标文件已经存在时，就说明已经被切割过了，则简单重定向即可
if (!target.exists()) {
    File file = new File(fileName);
    boolean result = file.renameTo(target);
    if (result) {
        LogLog.debug(fileName + " -> " + scheduledFilename);
    } else {
        LogLog.error("Failed to rename [" + fileName + "] to [" + scheduledFilename + "].");
    }
}
try {
        this.setFile(fileName, true, this.bufferedIO, this.bufferSize);
    } catch (IOException e) {
        errorHandler.error("setFile(" + fileName + ", true) call failed.");
}
    scheduledFilename = datedFilename;
```
