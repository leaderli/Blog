---
title: java中使用js
date: 2019-08-18 20:01:59
categories: java
tags:
- js
---


## 背景

使用`SpringBoot`构建的项目

注入`js`代码

```js
function objectToString(obj) {
  try {
    var result = "";
    result += getobjectprops("", obj);
    if (result.charAt(0) == '|') {
      result = result.substring(1);
    }
  } catch (errMsg) {
    return ("undefined");
  }
  return result;
}

function getArray(arrayName, item) {
  try {
    var len = eval(arrayName + '.length;');
    var result = "";
    for (var i = 0; i < len; i++) {
      if (i > 0) {
        result += " |";
      }
      var temp = arrayName + "[" + i + "]." + item;
      result += eval(temp);
    }
    return result;
  } catch (errMsg) {
    return ('unknown');
  }
}

function getRedirect(item) {
  return (getArray('session.connection.redirect', item));
}

f
```

```java
package com.li.ivr.test.expression;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;
import org.springframework.util.StreamUtils;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

/**
 *
 */
@Component
public class JS {

    @Value("classpath:rootxml.js")
    private Resource js;

    @Bean
    public ScriptEngine scriptEngine() throws IOException, ScriptException {
        ScriptEngineManager manager = new ScriptEngineManager();
        ScriptEngine engine = manager.getEngineByName("javascript");
        engine.eval(StreamUtils.copyToString(js.getInputStream(), StandardCharsets.UTF_8));
        return engine;
    }
}

```

测试

```java
package com.li.ivr.test.expression;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import javax.script.ScriptEngine;
import javax.script.ScriptException;
import java.io.IOException;

@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest
public class JSTest {

    @Autowired
    ScriptEngine js;

    @Test
    public void test() throws ScriptException, IOException {
        Object eval = js.eval("objectToString(1)");
        System.out.println(eval);
    }
}
```
