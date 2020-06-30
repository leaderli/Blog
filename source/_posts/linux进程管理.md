---
title: linux进程管理
date: 2020-05-11 22:53:29
categories: linux
tags:
  - linux
  - 进程
---

## 后台运行

shell 中执行命令若以`&`结尾，则程序会在后台执行，当用户退出时该后台程序会停止运行。若需要程序永久运行可以使用`nohup`
可使用`jobs`查看正在运行的作业，然后可以使用`fg %n`(n 为作业编号)将后台任务返回前台

Ctrl+c 是强制中断程序的执行。
Ctrl+z 的是将任务中断,但是此任务并没有结束,他仍然在进程中他只是维持挂起的状态。

Ctrl+z 的程序也可以使用`fg`将其返回前台

`jobs -l`显示`pid`

## 查询进程

1. 查询正在运行的进程信息

   ```shell
   ps -ef
   ```

2. 查询归属于用户 colin115 的进程

   ```shell
   ps -ef | grep colin115
   ps -lu colin115
   ```

3. 查询进程 ID（适合只记得部分进程字段）

   ```shell
   pgrep <name>

   ```

4. 以完整的格式显示所有的进程

   ```shell
   ps -ajx
   ```

5. 显示进程内存占用

   ```shell
   ps -aux
   ```

6. 查看端口占用的进程状态：

   ```shell
   lsof -i:3306
   ```

7. 查看用户 username 的进程所打开的文件

   ```shell
   lsof -u username
   ```

8. 查询 init 进程当前打开的文件

   ```shell
   lsof -c init
   ```

9. 查询指定的进程 ID(23295)打开的文件：

   ```shell
   lsof -p 23295
   ```

10. 查询指定目录下被进程开启的文件（使用+D 递归目录）：

    ```shell
    lsof +d mydir1/
    ```

## 杀进程

kill 命令可向进程发送指定的信号（默认发送的信号是 SIGTERM）。`kill -l`：显示信号的信息，我们常用的`kill -9`就是`SIGKILL`信号

## 分析进程

### pstack

此命令可显示每个进程的栈跟踪，`pstack <pid>`,这个命令在排查进程问题时非常有用，比如我们发现一个服务一直处于 work 状态（如假死状态，好似死循环），使用这个命令就能轻松定位问题所在；可以在一段时间内，多执行几次 pstack，若发现代码栈总是停在同一个位置，那个位置就需要重点关注，很可能就是出问题的地方；

## 常用命令

### 快速杀进程

```shell
ps -ef|grep java|grep -v grep|awk '{print "kill -9 "$2}'|sh
```
