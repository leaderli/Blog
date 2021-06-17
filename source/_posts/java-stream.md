---
title: java-stream
date: 2020-06-04 22:18:28
categories: java
tags:
---

### `groupingBy`

```java
 List<String> items =
            Arrays.asList("apple", "apple", "banana",
                "apple", "orange", "banana", "papaya");
Map<String, Long> result =
    items.stream().collect(
        Collectors.groupingBy(
            Function.identity(), Collectors.counting()
        )
    );
System.out.println("result = " + result);
Map<Object, Set<String>> collect = items.stream().collect(Collectors.groupingBy(String::length, Collectors.mapping(e -> e,
    Collectors.toSet())));

System.out.println("collect = " + collect);
```

### `join`

```java
String join = items.stream().collect(Collectors.joining(","));

```

### `reduce`

递归执行所有元素

```java
Stream<Integer> stream = Stream.of(1, 2, 3);
int count = stream.reduce(Integer::sum).orElse(0);
System.out.println("count " + count);
```

依次与初始值`identity`进行运算

```java
Stream<Integer> stream = Stream.of(2, 0, 3);
int identity = 6；
short value = stream.reduce(identity, (a, b) -> a * b).shortValue();
System.out.println("value = " + value);
```

相当于

```java
T result = identity;
for (T element : this stream)
    result = accumulator.apply(result, element)
return result;
```

依次与初始值`identity`进行运算，运行返回其他类型

```java
Stream<Integer> stream = Stream.of(2, 2, 3);
String reduce = stream.reduce("", (a, b) -> a + b, (u, u2) -> "");
System.out.println("reduce = " + reduce);
```

模拟 join

```java
 List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6);
String join= numbers.stream().map(String::valueOf).reduce((total, element) -> total + element+"").get();
System.out.println("join= " + join);
```

### 流快速删除,`Collection`提供了方法

```java
List<String> list = new ArrayList<>();
list.removeIf(Predicate<? super E> filter)
```

Map 根据value的值快速删除

```java
Map<Integer,Integer> map = new HashMap();
```

### `Collectors.toMap()`问题

`Collectors.toMap()`要求生成的 map 的 value 不能为 null，否则会报 nullPoint 异常。且 key 不能重复，否则会报 duplicate key 异常

### toArray

```java
List<String> list = new ArrayList<>();
list.add("l1");
list.add("l2");
String[] arr = list.stream().toArray(new IntFunction<String[]>() {
    @Override
    public String[] apply(int len) {
    //这里的len指的是list的长度
    return new String[len];
    }
});

//可以使用lambda来写
//String[] arr = list.stream().toArray(len -> new String[len]);

System.out.println(Arrays.toString(arr));
```
