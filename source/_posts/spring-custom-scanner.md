---
title: SpringBoot自定义扫描器
date: 2019-08-18 22:53:36
categories: spring
tags:
  - scanner
  - 自定义扫描器
---

实现自定义注解扫描器，将被`JsonBean`注解的类，注入到`spring`容器中，当由`spring`生成时，自动根据对应的`json`文件自动生成。

首先是两个注解

```java

import java.lang.annotation.*;

@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface JsonBean {
    String value();
}



import com.li.ivr.test.scanner.JsonBeanRegistrar;
import org.springframework.context.annotation.Import;

import java.lang.annotation.*;

@Target( ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Import(JsonBeanRegistrar.class)
public @interface JsonBeanScanner {
    String value();
}

```

被注解类

```java
package com.li.ivr.test.expression;


import com.li.ivr.test.annotation.JsonBean;

import java.util.Map;

@JsonBean("/data.json")
public class Session {

    private Map<String,?> avaya;

    public Map<String, ?> getAvaya() {
        return avaya;
    }

    public void setAvaya(Map<String, ?> avaya) {
        this.avaya = avaya;
    }

    @Override
    public String toString() {
        return "Session{" +
            "avaya=" + avaya +
            '}';
    }
}

```

核心代码,即`JsonBeanScanner`中`import`的类`JsonBeanRegistrar`

```java
package com.li.ivr.test.scanner;

import com.li.ivr.test.advise.ProxyFactoryBean;
import com.li.ivr.test.annotation.JsonBean;
import com.li.ivr.test.annotation.JsonBeanScanner;
import org.springframework.beans.factory.support.BeanDefinitionRegistry;
import org.springframework.context.annotation.ClassPathScanningCandidateComponentProvider;
import org.springframework.context.annotation.ImportBeanDefinitionRegistrar;
import org.springframework.core.type.AnnotationMetadata;
import org.springframework.core.type.filter.AnnotationTypeFilter;

import java.util.Objects;

public class JsonBeanRegistrar implements ImportBeanDefinitionRegistrar {
    @Override
    public void registerBeanDefinitions(AnnotationMetadata importingClassMetadata, BeanDefinitionRegistry registry) {
        String path =
            (String) Objects.requireNonNull(importingClassMetadata.getAnnotationAttributes(JsonBeanScanner.class.getName())).get(
                "value");
        createComponentScanner().findCandidateComponents(path).forEach(beanDefinition -> {
            beanDefinition.getConstructorArgumentValues().addGenericArgumentValue(Objects.requireNonNull(beanDefinition.getBeanClassName()));
            beanDefinition.setBeanClassName(ProxyFactoryBean.class.getName());
            registry.registerBeanDefinition(Objects.requireNonNull(beanDefinition.getBeanClassName()), beanDefinition);
        });

    }

    private ClassPathScanningCandidateComponentProvider createComponentScanner() {
        // Don't pull default filters (@Component, etc.):
        ClassPathScanningCandidateComponentProvider provider
            = new ClassPathScanningCandidateComponentProvider(false);
        provider.addIncludeFilter(new AnnotationTypeFilter(JsonBean.class));
        return provider;
    }
}

```

其中`ProxyFactoryBean`为生成`bean`的工厂类，代码如下

```java
package com.li.ivr.test.advise;

import com.google.gson.Gson;
import com.li.ivr.test.annotation.JsonBean;
import org.springframework.beans.factory.FactoryBean;
import org.springframework.util.StreamUtils;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

public class ProxyFactoryBean<T> implements FactoryBean {
    private Class<T> interfaceClass;

    public ProxyFactoryBean(Class<T> interfaceClass) {
        this.interfaceClass = interfaceClass;
    }

    @Override
    public T getObject() throws IOException {
        JsonBean annotation = interfaceClass.getAnnotation(JsonBean.class);
        InputStream in = ProxyFactoryBean.class.getResourceAsStream(annotation.value());
        String json = StreamUtils.copyToString(in, StandardCharsets.UTF_8);
        return new Gson().fromJson(json, interfaceClass);
    }

    @Override
    public Class<?> getObjectType() {
        return interfaceClass;
    }
}
```

我们在任意配置类中设置扫描路径即可

```java
@@Configuration
@JsonBeanScanner("com.li")
public class Application {
}
```
