---
title: spring tips
date: 2019-07-10 13:49:36
categories: spring
tags:
  - spring
  - tips
---

### spring bean 多个 id

```java
@Service("Service-A")
public class SampleService {
    public String doSomething() { return "Foo"; }
}

@Configuration
public class SampleConfig {

    @Bean(name = {"Service-B", "Service-C"})
    public SampleService createMirroredService(@Autowired SampleService service) {
        return service;
    }
}
```

### 作用域代理——proxyMode 属性

将一个短生命周期作用域 bean 注入给长生命周期作用域 bean，我们期望长生命周期 bean 的属性保持与短生命周期 bean 同样。例如

```java
@Component
@Scope(value = BeanDefinition.SCOPE_PROTOTYPE,proxyMode = ScopedProxyMode.TARGET_CLASS)
public class Prototype {
}

@Component
@Scope(BeanDefinition.SCOPE_SINGLETON)
public class Singleton {
  @Autowired
  private Prototype prototype;
}
```

保证每次`prototype`都是最新的，需要在`Prototype`类上定义`proxyMode`

### 延迟加载 bean

```java
//...
import javax.inject.Inject;
import javax.inject.Provider;

public class InjectTest{

    @Inject
    Provider<InjectBean> provider;

    public void test() {
      InjectBean bean =  provider.get();
    }

}
```

使用`@Autowire`也是可以的，重要是使用了`Provider`

### 基于注解的切面

```java
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.stereotype.Component;

@Aspect
@Component
public class AnnotationAspect {

  @Around("@annotation(Log)")
  public void log1(ProceedingJoinPoint point){
    MethodSignature  s = (MethodSignature) point.getSignature();
    Log annotation = s.getMethod().getAnnotation(Log.class);
  }
}
```

所有注解了`@Log`的方法都会被切

### `Spring`注入文件

```java
 import org.springframework.core.io.Resource;

 @Value("classpath:rootxml.js")
 private Resource cert;

 @Test
 public void test() throws ScriptException, IOException {
    System.out.println(StreamUtils.copyToString(cert.getInputStream(), StandardCharsets.UTF_8));
 }
```

### @Autowired

`@Autowired(required = false)`若`Spring`容器中没有对应的`BeanDefinition`时不会注入值，可赋值一个默认值避免空指针的情况。

### 定时任务

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
