---
title: gson使用手册
date: 2019-08-01 21:22:36
categories: tips
tags:
  - gson
  - tips
---

## 基本类型

```java
// Serialization
Gson gson = new Gson();
gson.toJson(1);            // ==> 1
gson.toJson("abcd");       // ==> "abcd"
gson.toJson(new Long(10)); // ==> 10
int[] values = { 1 };
gson.toJson(values);       // ==> [1]

// Deserialization
int one = gson.fromJson("1", int.class);
Integer one = gson.fromJson("1", Integer.class);
Long one = gson.fromJson("1", Long.class);
Boolean false = gson.fromJson("false", Boolean.class);
String str = gson.fromJson("\"abc\"", String.class);
String[] anotherStr = gson.fromJson("[\"abc\"]", String[].class);
```

## 类

```java
class BagOfPrimitives {
  private int value1 = 1;
  private String value2 = "abc";
  private transient int value3 = 3;
  BagOfPrimitives() {
    // no-args constructor
  }
}

// Serialization
BagOfPrimitives obj = new BagOfPrimitives();
Gson gson = new Gson();
String json = gson.toJson(obj);

// ==> json is {"value1":1,"value2":"abc"}
```

注意事项

1. 类的属性推荐使用`private`
2. 默认情况下被`transient`修饰的属性会被忽略
3. 序列化时为值`null`的属性将会被忽略
4. 反序列化时，值`null`的属性将会被赋值为`零值`
5. 序列化与反序列化默认不会调用 set、get 方法

## 数组

```java
Gson gson = new Gson();
int[] ints = {1, 2, 3, 4, 5};
String[] strings = {"abc", "def", "ghi"};

// Serialization
gson.toJson(ints);     // ==> [1,2,3,4,5]
gson.toJson(strings);  // ==> ["abc", "def", "ghi"]

// Deserialization
int[] ints2 = gson.fromJson("[1,2,3,4,5]", int[].class);
// ==> ints2 will be same as ints
```

## 集合

```java
Gson gson = new Gson();
Collection<Integer> ints = Lists.immutableList(1,2,3,4,5);

// Serialization
String json = gson.toJson(ints);  // ==> json is [1,2,3,4,5]

// Deserialization
Type collectionType = new TypeToken<Collection<Integer>>(){}.getType();
Collection<Integer> ints2 = gson.fromJson(json, collectionType);
// ==> ints2 is same as ints
```

## 泛型

```java
class Foo<T> {
  T value;
}
Gson gson = new Gson();

Foo<Bar> foo = new Foo<Bar>();
Type fooType = new TypeToken<Foo<Bar>>() {}.getType();
gson.toJson(foo, fooType);

gson.fromJson(json, fooType);
```

使用`TypeToken`可指定泛型

## 内置解析器

`java.net.URL`可以匹配如下格式的值`"https://github.com/google/gson/"`
`java.net.URI` 可以匹配如下格式的值`"/google/gson/"`

```java
Gson gson = new Gson();
String json = "{\"url\": \"https://github.com/google/gson/\",\"uri\": \"/google/gson/\"}";
TestUrl testUrl = gson.fromJson(json, TestUrl.class);
// toString -->  GsonTest.TestUrl(url=https://github.com/google/gson/, uri=/google/gson/)

@Data
public static class TestUrl{
    private URL url;
    private URI uri;
}
```

## 自定义序列化与反序列化

需要序列化的类`UserBean`

```java
@Data
public class UserBean {
    private String name;
}
```

序列化处理器，泛型为`UserBean`

```java
 public class UserJsonSerializer implements JsonSerializer<UserBean>{

    @Override
    public JsonElement serialize(UserBean src, Type typeOfSrc, JsonSerializationContext context) {
        //src 即是待序列化的实例对象
        JsonObject userJson= new JsonObject();
        userJson.addProperty("__name__",src.getName());
        return userJson;
    }
}
```

反序列化处理器，泛型为`UserBean`

```java
 public class UserJsonDeserializer implements JsonDeserializer<UserBean>{

    @Override
    public UserBean deserialize(JsonElement json, Type typeOfT, JsonDeserializationContext context) throws JsonParseException {
        UserBean userBean = new UserBean();
        //json 即为待反序列化的字符串生成的json对象
        JsonObject asJsonObject = json.getAsJsonObject();
        if(asJsonObject.has("__name__")){
            userBean.setName(String.valueOf(asJsonObject.get("__name__")));
        }
        return userBean;
    }
}
```

测试程序，注册`UserBean`的`TypeToken`的序列化与反序列化处理器

```java
GsonBuilder gsonBuilder = new GsonBuilder();
Type type= new TypeToken<UserBean>() {}.getType();
gsonBuilder.registerTypeAdapter(type,new UserJsonSerializer());
gsonBuilder.registerTypeAdapter(type,new UserJsonDeserializer());
Gson gson = gsonBuilder.create();
UserBean userBean = new UserBean();
userBean.setName("123");
String json = gson.toJson(userBean);
// {"__name__":"123"}
userBean = gson.fromJson(json, UserBean.class);
//UserBean(name="123")
```

## 使用 JsonSerializer 统一处理 null

```java
package com.leaderli.demo.util;

import com.google.gson.*;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;

public class GsonTest {

    private static class MapJsonSerializer implements JsonSerializer {

        @Override
        public JsonElement serialize(Object o, Type type, JsonSerializationContext jsonSerializationContext) {
            return serialize(o,(Class)type);
        }


        private <T> JsonElement serialize(Object o, Class<T> type) {
            if (Map.class.isAssignableFrom(type)) {
                JsonObject jsonObject = new JsonObject();
                Map<?, ?> map = (Map) o;
                map.forEach((k, v) -> {
                    if (k == null) {
                        return;
                    }
                    String key = String.valueOf(k);
                    if (v == null) {
                        jsonObject.add(key, new JsonPrimitive(""));
                    } else {
                        jsonObject.add(key, serialize(v, v.getClass()));
                    }

                });
                return jsonObject;
            } else if (Iterable.class.isAssignableFrom(type)) {
                Iterable<?> iterable = (Iterable) o;
                JsonArray array = new JsonArray();
                iterable.forEach(e -> {
                    if (e == null) {
                        array.add(new JsonPrimitive(""));
                    } else {

                        array.add(serialize(e, e.getClass()));
                    }

                });
                return array;
            } else {

                return new JsonPrimitive(String.valueOf(o));
            }
        }
    }

    @Test
    public void test() {

        Gson gson = new GsonBuilder().registerTypeHierarchyAdapter(Map.class, new MapJsonSerializer()).create();

        Map map = new HashMap();
        map.put("str",null);
        map.put("set",new HashSet<>());
        ArrayList<Object> list = new ArrayList<>();
        list.add(1);
        list.add(null);
        map.put("list", list);
        Map temp= new HashMap();
        temp.put("temp",null);
        map.put("temp",temp);

        System.out.println(gson.toJson(map));


    }
}

```

> {"str":"","temp":{"temp":""},"set":[],"list":["1",""]}

## 优化打印

```java
Gson gson = new GsonBuilder().setPrettyPrinting().create();
Person person= new Person();
person.setAge(1);
person.setName("hello");
System.out.println(gson.toJson(person))
```

打印结果如下

```json
{
	"name": "hello",
	"age": 1
}
```
