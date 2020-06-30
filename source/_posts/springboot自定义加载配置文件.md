---
title: springboot自定义加载配置文件
date: 2019-12-27 00:42:52
categories: spring
tags:
  - properties
  - yml
---

## 实现

`springboot`提供了注解`@PropertySource`来实现加载配置文件。
一个普通的注解配置,也可注解在其他`@Configuration`类上

```java
@SpringBootApplication
@PropertySource(factory = YamlPropertySourceFactory.class, value = "classpath:application.yml")
public class Application {
}
```

`PropertySource`和`PropertySourceFactory`的源码

```java

package org.springframework.context.annotation;

public @interface PropertySource {
    String name() default "";
    String[] value();
    boolean ignoreResourceNotFound() default false;
    String encoding() default "";
    Class<? extends PropertySourceFactory> factory() default PropertySourceFactory.class;

}

public interface PropertySourceFactory {
    PropertySource<?> createPropertySource(@Nullable String name, EncodedResource resource) throws IOException;
}
```

`PropertySource`的`factory`来表示使用何种`PropertySourceFactory`来实现加载过程，`value`指向的文件会被`spring`加载为`EncodedResource`实例以供`PropertySourceFactory`使用

`value`的值需要为有效资源，若我们需要加载绝对路径的资源文件，我们无视`value`的资源，仅加载自己所需要加载的配置文件。
首先我们了解下如何加载`yaml`配置

`custom.yml`配置文件,路径为`/Users/li/java/workspace/branches/src/main/resources/custom.yml`

```yml
foo: 1
```

我们可以使用`FileSystemResource`加载文件资源

```java
package com.leaderli.branches.utils;

import org.springframework.beans.factory.config.YamlPropertiesFactoryBean;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.support.EncodedResource;

import java.io.File;
import java.util.Properties;

public class ConfigUtil {
    public static Properties loadYamlIntoProperties(String yml) {

        EncodedResource resource = new EncodedResource(new FileSystemResource(new File(yml)));
        YamlPropertiesFactoryBean factory = new YamlPropertiesFactoryBean();
        factory.setResources(resource.getResource());
        factory.afterPropertiesSet();
        return factory.getObject();
    }
}

```

测试程序

```java
package com.leaderli.branches.config;

import com.leaderli.branches.utils.ConfigUtil;
import org.junit.jupiter.api.Test;

import java.util.Properties;

class YamlPropertySourceFactoryTest {
    @Test
    public void test() {
        String yml = "/Users/li/java/workspace/branches/src/main/resources/custom.yml";
        Properties properties = ConfigUtil.loadYamlIntoProperties(yml);
        assert  (int)properties.get("foo") == 1;
    }
}
```

接下来只需要实现`PropertySourceFactory`接口即可

```java
package com.leaderli.branches.config;

import com.leaderli.branches.utils.ConfigUtil;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.core.env.PropertiesPropertySource;
import org.springframework.core.env.PropertySource;
import org.springframework.core.io.support.EncodedResource;
import org.springframework.core.io.support.PropertySourceFactory;

import java.io.IOException;
import java.util.Properties;

public class YamlPropertySourceFactory implements PropertySourceFactory {
    private static final Log LOGGER = LogFactory.getLog(YamlPropertySourceFactory.class);


    @Override
    public PropertySource<?> createPropertySource(String name, EncodedResource resource) throws IOException {
        Properties propertiesFromYaml = ConfigUtil.loadYamlIntoProperties("/Users/li/java/workspace/branches/src/main/resources/custom.yml");
        String sourceName = name != null ? name : resource.getResource().getFilename();
        LOGGER.debug("resouce:" + resource);
        return new PropertiesPropertySource(sourceName, propertiesFromYaml);
    }

}

```
