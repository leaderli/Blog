---
title: redis事务
date: 2020-05-22 08:20:24
categories: redis
tags:
---

## 使用 script

redis script 是原子性的，天然就支持事务，redis 事务可以做的操作，一定可以使用 script 实现，且更高效简单。

## multi

建立一个命令队列，将后续命令顺序存在在临时队列中而不是执行，直到碰到 exec 或者 discard
如果后续命令语法错误，将会直接触发 discard
multi 命令后，redis 是可以执行其他客户端命令的

## discard

将 multi 缓存的命令队列丢弃

## watch

```shell
watch [keys ...]
```

监听一个或多个 key，将当前 key 的值存储起来

## unwatch

清空 watch 监听的 key

## exec

- 执行前判断是否有 watch 监听的 key，如有判断当前监听的 key 的值是否变动，若变动则不执行 exec
- 一旦开始执行 multi 命令队列，redis 核心程序顺序执行此命令队列，此操作时原子性的，不存在其他客户端命令在其中间执行
- 处于 redis 执行效率，命令队列执行过程中，如果命令执行失败或报错，仅将错误信息返回，并不会影响其他命令的执行
- 不支持回滚
- 清空 multi 队列
- 清空 watch 监听的 key
