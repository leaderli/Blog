---
title: linux相关问题
date: 2019-07-14 12:57:38
categories: linux
tags:
  - linux
  - unix
  - problem
---

## root 用户无法加载 bash_profile

在尝试通过使用`su root`登录到 root 用户，`/var/root/.bash_profile`的环境变量始终无法加载。
通过查看`su`的文档
`su`会以当前登录用户的 session 去切换用户，而`su -`会重新登录

    The su command is used to become another user during a login session. Invoked without a username, su defaults to becoming the superuser. The optional argument - may be used to provide an environment similar to what the user would expect had the user logged in directly.

同时

    -, -l, --login
    Provide an environment similar to what the user would expect had the user logged in directly.

使用`su - root`则可正常加载环境配置

下述问题也是这样的原因，可以通过上述方式去解决

> autojump_add_to_database command not found

## yum 安装一直超时

比如有如下提示

> Couldn't determine mirror, try again later 络

1. 确认下是否能链接到网络
2. 确认下 yum 的源是否失效了

## make 一直循环

如果系统时间比软件的发布时间要早，make 就会进入死循环。
使用`date -s '<date>'`修改为最新的时间即可

## make 缺少相关组件

> cache.h:21:18: fatal error: zlib.h: No such file or directory

下载`https://zlib.net/zlib-1.2.11.tar.gz`软件

    ```shell
    #下载
    wget https://zlib.net/zlib-1.2.11.tar.gz
    tar -xvf  lib-1.2.11.tar.gz
    cd zlib-1.2.11
    ./configure
    make  -j4
    make install
    ```

## `./`执行脚本头文件不存在

> !#/usr/bin/python3: No such file or directory

因为复制粘贴`!#/usr/bin/python3`时带上了不可见的换行或其他字符

通过命令`$ head -1 yourscript | od -c`文件的头文件的

- `0000000 # ! / b i n / b a s h \r \n`
- `0000000 357 273 277 # ! / b i n / b a s h \n`
- `0000000 # ! / b i n / b a s h \n`（这样的才是正确的输出）

> od 指令会读取所给予的文件的内容，并将其内容以八进制字码呈现出来
