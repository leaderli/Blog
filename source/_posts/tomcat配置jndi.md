---
title: tomcat配置jndi
date: 2019-08-10 22:24:42
categories: tomcat
tags: 
- tomcat
- jndi
- datasource
---

确保tomcat下有相关`jar`

tomcat目录下`/conf/context.xml`中增加配置

```xml
<Resource name = "jdbc/mysql"
      auth = "Container"
      type = "javax.sql.DataSource"  
      driverClassName = "com.mysql.jdbc.Driver"  
      url = "jdbc:mysql://localhost:3306/app"  
      factory="com.li.jndi.EncryptedDataSourceFactory"
      username = "root"
      password = "xxxx"
      maxActive = "200"
      maxIdle = "30"
      maxWait = "5000"
/>  
```

确保tomcat目录下有`driver`的`jar`包
>`/lib/mysql-connector-java-8.0.16.jar`

`factory`标签是指定`BasicDataSourceFactory`工厂类，可以用来解密`password`密文。需要如下依赖

```xml
<dependency>
    <groupId>commons-dbcp</groupId>
    <artifactId>commons-dbcp</artifactId>
    <version>1.2.2</version>
</dependency>
```

`EncryptedDataSourceFactory`代码如下

```java
package com.li.jndi;

import org.apache.commons.dbcp.BasicDataSourceFactory;
import org.apache.naming.ResourceRef;

import javax.naming.*;
import java.util.Enumeration;
import java.util.Hashtable;

public class EncryptedDataSourceFactory extends BasicDataSourceFactory {

    @Override
    public Object getObjectInstance(Object obj, Name name, Context nameCtx, Hashtable environment) throws Exception {
        if (obj instanceof ResourceRef) {
            decode("password", (Reference) obj);
        }
        return super.getObjectInstance(obj, name, nameCtx, environment);
    }

    private String decode(String old) throws Exception {
        return "root";
    }

    private int find(String addrType, Reference ref) throws Exception {
        Enumeration enu = ref.getAll();
        for (int i = 0; enu.hasMoreElements(); i++) {
            RefAddr addr = (RefAddr) enu.nextElement();
            if (addr.getType().compareTo(addrType) == 0) {
                return i;
            }
        }
        throw new Exception("The \"" + addrType
            + "\" name/value pair was not found"
            + " in the Reference object. The reference Object is" + " "
            + ref.toString());
    }

    private void decode(String refType, Reference ref) throws Exception {
        int index = find(refType, ref);
        RefAddr refAddr = ref.get(index);
        Object content = refAddr.getContent();
        if (content instanceof String) {
            ref.remove(index);
            ref.add(index, new StringRefAddr(refType, decode((String) content)));
        }
    }

}

```

使用`jndi`服务

```java
package com.li.jndi;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

public class DBConn {

    private static DataSource dataSource;

    static {
        try {
            Context context = new InitialContext();
            dataSource = (DataSource)context.lookup("java:comp/env/jdbc/mysql");
        }
        catch (NamingException e) {
            e.printStackTrace();
        }
    }
}
```
