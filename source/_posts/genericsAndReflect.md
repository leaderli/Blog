---
title: genericsAndReflect
date: 2019-10-19 19:51:27
categories: java
tags:
- reflect
- generick
- 泛型
- 反射
---

## `void`类型的范型方法

```java
private <T> void set(T t) {
  System.out.println(t);
}
```

## `java`运行时无法捕获`ClassCastException`的解决办法

```java
 private static <T> T get(Object o, T def) {
   try {
     return (T) def.getClass().cast(o);
   } catch (Throwable e) {
     return (T) def;
   }
 }
```

通过查看字节码就可以了解,直接 `return (T) value` 是在方法外检测`cast`

## 可变参数方法的反射

```java
public static void me(Object ... objects){
    for (Object object : objects) {
        System.out.println(object);
    }
}
@Test
public void  test() throws Exception {
    Class clazz = this.getClass();
    //Method method = clazz.getMethod("me",(new Object[0]).getClass());
    //Method method = clazz.getMethod("me",Array.newInstance(Object.class,0).getClass());
    Method method = clazz.getMethod("me",Class.forName("[Ljava.lang.Object;"));
    //1
    Object objs = Array.newInstance(object.class,2);
    Array.set(objs,0,1);
    Array.set(objs,1,"test");
    method.invoke(clazz,objs);
    //2
    Object[] obj = {1,"test"}
    method.invoke(clazz,new Object[]{obj});
}
```

可变参数不可直接显式使用null作为参数

```java
public class TestStatic {
    public static void main(String[] args) {
        String s = null;
        m1(s);
        Util.log("begin null");
        m1(null);
    }

    private static void m1(String... strs) {
        System.out.println(strs.length);
    }

}
```

```java
0: aconst_null          //将null压入操作栈
1: astore_1             //弹出栈顶(null)存储到本地变量1
2: iconst_1             //压栈1此时已经到方法m1了，在初始化参数，此值作为数组长度
3: anewarray     #2     //新建数组            // class java/lang/String
6: dup                  //复制数组指针引用
7: iconst_0             //压栈0，作为数组0角标
8: aload_1              //取本地变量1值压栈，作为数组0的值
9: aastore              //根据栈顶的引用型数值（value）、数组下标（index）、数组引用（arrayref）出栈，将数值存入对应的数组元素中
10: invokestatic  #3    //此时实际传递的是一个数组，只是0位置为null的元素 Method m1:([Ljava/lang/String;)V
13: iconst_1
14: anewarray     #4    //class java/lang/Object
17: dup
18: iconst_0
19: ldc           #5    //String begin null
1: aastore
22: invokestatic  #6    //Method li/Util.log:([Ljava/lang/Object;)V
25: aconst_null         //此处并没有新建数组操作，直接压栈null
26: invokestatic  #3    //此处一定会抛出空指针  Method m1:([Ljava/lang/String;)V
29: return
```

## 泛型 `extends super`

```java
//不管是extends或是super，只能使用在变量声明上，实际赋值的时候，一定是指定具体实现类的。

//那么对于<? extends T>来说，具体的实现类的泛型A只是变量声明的泛型T的子类，如果以T进行插入时，是无法保证插入的class类型，一定是A，所以extends禁用插入动作
List<Apple> apples = new ArrayList<Apple>();
List<? extends Fruit> fruits = apples;
// 对于<? super T>来说，具体的实现类的泛型A一定是变量声明的泛型T的父类，如果以T类型进入取值操作，无法保证取出的值一定是T类型，因为A一定是T的父类，所以插入的所有实例一定也是A的多态

List<Fruit> fruits = new ArrayList<Fruit>();
List<? super Apple> = fruits;
```

## 如何修改final修饰符的值

```java
String str = "fuck";

Field value = String.class.getDeclaredField("value");
//Field中包含当前属性的修饰符，通过改变修饰符的final属性，达到重新赋值的功能
Field modifier = Field.class.getDeclaredField("modifiers");
modifier.setAccessible(true);
modifier.set(value, value.getModifiers() & ~Modifier.FINAL);

value.setAccessible(true);
value.set(str, "notfuck".toCharArray());
//修改成功后重新加上final修饰符
modifier.set(value, value.getModifiers() | Modifier.FINAL);}
```