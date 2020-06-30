---
title: springboot数据库密码加密
date: 2019-07-19 10:50:31
categories: spring
tags:
  - springboot
  - datasource
  - 加密
---

## 方案一

`SpringBoot`在配置文件`application`中配置的关于数据库连接信息,在实际使用时是转换为`DataSource`类，那么只要将`SpringBoot`实现的`DataSource`继承类中，
将实际密文解密即可。通过查看源码可得知，`SpringBoot`中`DataSource`实现类为`HikariDataSource`,那么我们通过`BeanPostProcessor`在实例化`HikariDataSource`时,
替换密文即可。代码如下

```yml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/app
    username: root
    password: cm9vdA==
    driver-class-name: com.mysql.jdbc.Driver
```

```java
  @Bean
  public static BeanPostProcessor beanPostProcessor() {
    return new BeanPostProcessor() {
      @Override
      public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        if (bean instanceof HikariDataSource) {
          HikariDataSource hikariDataSource = (HikariDataSource) bean;
          hikariDataSource.setPassword(new String(Base64Utils.decode(hikariDataSource.getPassword().getBytes())));
        }
        return null;
      }
    };
  }
```

## 方案二

使用 jasypt

```xml
<dependency>
    <groupId>com.github.ulisesbocchio</groupId>
    <artifactId>jasypt-spring-boot-starter</artifactId>
    <version>2.1.1</version>
</dependency>
```

开启

```java
@EnableEncryptableProperties
public class SpringbootApplication {
}
```

自定义处理器解密处理器

```yml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/app
    username: root
    password: "{cipher}cm9vdA"
    driver-class-name: com.mysql.cj.jdbc.Driver
```

```java

  public static final String ENCODED_PASSWORD_HINT = "{cipher}";

  @Bean
  public static EncryptablePropertyDetector encryptablePropertyDetector() {
    return new EncryptablePropertyDetector() {

      @Override
      public boolean isEncrypted(String s) {
        if (null != s) {
          return s.startsWith(ENCODED_PASSWORD_HINT);
        }
        return false;
      }

      @Override
      public String unwrapEncryptedValue(String s) {
        return s.substring(ENCODED_PASSWORD_HINT.length());
      }
    };
  }

  @Bean
  public static EncryptablePropertyResolver encryptablePropertyResolver() {
    return new EncryptablePropertyResolver() {
      @Override
      public String resolvePropertyValue(String s) {
        if (null != s && s.startsWith(ENCODED_PASSWORD_HINT)) {
          return new String(Base64Utils.decode(s.substring(ENCODED_PASSWORD_HINT.length()).getBytes()));
        }
        return s;
      }
    };
  }
```

## 方案三

根据方案二的实现原理，使用`BeanFactoryPostProcessor`实现一个自动解密配置文件的处理器

```yml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/app
    username: root
    password: "{cipher}cm9vdA"
    driver-class-name: com.mysql.cj.jdbc.Driver
```

```java
 @Bean
  public static EncryptationAwarePropertyPlaceholderConfigurer enableEncryptablePropertySourcesPostProcessor(ConfigurableEnvironment environment) {
    return new DecodeBeanFactoryPostProcessor(environment);
  }
```

```java
public class DecodeBeanFactoryPostProcessor implements BeanFactoryPostProcessor {


  private ConfigurableEnvironment environment;

  public DecodeBeanFactoryPostProcessor(ConfigurableEnvironment environment) {
    this.environment = environment;
  }


  @Override
  public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {
    MutablePropertySources propertySources = environment.getPropertySources();
    StreamSupport.stream(propertySources.spliterator(), false).forEach(ps -> {
      //示例代码，仅仅处理application.yml相关的解码操作
      if (ps.getName().equals("applicationConfig: [classpath:/application.yml]")) {
        Map<Object, Object> source = (Map) ps.getSource();
        source.keySet().forEach(k -> {
          Object value = source.computeIfPresent(k, (key, v) -> {
            String cipher = v.toString();
            if (cipher.startsWith("{cipher}")) {
              return new String(Base64Utils.decode(cipher.substring("{cipher}".length()).getBytes()));
            }
            return v;
          });
        });
      }
    });
  }

```

其中需要注意的是，`DecodeBeanFactoryPostProcessor`的实例化需要在`ApplicationContext`加载成功后再去实例化，确保`ConfigurableEnvironment`已被正确初始化
