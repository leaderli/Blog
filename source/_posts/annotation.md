---
title: annotation
date: 2019-10-19 19:30:24
categories: java
tags:
- 注解
- 反射
---

## 注解的原理

注解本质是一个继承了`Annotation`的特殊接口，其具体实现类是`Java`运行时生成的动态代理类。而我们通过反射获取注解时，返回的是`Java`运行时生成的动态代理对象`$Proxy1`。通过代理对象调用自定义注解（接口）的方法，会最终调用`AnnotationInvocationHandler`的`invoke`方法。该方法会从`memberValues`这个`Map`中索引出对应的值。而`memberValues`的来源是`Java`常量池。

## 元注解

`java.lang.annotation`提供了四种元注解，专门注解其他的注解（在自定义注解的时候，需要使用到元注解）：

### `Retention` 定义该注解的生命周期

1. `RetentionPolicy.SOURCE` : 在编译阶段丢弃。这些注解在编译结束之后就不再有任何意义，所以它们不会写入字节码。`@Override`, `@SuppressWarnings`都属于这类注解。
2. `RetentionPolicy.CLASS` : 在类加载的时候丢弃。在字节码文件的处理中有用。注解默认使用这种方式
3. `RetentionPolicy.RUNTIME` : 始终不会丢弃，运行期也保留该注解，因此可以使用反射机制读取该注解的信息。我们自定义的注解通常使用这种方式。

### `Target` 表示该注解用于什么地方。默认值为任何元素，表示该注解用于什么地方。可用的`ElementType`参数包括

1. `ElementType.CONSTRUCTOR`:用于描述构造器
2. `ElementType.FIELD`:成员变量、对象、属性（包括`enum`实例）​​
3. `ElementType.LOCAL_VARIABLE`:用于描述局部变量
4. `ElementType.METHOD`:用于描述方法
5. `ElementType.PACKAGE`:用于描述包
6. `ElementType.PARAMETER`:用于描述参数
7. `ElementType.TYPE`:用于描述类、接口(包括注解类型) 或`enum`声明

### `Documented` 一个简单的`Annotations`标记注解，表示是否将注解信息添加在`java`文档中

### `Inherited`  元注解是一个标记注解，`@Inherited`阐述了某个被标注的类型是被继承的。如果一个使用了`@Inherited`修饰的`annotation`类型被用于一个`class`，则这个`annotation`将被用于该`class`的子类

## 自定义注解

自定义注解类编写的一些规则:
`Annotation`型定义为`@interface`, 所有的`Annotation`会自动继承`java.lang.Annotation`这一接口,并且不能再去继承别的类或是接口.
参数成员只能用`public`或默认(`default`)这两个访问权修饰
参数成员只能用基本类型`byte`,`short`,`char`,`int`,`long`,`float`,`double`,`boolean`八种基本数据类型和`String`、`Enum`、`Class`、`annotations`等数据类型,以及这一些类型的数组.
要获取类方法和字段的注解信息，必须通过`Java`的反射技术来获取 `Annotation`对象,因为你除此之外没有别的获取注解对象的方法
注解也可以没有定义成员, 不过这样注解就没啥用了PS:自定义注解需要使用到元注解

```java
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.PARAMETER, ElementType.TYPE})
public @interface NotNull {
}
```
