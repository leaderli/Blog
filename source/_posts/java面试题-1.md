---
title: java面试题_1
date: 2019-11-12 13:56:42
categories: 面试题
tags:
  - 面试题
  - java
---

### `HashMap`,`HashTable`,`CocurrentHashMap`的共同点和区别

共同点：

1. 底层使用拉链式数组
2. 为了避免`hash`冲突，当当数组元素已用槽数量超过(容量\*容载因子)就会扩容
3. `put`时，对`key`进行`hash`计算槽，若槽没有元素则赋值，否则插入链表的结尾
4. `get`时，对`key`进行`hash`计算槽，若槽没有元素或者仅有一个元素，则直接返回，
   否则，通过`equals`方法比较`key`，返回指定的元素

不同点：

1. `HashTable`的`key`和`value`不允许`null`
2. `hash`方法不同，`HashTable`直接对`hashcode`进行取模运算，`HashMap`首先对`hashcode`进行扰动计算，尽量避免 hash 碰撞。然后因其数组长度恒定为$2^n$,所以直接通过与运算进行取模，
3. `HashMap`线程不安全，`HashTable`通过`synchronized`修改关键方法确保线程安全，`CoccurentHashMap`通过分段锁的方式实现

### 说出几种幂等的实现方式

幂等操作指任意多次执行的结果和执行一次的结果一样。通俗来说，就是同一用户的对同一操作的多次请求的结果是一致的。

保证幂等性主要是三点：

1. 对于同一操作的请求必须有唯一标识，例如订单支付系统，肯定包含订单`ID`，确保一个订单仅支付一次。
2. 处理请求时需要有标识记录操作的状态，如正在处理中，已经处理完成等。
3. 每次接受请求时，需要判断是否已经处理过该请求或者正在处理该请求。

实现方式：

1. 分布式锁
2. 数据库锁
3. 事务

### `Spring`的`init-method`，`destroy-metdho`的实现方式

根据{% post_link spring-initMethod执行过程 %}的分析，我们可以知道`Spring`在扫描`bean`的配置信息时，将
`init-method`，`destroy-metdhod`的信息存储在`BeanDefinition`中，在`bean`的生命周期的一开始即实例化`bean`，以及对`bean`的属性进行初始化赋值后，会查找当前`BeanDefinition`,是否有`init-method`方法，有则通过反射去执行。在`bean`的生命周期的最后，会查找当前`BeanDefinition`,是否有`destroy-metdhod`方法，有则通过反射去执行。
