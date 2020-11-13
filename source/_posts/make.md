---
title: make
date: 2020-09-14 16:56:50
categories:
tags:
---

可参考博客的详细解释[一起写 Makefile](https://seisman.github.io/how-to-write-makefile/introduction.html#)

## 概述

基本规则

```makefile
target ... : prerequisites ...
    command
    ...
    ...
```

- target
  可以是一个 object file（目标文件），也可以是一个执行文件，还可以是一个标签（label）。即`:`后面什么也没有，make 就不会自动查找它的依赖性，也不会执行其定义的命令，可以通过`make <label>`的方式手动执行。makefile 的第一个 target 会被默认执行。
- prerequisites
  生成该 target 所依赖的文件和/或 target。如果 prerequisites 文件的日期要比 targets 文件的日期要新，或者 target 不存在的话，那么，make 就会执行后续定义的命令。
  make 会一层一层的去找文件的依赖关系，直到最终编译出第一个目标文件。
- command
  该 target 要执行的命令（任意的 shell 命令），要以一个 `Tab` 键作为开头，，命令可以为多行，每行命令在独立的进程中执行，不会共享变量，

```makefile

#可以定义变量
objects = main.o kbd.o command.o display.o \
    insert.o search.o files.o utils.o

edit : $(objects)
    cc -o edit $(objects)
main.o : main.c defs.h
    cc -c main.c
kbd.o : kbd.c defs.h command.h
    cc -c kbd.c
command.o : command.c defs.h command.h
    cc -c command.c
display.o : display.c defs.h buffer.h
    cc -c display.c
insert.o : insert.c defs.h buffer.h
    cc -c insert.c
search.o : search.c defs.h buffer.h
    cc -c search.c
files.o : files.c defs.h buffer.h command.h
    cc -c files.c
utils.o : utils.c defs.h
    cc -c utils.c

#标记clean为伪目标
.PHONY : clean
#伪目标，可以通过make clean执行
clean :
    rm edit $(objects)
```

伪目标一般没有依赖文件，但是也可以为伪目标制定锁依赖的文件。伪目标同样也可以作为“默认目标”，只要将其放在第一个。伪目标只是一个标签不会生成文件，它总是会被执行

```makefile
all:prog1 prog2 prog3
.PHONY: all

prog1: prog1.o utils.o
    cc -o prog1 prog1.o utils.o

prog2: prog2.o
    cc -o prog2 prog2.o

prog3: prog3.o sort.o utils.o
    cc -o prog3 prog3.o sort.o utils.o
```

## 参数

- -j 并行编译

## libvpx

```shell
./configure --enable-pic --enable-static --enable-shared --as=yasm --target=generic-gnu
# 清空编译临时文件目录
make clean
make
```

## gcc 版本

Centos7 gcc 版本默认 4.8.3，Red Hat 为了软件的稳定和版本支持，yum 上版本也是 4.8.3，所以无法使用 yum 进行软件更新，所以使用 scl。

scl 软件集(Software Collections),是为了给 RHEL/CentOS 用户提供一种以方便、安全地安装和使用应用程序和运行时环境的多个（而且可能是更新的）版本的方式，同时避免把系统搞乱。

使用 scl 升级 gcc 步骤：

```shell
# 安装scl源：
yum install centos-release-scl scl-utils-build
# 列出scl有哪些源可以用
yum list all --enablerepo='centos-sclo-rh'
# 安装5.3版本的gcc、gcc-c++、gdb
yum install devtoolset-4-gcc.x86_64 devtoolset-4-gcc-c++.x86_64 devtoolset-4-gcc-gdb-plugin.x86_64
# .查看从 SCL 中安装的包的列表
scl --list 或 scl -l
# 查看版本
gcc -v
# 切换版本 临时指定，退出bash后失效
# 使用scl创建一个scl包的bash会话环境
scl enable devtoolset-4 bash
```
