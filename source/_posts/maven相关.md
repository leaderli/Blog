---
title: maven相关
date: 2019-07-09 23:01:19
categories: tips
tags:
  - maven
  - idea
---

### idea 中无法直接下载源代码

可在项目目录下手动执行命令下载

```bash
mvn dependency:resolve -Dclassifier=sources
```

### maven 父类 pom

定义父类`pom`

```xml
<groupId>com.li</groupId>
  <artifactId>springboot</artifactId>
  <version>1.0</version>
  <name>springboot</name>
  <packaging>pom</packaging>
```

执行`install`或`depoly`发布到仓库中

其他项目引用

```xml
 <parent>
    <groupId>com.li</groupId>
    <artifactId>springboot</artifactId>
    <version>1.0</version>
    <relativePath/>
  </parent>
```

### eclipse 中 maven 项目不自动编译

执行`clean`，再`compile`即可。

### 跳过测试

```shell
mvn package -DskipTests=true
```
