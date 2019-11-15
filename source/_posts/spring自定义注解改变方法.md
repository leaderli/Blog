---
title: spring自定义注解改变方法
date: 2019-08-09 00:16:36
categories: spring
tags:
- spring
- 自定义注解
---

## 版本说明

`jdk`:1.8.0_131  
`springboot`:2.1.6.RELEAS  
`maven`:3.6.1  
`lombok插件`  

## 概述

仅仅示范简单用法不涉及源码介绍，仅仅是一些实现方式，不一定是最优实现方式。这里仅仅只做打印参数，不做其他特殊操作，
可以根据需要，可以实现的包括异步调用，远程调用，缓存等等。

标记注解类

```java
import org.slf4j.event.Level;

import java.lang.annotation.*;

@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface LogAnnotation {
    Level value() default Level.DEBUG;
}
```

被注解bean

```java

import org.slf4j.event.Level;
import org.springframework.stereotype.Component;

@Component
public class LogBean {
    @LogAnnotation
    public void debug() {

    }

    @LogAnnotation(Level.ERROR)
    public void error() {

    }

    public void normal(){

    }
}
```

## 方案一

使用`BeanPostProcessor`，扫描方法或类是否有`LogAnnotation`注解，如果有，则替换bean为代理类。

```java
import lombok.extern.slf4j.Slf4j;
import org.slf4j.event.Level;
import org.springframework.aop.support.AopUtils;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.cglib.proxy.Enhancer;
import org.springframework.cglib.proxy.MethodInterceptor;
import org.springframework.core.annotation.AnnotatedElementUtils;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.Arrays;

@Component
@Order(Integer.MAX_VALUE)
@Slf4j
public class LogBeanPostProcessor implements BeanPostProcessor {
    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {

    Class<?> targetClass = AopUtils.getTargetClass(bean);
    //判断类是否有注解LogAnnotation
    if (AnnotatedElementUtils.findMergedAnnotation(targetClass, LogAnnotation.class) != null || Arrays.stream(targetClass.getMethods()).anyMatch(method -> AnnotatedElementUtils.findMergedAnnotation(method, LogAnnotation.class) != null)) {
        Enhancer enhancer = new Enhancer();
        enhancer.setSuperclass(targetClass);
        //注册切面方法
        enhancer.setCallback((MethodInterceptor) (o, method, args, methodProxy) -> {
            LogAnnotation annotation = AnnotatedElementUtils.findMergedAnnotation(targetClass, LogAnnotation.class);
            if (annotation == null) {
                annotation = AnnotatedElementUtils.findMergedAnnotation(method, LogAnnotation.class);
            }
            if (annotation == null) {
                return method.invoke(bean, args);
            }
            //包含有注解的方法，或者类上有注解的方法，打印日志
            Level level = annotation.value();
            if (log.isDebugEnabled()) {
                log.debug("[" + level + "]" + method.getName() + " " + Arrays.toString(args));
            } else if (log.isErrorEnabled()) {
                log.debug("[" + level + "]" + method.getName() + " " + Arrays.toString(args));
            }
            return method.invoke(bean, args);
        });
        //生成代理类
        return enhancer.create();
    }
    return bean;
}
}

```

## 方案二

使用`spring`提供的切面功能，针对被注解的类进行切面

```java
package com.li.springboot.other;

import com.li.springboot.advice.MyPointcutAdvisor;
import lombok.extern.slf4j.Slf4j;
import org.aopalliance.aop.Advice;
import org.aopalliance.intercept.MethodInterceptor;
import org.slf4j.event.Level;
import org.springframework.aop.Pointcut;
import org.springframework.aop.framework.AbstractAdvisingBeanPostProcessor;
import org.springframework.aop.support.AbstractPointcutAdvisor;
import org.springframework.aop.support.AopUtils;
import org.springframework.aop.support.ComposablePointcut;
import org.springframework.aop.support.annotation.AnnotationMatchingPointcut;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.BeanFactory;
import org.springframework.beans.factory.BeanFactoryAware;
import org.springframework.core.BridgeMethodResolver;
import org.springframework.core.annotation.AnnotatedElementUtils;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.util.ClassUtils;

import java.lang.reflect.Method;
import java.util.Arrays;

@Component
@Order(Integer.MAX_VALUE)
@Slf4j
public class LogBeanAdvisingBeanPostProcessor extends AbstractAdvisingBeanPostProcessor implements BeanFactoryAware {
    @Override
    public void setBeanFactory(BeanFactory beanFactory) throws BeansException {
        setBeforeExistingAdvisors(true);
        MyPointcutAdvisor advisor = new MyPointcutAdvisor();
        this.advisor = new AbstractPointcutAdvisor() {
            @Override
            public Advice getAdvice() {
                return (MethodInterceptor) invocation -> {
                    //获取目标类
                    Class<?> targetClass = (invocation.getThis() != null ? AopUtils.getTargetClass(invocation.getThis()) : null);
                    //获取指定方法
                    Method specificMethod = ClassUtils.getMostSpecificMethod(invocation.getMethod(), targetClass);
                    //获取真正执行的方法,可能存在桥接方法
                    final Method userDeclaredMethod = BridgeMethodResolver.findBridgedMethod(specificMethod);
                    //获取方法上注解
                    LogAnnotation annotation = AnnotatedElementUtils.findMergedAnnotation(userDeclaredMethod,
                        LogAnnotation.class);
                    if (annotation == null) {
                        annotation = AnnotatedElementUtils.findMergedAnnotation(targetClass, LogAnnotation.class);
                    }
                    //包含注解则打印参数
                    if (annotation != null) {
                        Level level = annotation.value();
                        if (log.isDebugEnabled()) {
                            log.debug("[" + level + "]" + specificMethod.getName() + " " + Arrays.toString(invocation.getArguments()));
                        } else if (log.isErrorEnabled()) {
                            log.debug("[" + level + "]" + specificMethod.getName() + " " + Arrays.toString(invocation.getArguments()));
                        }
                    }
                    //执行具体业务逻辑
                    return invocation.proceed();
                };
            }

            @Override
            public Pointcut getPointcut() {
                ComposablePointcut result = null;
                //类级别
                Pointcut cpc = new AnnotationMatchingPointcut(LogAnnotation.class, true);
                //方法级别
                Pointcut mpc = AnnotationMatchingPointcut.forMethodAnnotation(LogAnnotation.class);
                //对于类和方法上都可以添加注解的情况
                //类上的注解,最终会将注解绑定到每个方法上
                result = new ComposablePointcut(cpc);
                return result.union(mpc);
            }
        };
    }
}
```
