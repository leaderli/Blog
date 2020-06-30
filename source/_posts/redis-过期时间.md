---
title: redis-过期时间
date: 2020-05-20 19:18:33
categories: redis
tags:
---

## 概述

redis 可对 key 设定过期时间，当达到指定时间后，将会自动将 key 删除

- expire 几秒后失效
- pexpire 几毫秒后失效
- expireat 指定秒失效
- pexpireat 指定毫秒失效
- ttl 查询剩余秒数
- pttl 查询剩余毫秒数
- persist 移出过期时间
- 过期时间设置可被`del`,`set`,`getset`和其他写命令给重置
- `rename`会将原 key 的过期时间同步过新 key 上

## 过期时间

key 的过期时间使用的是 Unix 时间戳，不同服务器的时间差异可能导致 key 提前或延迟过期。多个节点同步数据时，可能各个节点的数据是否已经失效时不同的。

key 的过期时间作为一个属性，存储在 key 的中

## 过期策略

被动删除，当客户端请求已经失效的 key 时，此时 redis 会直接删除该 key。但是有些 key 可能一直不被访问，所以 redis 还提供了定期删除的策略。redis 每次测试一小部分 key 是否过期，然后执行删除。

- 一般情况下一秒执行 10 此定时任务
- 随机测试 20 个 key，删除所有已经过期的
- 当 25%的 key 都是过期的，会重新执行此任务

## 同步过期命令

当 key 过期时，redis 会同步一个`del`命令到从节点，或者 AOF 文件。
