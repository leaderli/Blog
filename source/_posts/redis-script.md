---
title: redis-script
date: 2020-05-19 20:02:20
categories: redis
tags:
---

## 简介

redis 内置 lua 解释器，支持解析执行 lua script。可以通过 eval 和 evalsha 命令来使用

`eval script numkey keys[key ...] argv[argv ...]`

- 第一个参数是 script，这个 script 无需定义一个 function(也不应该)，它可以直接被 redis 执行的上下文
- 第二个参数是`KEYS`参数的数量
- 剩余的参数既是`KEYS`和`ARGV`的参数

例如

```lua
> eval "return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}" 2 key1 key2 first second
1) "key1"
2) "key2"
3) "first"
4) "second"
```

## 调用 redis

我们可以使用以下两个方法在 lua 调用 redis 命令

- redis.call()
- redis.pcall()

这两个命令基本类似，唯一的区别在于当执行出错时，redis.call()会直接抛出异常，而 redis.pcall()仅将错误信息组织成报文返回

示例

```shell
# 0 表示script中无参数
eval "return redis.call('set','foo','bar')" 0
```

lua 中所有关于 redis 命令的操作在执行前需要分析哪个 key 会被操作，所以明确指定哪些 key 会被操作,确定 lua 将会被发送到哪个节点去执行。lua 操作的 keys 需要确保在同一个节点上，可以通过`hash槽`的方式确保其在同一个节点上。

## 原子性

lua script 的所有操作时原子性的

## evalsha

eval 命令每次执行 script 时会将 script 本身发送至服务器，redis 为了避免带宽消耗，提供了 evalsha 命令。它使用 script 的`sha1`值来替代 script 本身，若服务器有该 script 的缓存，则直接执行，否则返回失败，并提示你使用 eval 命令。

例如

```shell
> set foo bar
OK
> eval "return redis.call('get','foo')" 0
"bar"
> evalsha 6b1bf486c81ceb7edf3c093f4c48582e38c0e791 0
"bar"
> evalsha ffffffffffffffffffffffffffffffffffffffff 0
(error) `NOSCRIPT` No matching script. Please use [EVAL](/commands/eval).

```

每个 eval 执行的 script 都会被永久缓存在 redis 服务器中，可使用`script`命令来操作缓存

1. SCRIPT FLUSH 清空所有缓存的 lua script
2. SCRIPT EXISTS sha1 sha2 ... shaN 查看对应`sha1`的 lua script 是否存在
3. SCRIPT LOAD script 手动加载 lua script
4. SCRIPT KILL 用来打断一个长时间执行但未达到最大 script 执行时限的 lua script

## lua 脚本需要注意的地方

redis5 之后，当 lua 脚本执行成功后，redis 将写命令同步到从节点或者 aof 文件中，而不是同步 script
所以在之前的版本 lua 脚本需要按照以下标准

- 不使用系统时间或者其他外部的变量
- 禁止使用 redis 的 `randomkey`,`srandmember`,`time`命令
- lua 使用`smembers`会先排序
- 禁止使用 lua 的`math.random`和`math.randomseed`方法
- 禁止赋值全局变量

## 批量

```lua
eval "for i,v in pairs(argv) do
 redis.call('set',KEYS[i],ARGV[i])
end"  numkeys [KEYS...] [ARGV...]
```

## 在集群模式下执行`lua`时报错

> lua script attempted to access a non local key in a cluster node

redis 在执行 lua 时，将会对上送的`kEYS`进行计算，计算其是否属于同一个节点，如果属于同一节点，那么就会将 lua 请求转发到该节点去执行。若你在 lua 中手动写死 key，而不是通过参数上送的话，那么 redis 就可能随机选定一个节点去执行，实际执行过程中，就有一定几率发现当前节点是不正确的。
这是因为 redis 仅允许在单个节点执行 lua ，所以需要确保 key 在同一个节点上，为了确保 key 在同一个节点，我们可以使用`hash tag`，即用`{}`将 key 的一部分包裹起来，比如说`{dbconfig}_c1`,`{dbconfig}_c2`,这样在计算`hash槽`时只会计算`{}`内，从而确保 key 在同一个节点。

## 执行脚本文件

```lua
-- print输出在redis-server服务器的日志上
-- 删除大于hello1的key
print('--------------->')
local l=redis.call("keys","*")
for i=1,#l,1 do
    if('hello1'< l[i]) then
        redis.call('del',l[i])
    end

end
return l
```
