---
title: java-bridge-method
date: 2019-08-09 21:25:04
categories: java
tags:
  - 泛型
---

## 桥接方法

泛型类型擦除的影响，以及 bridge 方法介绍

```java
public class Node<T> {

    public T data;

    public Node(T data) { this.data = data; }

    public void setData(T data) {
        System.out.println("Node.setData");
        this.data = data;
    }
}

public class MyNode extends Node<Integer> {
    public MyNode(Integer data) { super(data); }

    public void setData(Integer data) {
        System.out.println("MyNode.setData");
        super.setData(data);
    }
}
```

当做如下使用时

```java
Node node = new MyNode(5);
n.setData("Hello");
```

我们的子类中实际是没有 setData(Object.class)的方法的，`java`编译器在进行类型擦除的时候会自动生成一个`synthetic`方法，也叫`bridge`方法,我们通过生成的字节码可以看到实际`bridge`方法，首先校验类型是否为`Integer`，然后在调用`setData(Integer.class)`因此，上述代码会抛出`ClassCastException`

```java
public void setData(java.lang.Integer);
    descriptor: (Ljava/lang/Integer;)V
    flags: ACC_PUBLIC
    Code:
        stack=2, locals=2, args_size=2
            0: getstatic     #2                  // Field java/lang/System.out:Ljava/io/PrintStream;
            3: ldc           #3                  // String MyNode.setNode
            5: invokevirtual #4                  // Method java/io/PrintStream.println:(Ljava/lang/String;)V
            8: aload_0
            9: aload_1
            10: invokespecial #5                  // Method com/li/springboot/bridge/Node.setData:(Ljava/lang/Object;)V
            13: return
        LineNumberTable:
        line 11: 0
        line 12: 8
        line 13: 13
        LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0      14     0  this   Lcom/li/springboot/bridge/MyNode;
            0      14     1 integer   Ljava/lang/Integer;
    MethodParameters:
        Name                           Flags
        integer


public void setData(java.lang.Object);
    descriptor: (Ljava/lang/Object;)V
    flags: ACC_PUBLIC, ACC_BRIDGE, ACC_SYNTHETIC
    Code:
        stack=2, locals=2, args_size=2
            0: aload_0
            1: aload_1
            2: checkcast     #11                 // class java/lang/Integer
            5: invokevirtual #12                 // Method setData:(Ljava/lang/Integer;)V
            8: return
        LineNumberTable:
        line 3: 0
        LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       9     0  this   Lcom/li/springboot/bridge/MyNode;
    MethodParameters:
        Name                           Flags
        integer                        synthetic

```

## 桥接子类获取泛型

父类泛型可以使用

```java
ParameterizedTypeImpl type = (ParameterizedTypeImpl) MyNode.class.getGenericSuperclass();
//具体每个泛型
type.getActualTypeArguments()
```

接口泛型

```java
ParameterizedTypeImpl[] types = (ParameterizedTypeImpl[]) MyNode.class.getGenericInterfaces();

```

## Spring 注入桥接子类注意

```java
public interface Generic<T,R> {}
@Component
public class G1 implements Generic<Object, Collection> {}
public class G2 implements Generic<Object, List> {}
public class G3<T> implements Generic<T, List> {}
public class G4 implements Generic<String, List> {}
```

```java

   @Autowired
   List<Generic> generics; //G1 G2 G3 G4
   @Autowired
   List<Generic<?, ? extends Collection>> generics; //G1 G2 G3 G4
   @Autowired
   List<Generic<?, Collection>> generics;//G1
   @Autowired
   List<Generic<Object, ? extends Collection>> generics; //G1 G2 G3
   @Autowired
   List<Generic<Object, Collection>> generics; //G1 G2
```
