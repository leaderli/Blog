---
title: springboot-jpa
date: 2019-07-30 21:50:50
categories: spring
tags:
  - springboot
  - jpa
  - mysql
---

## 版本说明

`jdk`:1.8.0_131
`springboot`:2.1.6.RELEAS
`maven`:3.6.1
`database`:mysql-5.7.14
`lombok插件`

## 概述

项目基于 maven，pom 配置如下

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.1.6.RELEASE</version>
    <relativePath/> <!-- lookup parent from repository -->
  </parent>
  <groupId>com.li</groupId>
  <artifactId>springboot</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <name>springboot</name>
  <description>Demo project for Spring Boot</description>

  <properties>
    <java.version>1.8</java.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-jdbc</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
      <groupId>com.github.ulisesbocchio</groupId>
      <artifactId>jasypt-spring-boot</artifactId>
      <version>2.1.1</version>
    </dependency>
    <dependency>
      <groupId>log4j</groupId>
      <artifactId>log4j</artifactId>
      <version>1.2.17</version>
    </dependency>
    <dependency>
      <groupId>org.projectlombok</groupId>
      <artifactId>lombok</artifactId>
      <optional>true</optional>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
    </dependency>
    <dependency>
      <groupId>mysql</groupId>
      <artifactId>mysql-connector-java</artifactId>
    </dependency>
    <dependency>
      <groupId>javax.inject</groupId>
      <artifactId>javax.inject</artifactId>
      <version>1</version>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>org.aspectj</groupId>
      <artifactId>aspectjweaver</artifactId>
      <version>1.9.4</version>
    </dependency>
    <dependency>
      <groupId>org.apache.commons</groupId>
      <artifactId>commons-lang3</artifactId>
    </dependency>
    <dependency>
      <groupId>com.google.code.gson</groupId>
      <artifactId>gson</artifactId>
      <version>2.8.5</version>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
      <plugin>
        <artifactId>maven-clean-plugin</artifactId>
        <version>3.1.0</version>
      </plugin>
    </plugins>
  </build>

</project>
```

部分代码使用`lombok`进行简化

表实体类

```java
package com.li.springboot.bean;

import lombok.Data;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;

@Proxy(lazy = false)
@Entity(name = "log")
@Data
public class Log {
    @Id
    private String id;
    private String log;
    private String time;
    @Column(name = "user_id")
    private String userID;
}
```

`@Id`表示主键
`@Entity`标记当前类为一个表，若指定属性`name`，则实际表名使用`name`的值，否则使用类名。
`@Column`中的`name`同样也是指定表的字段名。

表操作类

```java
package com.li.springboot.dao;

import com.li.springboot.bean.Log;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LogDao extends JpaRepository<Log, String> {
}

```

```java
package com.li.springboot.controller;

import com.li.springboot.bean.Log;
import com.li.springboot.dao.LogDao;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class LogController {
  @Autowired
  LogDao logDao;

  @RequestMapping("/{id}")
  public Log log(@PathVariable String id) {
    return logDao.getOne(id);
  }
}
```

`JpaRepository`的泛型，分别指定表实体类和表主键,`JpaRepository`包含常用的数据库操作，`LogDao`可直接使用。

数据库连接信息配置

```yml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/app
    username: root
    password: "{cipher}cm9vdA"
    driver-class-name: com.mysql.cj.jdbc.Driver
  jpa:
    show-sql: true
logging:
  level:
    root: error
    com:
      li: debug
```

其他，略

测试

```java
package com.li.springboot.controller;

import com.google.gson.Gson;
import com.li.springboot.bean.Log;
import lombok.extern.slf4j.Slf4j;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Slf4j
public class LogControllerTest {
    @Autowired
    MockMvc mockMvc;

    @Test
    public void test() throws Exception {
        mockMvc.perform(get("/1")).andDo(print()).andExpect(result -> {
            Log log = new Gson().fromJson(result.getResponse().getContentAsString(), Log.class);
            assert log !=null;
        });
    }

}
```
