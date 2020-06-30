---
title: spring配置类加载yaml配置项的模拟实现
date: 2020-03-16 14:27:04
categories: spring
tags:
  - spring
  - yaml
---

核心思路就是自定义一个注解用以`Spring`启动过程中，将其手动注入到`Spring`容器中，并干预该类的实例化过程

```java
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface YamlBean {
    String value();
}

```

```java
import org.springframework.beans.factory.support.BeanDefinitionRegistry;
import org.springframework.context.annotation.ClassPathScanningCandidateComponentProvider;
import org.springframework.context.annotation.ImportBeanDefinitionRegistrar;
import org.springframework.core.type.AnnotationMetadata;
import org.springframework.core.type.filter.AnnotationTypeFilter;

import java.util.Objects;

public class YamlBeanRegistrar implements ImportBeanDefinitionRegistrar {
    public void registerBeanDefinitions(AnnotationMetadata importingClassMetadata, BeanDefinitionRegistry registry) {
        createComponentScanner().findCandidateComponents("com.leaderli.yaml").forEach(beanDefinition -> {
            System.out.println("beanDefinition = " + beanDefinition);
            beanDefinition.getConstructorArgumentValues().addGenericArgumentValue(Objects.requireNonNull(beanDefinition.getBeanClassName()));
            beanDefinition.setBeanClassName(ProxyFactoryBean.class.getName()); //指定该类的生成工厂类
            registry.registerBeanDefinition(Objects.requireNonNull(beanDefinition.getBeanClassName()), beanDefinition);
        });

    }

    private ClassPathScanningCandidateComponentProvider createComponentScanner() {
        // 扫描YamlBean注解的类
        ClassPathScanningCandidateComponentProvider provider
                = new ClassPathScanningCandidateComponentProvider(false);
        provider.addIncludeFilter(new AnnotationTypeFilter(YamlBean.class));
        return provider;
    }
}
```

```java

import org.springframework.beans.factory.FactoryBean;
import org.yaml.snakeyaml.Yaml;

import java.io.IOException;
import java.io.InputStream;
import java.util.Map;

public class ProxyFactoryBean<T> implements FactoryBean<T> {
    private Class<T> interfaceClass;

    public ProxyFactoryBean(Class<T> interfaceClass) {
        this.interfaceClass = interfaceClass;
    }

    public T getObject() throws IOException {
        YamlBean annotation = interfaceClass.getAnnotation(YamlBean.class);

        InputStream inputStream = ClassLoader.getSystemResourceAsStream("bean.yml");
        Yaml yaml = new Yaml();
        Map<String,Object> load = yaml.load(inputStream);

        String prefix = annotation.value();
        System.out.println("prefix = " + prefix);

        for (String key : prefix.split("\\.")) {
            load= (Map<String, Object>) load.get(key);
            System.out.println("load = " + load);

        }
        yaml = new Yaml();
        String dump = yaml.dump(load);
        System.out.println("dump = " + dump);

        T bean = yaml.loadAs(dump, interfaceClass);
        System.out.println("bean = " + bean);
        return bean;


    }

    public Class<?> getObjectType() {
        return interfaceClass;
    }

    public boolean isSingleton() {
        return false;
    }
}


```

在`Spring`的配置类将扫描器导入

```java
@Configuration
@Import(YamlBeanRegistrar.class)
public class SpringConfig {
}

```
