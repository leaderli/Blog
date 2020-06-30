---
title: log4j日志问题
date: 2019-09-05 21:21:29
categories: java
tags:
  - log4j
---

## 问题描述

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

## 解决方案

根据分析，我们确保`target.delete()`和`ile.renameTo(target)`只被执行一次，且其他`logger`在指定时间重新将日志流指向到最新的`log4j.log`即可。

比如说简单的重写`DailyRollingFileAppender`,在`rollOver`代码处稍作修改

```java
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
