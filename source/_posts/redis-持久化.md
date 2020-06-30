---
title: redis-持久化
date: 2020-05-26 18:33:02
categories: redis
tags:
---

## RDB

RDB 是 redis 在指定时间内生成的数据集的时间点快照，可使用`SAVE`命令手动生成备份文件

**_优点:_**

- 一个时间点的压缩过的快照文件，非常适用于备份
- 适用于作为容灾处理，可以存储在其他数据中心
- 仅需子进程去生成快照，不阻塞 redis 主线程
- 启动时恢复数据比 AOF 快

**_缺点:_**

- RDB 不利于记录短时间内的数据更新操作
- RDB 最多可能会丢失备份间隔时间内的数据
- 当数据过大时，生成快照耗费时间过多

## AOF

AOF 是一个记录了 redis 所有写操作的日志，它可以在服务器启动时重新执行这些写命令来还原数据库。
AOF 文件中记录的写命令使用 redis 协议来保存数据，新命令会被追加到文件的结尾。redis 还可以对 AOF 文件进行重写，优化 AOF 文件的体积

**_优点:_**

- 可靠性高，AOF 可供选择的策略`no fsync at all`, `fsync every second`, `fsync at every query`，默认情况下使用的是 `fsync every second`。同步的频率越高，占用 CPU 越多，同步效果越好
- AOF 日志一个追加文件
- AOF 可通过重写优化其体积
- AOF 文件格式易于理解，方便转换

**_缺点:_**

- AOF 文件一般大于 RDB
- AOF 消耗性能大

## 配置

```conf
# RDB 每60秒，至少1000个key被修改过
save 60 1000

# AOF
appendonly yes
# AOF策略
#1 no
#2 everysec
#3 always
appendfsync  everysec
```

可以使用`redis-check-aof`修复 aof 文件
可以使用`redis-check-rdb`修复 rdb 文件
