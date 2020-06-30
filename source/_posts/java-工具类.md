---
title: java-工具类
date: 2020-06-04 22:31:25
categories: java
tags:
  - tips
---

### EventBus

`maven`

```xml
<dependency>
    <groupId>com.google.guava</groupId>
    <artifactId>guava</artifactId>
    <version>21.0</version>
</dependency>
```

`post`事件，注册的 listener 中注解了`@Subscribe`的方法会被执行，该方法的参数的类型需要与`event`类型一致，若没有类型一致的`@Subscribe`，则由参数类型`DeadEvent`的`listener`统一处理

```java
public class EventBusTest {
    @Test
    public void test() {
        EventBus eventBus = new EventBus();
        EventListener eventListener = new EventListener();
        eventBus.register(eventListener);
        eventBus.post("hello");
        eventBus.post(123);
    }
    public static class EventListener {
        @Subscribe
        public void stringEvent(String event) {
            System.out.println("event = " + event);
        }
        @Subscribe
        public void handleDeadEvent(DeadEvent deadEvent) {
            System.out.println("deadEvent = " + deadEvent);
        }
    }
}

```

### `junit` 断言异常

```java
public class Student {
    public boolean canVote(int age) {
        if (i<=0) throw new IllegalArgumentException("age should be +ve");
        if (i<18) return false;
        else return true;
    }
}
public class TestStudent{

    @Rule
    public ExpectedException thrown= ExpectedException.none();

    @Test
    public void canVote_throws_IllegalArgumentException_for_zero_age() {
        Student student = new Student();
        thrown.expect(IllegalArgumentException.class);
        thrown.expectMessage("age should be +ve");
        student.canVote(0);
    }
}
```

### `poi`

在生成`excel`时，当为单元格填充内容为数字时，生成的 excel 的数字单元格左上角提示绿色小三角。可在填充单元格值时使用`Double`类型

```java
XSSFCell cell = row.createCell(cellNum);
cell.setCellType(Cell.CELL_TYPE_STRING);
if(value.matches("\\d+")){
    cell.setCellValue(Double.valueOf(value));
}else{
    cell.setCellValue(value);
}
```
