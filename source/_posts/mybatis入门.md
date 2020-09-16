---
title: mybatis入门
date: 2019-07-31 23:01:52
categories: java
tags:
  - mybatis
  - mysql
---

## 版本说明

`jdk`:1.8.0_131
`springboot`:2.1.6.RELEAS
`maven`:3.6.1
`database`:mysql-5.7.1
`mybatis`:3.5.2
`lombok插件`

## 概述

基于[官方文档](http://www.mybatis.org/mybatis-3/getting-started.html)的学习笔记。项目基于`maven`构建,项目主要介绍`mybatis`的使用，因此基本不使用`Spring`的相关代码

建表语句如下，建表语句来自[git-mybatis-3](https://github.com/mybatis/mybatis-3/tree/master/src/test/java/org/apache/ibatis/databases/blog)，针对`mysql`进行部分修改

```sql
-- create your own database

DROP TABLE IF EXISTS comment;
DROP TABLE IF EXISTS post_tag;
DROP TABLE IF EXISTS tag;
DROP TABLE IF EXISTS post;
DROP TABLE IF EXISTS blog;
DROP TABLE IF EXISTS author;
DROP TABLE IF EXISTS node;

CREATE TABLE author (
  id                INT PRIMARY KEY AUTO_INCREMENT,
  username          VARCHAR(255) NOT NULL,
  password          VARCHAR(255) NOT NULL,
  email             VARCHAR(255) NOT NULL,
  bio               BLOB,
  favourite_section VARCHAR(25)
)
  AUTO_INCREMENT = 10000;

CREATE TABLE blog (
  id        INT PRIMARY KEY AUTO_INCREMENT,
  author_id INT NOT NULL,
  title     VARCHAR(255)
);

CREATE TABLE post (
  id         INT PRIMARY KEY AUTO_INCREMENT,
  blog_id    INT,
  author_id  INT          NOT NULL,
  created_on TIMESTAMP,
  section    VARCHAR(25)  NOT NULL,
  subject    VARCHAR(255) NOT NULL,
  body       BLOB         NOT NULL,
  draft      INT          NOT NULL,
  FOREIGN KEY (blog_id) REFERENCES blog (id)
);

CREATE TABLE tag (
  id   INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE post_tag (
  post_id INT NOT NULL,
  tag_id  INT NOT NULL,
  PRIMARY KEY (post_id, tag_id)
);

CREATE TABLE comment (
  id      INT PRIMARY KEY AUTO_INCREMENT,
  post_id INT      NOT NULL,
  name    LONGTEXT NOT NULL,
  comment LONGTEXT NOT NULL
);

CREATE TABLE node (
  id        INT NOT NULL,
  parent_id INT,
  PRIMARY KEY (id)
);


INSERT INTO author (id, username, password, email, bio, favourite_section)
VALUES (101, 'jim', '********', 'jim@ibatis.apache.org', '', 'NEWS');
INSERT INTO author (id, username, password, email, bio, favourite_section)
VALUES (102, 'sally', '********', 'sally@ibatis.apache.org', NULL, 'VIDEOS');

INSERT INTO blog (id, author_id, title) VALUES (1, 101, 'Jim Business');
INSERT INTO blog (id, author_id, title) VALUES (2, 102, 'Bally Slog');

INSERT INTO post (id, blog_id, author_id, created_on, section, subject, body, draft) VALUES
  (1, 1, 101, '2008-01-01 00:00:01', 'NEWS', 'Corn nuts',
   'I think if I never smelled another corn nut it would be too soon...', 1);
INSERT INTO `post` (id, blog_id, author_id, created_on, section, subject, body, draft)
VALUES (2, 1, 101, '2008-01-12 00.00.00', 'VIDEOS', 'Paul Hogan on Toy Dogs', 'That''s not a dog.  THAT''s a dog!', 0);
INSERT INTO post (id, blog_id, author_id, created_on, section, subject, body, draft)
VALUES (3, 2, 102, '2007-12-05 00.00.00', 'PODCASTS', 'Monster Trucks', 'I think monster trucks are great...', 1);
INSERT INTO post (id, blog_id, author_id, created_on, section, subject, body, draft) VALUES
  (4, 2, 102, '2008-01-12 00.00.00', 'IMAGES', 'Tea Parties', 'A tea party is no place to hold a business meeting...',
   0);

INSERT INTO post (id, blog_id, author_id, created_on, section, subject, body, draft)
VALUES (5, NULL, 101, '2008-01-12 00.00.00', 'IMAGES', 'An orphaned post', 'this post is orphaned', 0);

INSERT INTO tag (id, name) VALUES (1, 'funny');
INSERT INTO tag (id, name) VALUES (2, 'cool');
INSERT INTO tag (id, name) VALUES (3, 'food');

INSERT INTO post_tag (post_id, tag_id) VALUES (1, 1);
INSERT INTO post_tag (post_id, tag_id) VALUES (1, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (1, 3);
INSERT INTO post_tag (post_id, tag_id) VALUES (2, 1);
INSERT INTO post_tag (post_id, tag_id) VALUES (4, 3);

INSERT INTO comment (id, post_id, name, comment) VALUES (1, 1, 'troll', 'I disagree and think...');
INSERT INTO comment (id, post_id, name, comment) VALUES (2, 1, 'anonymous', 'I agree and think troll is an...');
INSERT INTO comment (id, post_id, name, comment)
VALUES (4, 2, 'another', 'I don not agree and still think troll is an...');
INSERT INTO comment (id, post_id, name, comment) VALUES (3, 3, 'rider', 'I prefer motorcycles to monster trucks...');


INSERT INTO node (id, parent_id) VALUES (1, NULL);
INSERT INTO node (id, parent_id) VALUES (2, 1);
INSERT INTO node (id, parent_id) VALUES (3, 1);
INSERT INTO node (id, parent_id) VALUES (4, 2);
INSERT INTO node (id, parent_id) VALUES (5, 2);
INSERT INTO node (id, parent_id) VALUES (6, 3);
INSERT INTO node (id, parent_id) VALUES (7, 3);

```

pom 文件

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.li</groupId>
  <artifactId>mybatis</artifactId>
  <version>1.0-SNAPSHOT</version>
  <dependencies>
    <dependency>
      <groupId>org.mybatis</groupId>
      <artifactId>mybatis</artifactId>
      <version>3.5.2</version>
    </dependency>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.11</version>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>org.projectlombok</groupId>
      <artifactId>lombok</artifactId>
      <version>1.18.4</version>
    </dependency>
  </dependencies>
</project>
```

`mybatis`配置文件

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
    PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
  <properties resource="config.properties">
  </properties>
  <typeAliases>
    <package name="org.mybatis.example"/>
  </typeAliases>
  <environments default="development">
    <environment id="development">
      <transactionManager type="JDBC"/>
      <dataSource type="POOLED">
        <property name="driver" value="${driver}"/>
        <property name="url" value="${url}"/>
        <property name="username" value="${username}"/>
        <property name="password" value="${password}"/>
      </dataSource>
    </environment>
    </environments>
  <mappers>
    <package  name="org.mybatis.example"/>
  </mappers>
</configuration>
```

## properties

定义配置文件地址，标签属性值可以`${xxx}`取配置文件的值

## DataSource

`dataSource`标签用来定义一个标准的`DataSource`标准，`mybatis`内置了三种类型的`DataSource`

> `type="[UNPOOLED|POOLED|JNDI]"`

### `UNPOOLED`

每一次数据操作都新建。可做如下配置

> `driver`  
> `url` > `username`  
> `password`  
> `defaultTransactionIsolationLevel`:数据库隔离级别  
> `defaultNetworkTimeout`
> 同时可以为`driver`设置属性`driver.encoding=UTF8`

### `POOLED`

使用连接池来管理数据源,除了`UNPOOLED`的配置还可做如下配置

> `poolMaximumActiveConnections`  
> `poolMaximumIdleConnections`  
> `poolMaximumCheckoutTime`  
> `poolTimeToWait`  
> `poolMaximumLocalBadConnectionTolerance`  
> `poolPingQuery`  
> `poolPingEnabled`  
> `poolPingConnectionsNotUsedFor`

### `JNDI`

`initial_context`
`data_source`

`env.`前缀的配置将被加载到`InitialContext`中
`env.encoding=UTF8`

```xml
<dataSource type="JNDI">
  <property name="data_source" value="java:/comp/env/jdbc/mysql"/>
</dataSource>
```

### 自定义类型

`type`可指定为其他工厂类

```xml
<dataSource type="org.myproject.C3P0DataSourceFactory">
    <property name="driver" value="${driver}"/>
    <property name="url" value="${url}"/>
    <property name="username" value="${username}"/>
    <property name="password" value="${password}"/>
</dataSource>
```

env.encoding=UTF8

## mappers

定位映射的`SQL`语句

```xml
<mappers>
  <mapper url="file:/Users/BlogMapper.xml"/>
  <mapper class="org.mybatis.example.BlogMapper"/>
  <mapper resource="org.mybatis.example.BlogMapper.xml"/>
  <package  name="org.mybatis.example"/>
</mappers>
```

## typeAliases

`mybatis`默认别名有如下

|    别名    | class 类型 |
| :--------: | :--------: |
|   \_byte   |    byte    |
|   \_long   |    long    |
|  \_short   |   short    |
|   \_int    |    int     |
| \_integer  |    int     |
|  \_double  |   double   |
|  \_float   |   float    |
| \_boolean  |  boolean   |
|   string   |   String   |
|    byte    |    Byte    |
|    long    |    Long    |
|   short    |   Short    |
|    int     |  Integer   |
|  integer   |  Integer   |
|   double   |   Double   |
|   float    |   Float    |
|  boolean   |  Boolean   |
|    date    |    Date    |
|  decimal   | BigDecimal |
| bigdecimal | BigDecimal |
|   object   |   Object   |
|    map     |    Map     |
|  hashmap   |  HashMap   |
|    list    |    List    |
| arraylist  | ArrayList  |
| collection | Collection |
|  iterator  |  Iterator  |

可指定其他别名

```xml
<typeAliases>
  <typeAlias type="org.mybatis.example.Blog" alias="blog"/>
  <package name="org.mybatis.example"/>
</typeAliases>
```

别名可供`resultType`或`parameterType`使用

## typeHandlers

每当 MyBatis 在 PreparedStatement 上设置参数或从 ResultSet 中检索值时，都会使用 TypeHandler 以适合 Java 类型的方式检索值。 下表描述了默认的 TypeHandlers。

| Type Handler               | java Types                    | JDBC Types                                                                         |
| :------------------------- | :---------------------------- | :--------------------------------------------------------------------------------- |
| BooleanTypeHandler         | java.lang.Boolean, boolean    | Any compatible BOOLEAN                                                             |
| ByteTypeHandler            | java.lang.Byte, byte          | Any compatible NUMERIC or BYTE                                                     |
| ShortTypeHandler           | java.lang.Short, short        | Any compatible NUMERIC or SMALLINT                                                 |
| IntegerTypeHandler         | java.lang.Integer, int        | Any compatible NUMERIC or INTEGER                                                  |
| LongTypeHandler            | java.lang.Long, long          | Any compatible NUMERIC or BIGINT                                                   |
| FloatTypeHandler           | java.lang.Float, float        | Any compatible NUMERIC or FLOAT                                                    |
| DoubleTypeHandler          | java.lang.Double, double      | Any compatible NUMERIC or DOUBLE                                                   |
| BigDecimalTypeHandler      | java.math.BigDecimal          | Any compatible NUMERIC or DECIMAL                                                  |
| StringTypeHandler          | java.lang.String              | CHAR, VARCHAR                                                                      |
| ClobReaderTypeHandler      | java.io.Reader                | -                                                                                  |
| ClobTypeHandler            | java.lang.String              | CLOB, LONGVARCHAR                                                                  |
| NStringTypeHandler         | java.lang.String              | NVARCHAR, NCHAR                                                                    |
| NClobTypeHandler           | java.lang.String              | NCLOB                                                                              |
| BlobInputStreamTypeHandler | java.io.InputStream           | -                                                                                  |
| ByteArrayTypeHandler       | byte[]                        | Any compatible byte stream type                                                    |
| BlobTypeHandler            | byte[]                        | BLOB, LONGVARBINARY                                                                |
| DateTypeHandler            | java.util.Date                | TIMESTAMP                                                                          |
| DateOnlyTypeHandler        | java.util.Date                | DATE                                                                               |
| TimeOnlyTypeHandler        | java.util.Date                | TIME                                                                               |
| SqlTimestampTypeHandler    | java.sql.Timestamp            | TIMESTAMP                                                                          |
| SqlDateTypeHandler         | java.sql.Date                 | DATE                                                                               |
| SqlTimeTypeHandler         | java.sql.Time                 | TIME                                                                               |
| ObjectTypeHandler          | Any OTHER, or unspecified     |                                                                                    |
| EnumTypeHandler            | Enumeration Type              | VARCHAR any string compatible type, as the code is stored (not index).             |
| EnumOrdinalTypeHandler     | Enumeration Type              | Any compatible NUMERIC or DOUBLE, as the position is stored (not the code itself). |
| SqlxmlTypeHandler          | java.lang.String              | SQLXML                                                                             |
| InstantTypeHandler         | java.time.Instant             | TIMESTAMP                                                                          |
| LocalDateTimeTypeHandler   | java.time.LocalDateTime       | TIMESTAMP                                                                          |
| LocalDateTypeHandler       | java.time.LocalDate           | DATE                                                                               |
| LocalTimeTypeHandler       | java.time.LocalTime           | TIME                                                                               |
| OffsetDateTimeTypeHandler  | java.time.OffsetDateTime      | TIMESTAMP                                                                          |
| OffsetTimeTypeHandler      | java.time.OffsetTime          | TIME                                                                               |
| ZonedDateTimeTypeHandler   | java.time.ZonedDateTime       | TIMESTAMP                                                                          |
| YearTypeHandler            | java.time.Year                | INTEGER                                                                            |
| MonthTypeHandler           | java.time.Month               | INTEGER                                                                            |
| YearMonthTypeHandler       | java.time.YearMonth           | VARCHAR or LONGVARCHAR                                                             |
| JapaneseDateTypeHandler    | java.time.chrono.JapaneseDate | DATE                                                                               |

你可以通过继承`org.apache.ibatis.type.TypeHandler`或者使用`org.apache.ibatis.type.BaseTypeHandler`来使用非标准的`TypeHandler`

在配置文件`typeHandlers`中的`typeHandler`标签中配置`jdbcType`,可指定`sql`表字段类型，若实际`java`类注解了`@MappedJdbcTypes`，会无视配置文件  
在配置文件`typeHandlers`中的`typeHandler`标签中配置`javaType`,可指定`javaBean`类型，若实际`java`类注解了`@MappedTypes`，会无视配置文件  
示例如下：

```java
package org.mybatis.example;

import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedJdbcTypes;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
/**
* includeNullJdbcType=true表示当sql字段类型未知也可使用
*/
@MappedJdbcTypes(value=JdbcType.VARCHAR,includeNullJdbcType=true)
@MappedTypes(String.class)
public class ExampleTypeHandler extends BaseTypeHandler<String> {

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, String parameter, JdbcType jdbcType) throws SQLException {
        ps.setString(i, parameter+"_sql");
    }

    @Override
    public String getNullableResult(ResultSet rs, String columnName) throws SQLException {
        return rs.getString(columnName)+"_java";
    }

    @Override
    public String getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        return rs.getString(columnIndex)+":java";
    }

    @Override
    public String getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        return cs.getString(columnIndex)+"#java";
    }
}

```

在`mybatis`配置文件中若配置了`<typehandlers>`将会替换默认的数据库类型为`VARCHAR`，`java`类型为`java.lang.String`的转换处理器

```xml
<typeHandlers>
  <typeHandler handler="org.mybatis.example.ExampleTypeHandler"/>
  <!-- 扫描package目录下所有类型转换器-->
  <package name="org.mybatis.example"/>
</typeHandlers>
```

<hi>上述配置实际上是调用 org.mybatis.spring.SqlSessionFactoryBean:setTypeHandlers 方法</hi>

也可临时指定

```xml
<resultMap id="blogMap" type="blog">
  <result column="id"  property="id"/>
  <result column="title" typeHandler="exampleTypeHandler" property="title"/>
</resultMap>
```

可使用泛型，通过配置文件`typeHandler`的`javaType`觉得处理的`java`类型

```java
public class GenericTypeHandler<E extends MyObject> extends BaseTypeHandler<E> {

  private Class<E> type;

  public GenericTypeHandler(Class<E> type) {
    if (type == null) throw new IllegalArgumentException("Type argument cannot be null");
    this.type = type;
  }
```

```xml
<typeHandlers>
  <typeHandler handler="org.mybatis.example.ExampleTypeHandler" javaType="String"/>
</typeHandlers>
```

## plugins

`mybatis`可定义插件来对数据库操作的各个阶段以切面的方式进行处理。`mybatis`提供了四种类型的插件

在`mybatis`中增加配置，`<property>`的值注入到具体插件的`setProperties`方法的参数

```xml
<plugins>
  <plugin interceptor="org.mybatis.example.ExamplePlugin">
    <property name="someProperty" value="100"/>
  </plugin>
</plugins>
```

插件需要继承`org.apache.ibatis.plugin.Interceptor`，其中注解`Intercepts`的值，表示切面的位置

`type`

> `Executor` (update, query, flushStatements, commit, rollback, getTransaction, close, isClosed)  
> `ParameterHandler` (getParameterObject, setParameters)  
> `ResultSetHandler` (handleResultSets, handleOutputParameters)  
> `StatementHandler` (prepare, parameterize, batch, update, query)

`method`

> `type`里的方法名

`args`

> `type`里的方法的参数类型

`metdho`和`args`可以定位到一个具体的`java`方法。所以`method`和`args`的值参考`type`中的方法即可

```java
package org.mybatis.example;

import org.apache.ibatis.cache.CacheKey;
import org.apache.ibatis.executor.Executor;
import org.apache.ibatis.mapping.BoundSql;
import org.apache.ibatis.mapping.MappedStatement;
import org.apache.ibatis.plugin.Interceptor;
import org.apache.ibatis.plugin.Intercepts;
import org.apache.ibatis.plugin.Invocation;
import org.apache.ibatis.plugin.Signature;
import org.apache.ibatis.session.ResultHandler;
import org.apache.ibatis.session.RowBounds;

import java.util.Properties;

@Intercepts({
    @Signature(type = Executor.class, method = "query", args = {MappedStatement.class, Object.class, RowBounds.class,
        ResultHandler.class, CacheKey.class, BoundSql.class}),
    @Signature(type = Executor.class, method = "query", args = {MappedStatement.class, Object.class, RowBounds.class, ResultHandler.class})
})
public class ExamplePlugin implements Interceptor {
    private Properties properties = new Properties();

    public Object intercept(Invocation invocation) throws Throwable {
        System.out.println("properties:"+properties);
        return invocation.proceed();
    }

    public void setProperties(Properties properties) {
        this.properties = properties;
    }
}
```

通过自定义插件我们可以去分析下 `#{}`,`${}`的区别

```java
@Intercepts({
    @Signature(type = Executor.class, method = "query", args = {MappedStatement.class, Object.class, RowBounds.class,
        ResultHandler.class}),
})
public class ExamplePlugin implements Interceptor {

    public Object intercept(Invocation invocation) throws Throwable {
        MappedStatement mappedStatement = (MappedStatement) invocation.getArgs()[0];
        BoundSql boundSql = mappedStatement.getBoundSql(Map.class);
        System.out.println("boundSql:" + boundSql.getSql());
        return invocation.proceed();
    }
}
```

```java
sqlSession.selectOne(
            "org.mybatis.example.BlogMapper.selectBlog", 1 );
```

`#{}`,`${}`的实际输出，后者有被`sql`注入的可能性

```sql
boundSql:select *
    from Blog
    where id = ?
```

```sql
boundSql:select *
    from Blog
    where id = 1
```

## transactionManager

略，一般由`spring`去控制

## environments

可配置多环境的数据源

```xml
<environments default="development">
    <environment id="development">
    ...
    </environment>
</environments>
```

可指定`id`的数据源，若未指定则使用`default`的数据源

```java
SqlSessionFactory factory = new SqlSessionFactoryBuilder().build(reader, environment);
SqlSessionFactory factory = new SqlSessionFactoryBuilder().build(reader, environment, properties);
```

## mapping xml

详细信息科参考[官方文档](http://www.mybatis.org/mybatis-3/sqlmap-xml.html)
`mybatis`的核心在于映射的`SQL`

### SELECT

```xml
<select id="selectBlog" parameterType="int" resultType="hashmap" >
  select * from Blog where id = #{id}
</select>
```

`#{id}`这个通知`mybatis`创建一个`PreparedStatement`参数，在预编译阶段实际`sql`语句会被替换为

> `select * from Blog where id = ?`

实际执行代码类型如下

```java
String selectPerson = "SELECT * FROM PERSON WHERE ID=?";
PreparedStatement ps = conn.prepareStatement(selectPerson);
ps.setInt(1,id);
```

`id` `SQL`映射唯一标识  
`parameterType` 请求参数`class`类型  
`resultType` 返回结果集类型  
`resultMap` 扩展的返回类型的`id`  
`flushCache` 是否清空二级缓存，默认不清空  
`useCache` 是否开启二级缓存，默认不缓存  
`timeout` 请求超时时间  
`fetchSize` 返回最大条数，默认不限制  
`statementType` 可选`STATEMENT`,`PREPARED`或`CALLABLE`，决定使用的是 `Statement`,`PreparedStatement`或`CallableStatement`，默认的是`PREPARED`  
`resultSetType`  
`databaseId` `databaseIdProvider` 多种数据库引擎支持  
`resultOrdered`  
`resultSets`

### insert, update and delete

`id` `SQL`映射唯一标识  
`parameterType` 请求参数`class`类型  
`flushCache` 是否清空二级缓存，默认不清空  
`timeout` 请求超时时间  
`statementType` 可选`STATEMENT`,`PREPARED`或`CALLABLE`，决定使用的是 `Statement`,`PreparedStatement`或`CallableStatement`，默认的是`PREPARED`  
`useGeneratedKeys` 是否使用数据库自增主键  
`keyProperty` 用于指定传入的`java`成员变量  
`keyColumn` 用于指定数据库表的主键字段  
`databaseId` `databaseIdProvider` 多种数据库引擎支持

#### 返回主键

在配置了`useGeneratedKeys`时，如何取得返回的主键

```xml
  <insert id="insertBlog" useGeneratedKeys="true" keyProperty="java_id" keyColumn="id">
   insert into blog( title,author_id) values (#{title},#{author_id})
 </insert>
```

```java
SqlSession sqlSession = sqlSessionFactory.openSession();
Map map = new HashMap();
map.put("title", "title3");
map.put("author_id", "102");
int insert = sqlSession.insert("org.mybatis.example.BlogMapper.insertBlog", map);
System.out.println(map);
sqlSession.commit();
```

> {title=title3, author_id=102, java_id=6}

可以看到返回主键写入到请求的`pojo`中了

`mybatis`还提供了其他方式进行主键的生成

`<selectKey>`
`keyProperty` 指定存储主键的字段
`keyColumn` 用于指定数据库表的主键字段  
`order` `Before`或者`After`,若是`Before`,则先生成主键，执行`insert`。而设置为`After`,则先`insert`,再讲返回的主键插入的写入请求的`pojo`中  
`resultType` 返回主键类型  
`statementType` 可选`STATEMENT`,`PREPARED`或`CALLABLE`，决定使用的是 `Statement`,`PreparedStatement`或`CallableStatement`，默认的是`PREPARED`

#### 批量插入

```xml
 <insert id="insertBlog" useGeneratedKeys="true" keyProperty="id">
    insert into blog( title,author_id) values
    <foreach item="item" collection="list" separator=",">
    (#{item.title}, #{item.author_id})
    </foreach>
  </insert>
```

### SQL

可被其他`SQL`映射语句重复使用

```xml
<sql id="userColumns"> ${alias}.id,${alias}.username,${alias}.password </sql>

<select id="selectUsers" resultType="map">
  select
    <include refid="userColumns"><property name="alias" value="t1"/></include>,
    <include refid="userColumns"><property name="alias" value="t2"/></include>
  from some_table t1
    cross join some_table t2
</select>
```

### Parameters

#### `${}`或`#{}`

`${}`会被直接替换为值，而`#{}`则进入`prepared`阶段

使用介绍

```java
@Select("select * from user where ${column} = #{value}")
User findByColumn(@Param("column") String column, @Param("value") String value);
```

#### `#{}`高阶

可以指定某个属性使用独立的处理器，该处理器可以不用注册，但是需要使用全名，如果使用简称则需要已经注册的

> `#{age,javaType=int,jdbcType=NUMERIC,typeHandler=MyTypeHandler}`

指定`double`的精度

> `#{height,javaType=double,jdbcType=NUMERIC,numericScale=2}`

### ResultMap

通过自定义映射关系来处理复杂的返回结果集

属性
`id` 主键
`type` 返回`class`类型
`autoMapping` 自动匹配的模式。查询的`ResultSet`转换`pojo`时，会自动查找同名属性(忽略大小写)

> `NONE`表示不启用自动映射
> `PARTIAL`表示只对非嵌套的 resultMap 进行自动映射
> `FULL`表示对所有的 resultMap 都进行自动映射

```xml
<resultMap id="detailedBlogResultMap" type="Blog">
  <constructor>
    <idArg column="blog_id" javaType="int"/>
  </constructor>
  <result property="title" column="blog_title"/>
  <association property="author" javaType="Author">
    <id property="id" column="author_id"/>
    <result property="username" column="author_username"/>
    <result property="password" column="author_password"/>
    <result property="email" column="author_email"/>
    <result property="bio" column="author_bio"/>
    <result property="favouriteSection" column="author_favourite_section"/>
  </association>
  <collection property="posts" ofType="Post">
    <id property="id" column="post_id"/>
    <result property="subject" column="post_subject"/>
    <association property="author" javaType="Author"/>
    <collection property="comments" ofType="Comment">
      <id property="id" column="comment_id"/>
    </collection>
    <collection property="tags" ofType="Tag" >
      <id property="id" column="tag_id"/>
    </collection>
    <discriminator javaType="int" column="draft">
      <case value="1" resultType="DraftPost"/>
    </discriminator>
  </collection>
</resultMap>
```

#### id & result

映射基本类型，`id`表示主键

> `property` `pojo`成员变量  
> `column` 数据库字段  
> `javaType` 成员变量`class`类型  
> `jdbcType` 数据库字段类型  
> `typeHandler` 使用具体的处理器去处理

支持的数据库类型

> `BIT` `FLOAT` `CHAR` `TIMESTAMP` `OTHER` `UNDEFINED` >`TINYINT` `REAL` `VARCHAR` `BINARY` `BLOB` `NVARCHAR` >`SMALLINT` `DOUBLE` `LONGVARCHAR` `VARBINARY` `CLOB` `NCHAR` >`INTEGER` `NUMERIC` `DATE` `LONGVARBINARY` `BOOLEAN` `NCLOB` >`BIGINT` `DECIMAL` `TIME` `NULL` `CURSOR` `ARRAY`

#### constructor

为`type`有参构造器传递参数，分为`<idArg>`（主键）和`<arg>`，默认构造器参数根据顺序进行传参。

> `property` `pojo`成员变量  
> `column` 数据库字段  
> `javaType` 成员变量`class`类型  
> `jdbcType` 数据库字段类型  
> `typeHandler` 使用具体的处理器去处理
> `select` 其他映射语句的 id，根据其查询值注入构造器参数中
> `resultMap` 引入其他`resultMap` > `name` 根据名称指定具体参数值，无视参数顺序。

#### association

一定要注意集合类型的长度

> `property` `pojo`成员变量  
> `column` 数据库字段  
> `javaType` 成员变量`class`类型  
> `jdbcType` 数据库字段类型  
> `typeHandler` 使用具体的处理器去处理
> `select` 其他映射语句的 id，根据其查询值注入到成员变量中
> `resultMap` 引入其他`resultMap` >`fetchType` 可设置为`lazy`或`eager`是否延迟加载
> `columnPrefix` 当涉及到多表查询时，多表的字段相同，那么`sql`语句就需要使用`as`来区分字段。
> 例如：

```xml
<select id="selectBlog" resultMap="blogResult">
  select
  B.id as blog_id,
  B.title as blog_title,
  B.author_id as blog_author_id,
  P.id as post_id,
  P.subject as post_subject,
  P.body as post_body,
  from Blog B
  left outer join Post P on B.id = P.blog_id
  where B.id = #{id}
</select>
```

一般情况下我们

```xml
<resultMap id="blogResult" type="Blog">
  <id property="id" column="blog_id" />
  <result property="title" column="blog_title"/>
  <collection property="posts" ofType="Post">
    <id property="id" column="post_id"/>
    <result property="subject" column="post_subject"/>
    <result property="body" column="post_body"/>
  </collection>
</resultMap>
```

我们可以使用`columnPrefix`来处理

```xml
<resultMap id="blogResult" type="Blog">
  <id property="id" column="blog_id" />
  <result property="title" column="blog_title"/>
  <collection property="posts" ofType="Post" resultMap="blogPostResult" columnPrefix="post_"/>
</resultMap>

<resultMap id="blogPostResult" type="Post">
  <id property="id" column="id"/>
  <result property="subject" column="subject"/>
  <result property="body" column="body"/>
</resultMap>
```

#### discriminator

```xml
<resultMap id="vehicleResult" type="Vehicle">
  <id property="id" column="id" />
  <result property="vin" column="vin"/>
  <result property="year" column="year"/>
  <result property="make" column="make"/>
  <result property="model" column="model"/>
  <result property="color" column="color"/>
  <discriminator javaType="int" column="vehicle_type">
    <case value="1" resultMap="carResult"/>
    <case value="2" resultMap="truckResult"/>
    <case value="3" resultMap="vanResult"/>
    <case value="4" resultMap="suvResult"/>
  </discriminator>
</resultMap>
```

根据`column`的值决定哪种`<case>`执行

### cache

略过，由`spring`去控制

## Dynamic SQL

## SpringBoot

maven 依赖

```xml
<dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter</artifactId>
    <version>2.1.0</version>
</dependency>
```

[官方文档](http://www.mybatis.org/spring-boot-starter/mybatis-spring-boot-autoconfigure/)

可在`springboot`配置文件`application.properties`(或`application.yml`).中配置`Mybatis`使用`mybatis`前缀作为配置

`config-location` `mybatis`配置文件目录
`mapper-locations` `mapper`文件目录地址
`type-aliases-package` 别名包名，不同目录可用`,; \t\n`分割
`type-handlers-package` 类型转换器包名，不同目录可用`,; \t\n`分割
`configuration-properties` 指定`properties`配置文件，可被`mybatis`配置文件和`mapper`文件中作为占位符使用
`configuration.*` 等同于`mybatis`配置文件中的`settings`

可使用`ConfigurationCustomizer`来自定制细节

```java
@Configuration
public class MyBatisConfig {
  @Bean
  ConfigurationCustomizer mybatisConfigurationCustomizer() {
    return new ConfigurationCustomizer() {
      @Override
      public void customize(Configuration configuration) {
        // customize ...
      }
    };
  }
}
```

`mybatis`会自动检测继承`mybatis`接口的`bean`  
`Interceptor`  
`TypeHandler`  
`LanguageDriver (Requires to use together with mybatis-spring 2.0.2+)`  
`DatabaseIdProvider`

```java
@Configuration
public class MyBatisConfig {
  @Bean
  MyInterceptor myInterceptor() {
    return MyInterceptor();
  }
  @Bean
  MyTypeHandler myTypeHandler() {
    return MyTypeHandler();
  }
}
```
