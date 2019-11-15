---
title: spring tips
date: 2019-07-10 13:49:36
categories: spring 
tags:
- spring
- tips
---

## spring bean 多个id

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

## 作用域代理——proxyMode属性

将一个短生命周期作用域bean注入给长生命周期作用域bean，我们期望长生命周期bean的属性保持与短生命周期bean同样。例如

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

## 延迟加载bean

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

## 基于注解的切面

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
