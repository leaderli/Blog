---
layout: posts
title: linux
date: 2019-07-04 00:49:32
categories: linux
tags:
  - linux
  - tips
---

shell 是系统内核和用户沟通的桥梁，它作为系统的命令解释器为用户提供解释命令的功能。linux 系统上存在多种 shell。可通过

```shell
#查看系统支持的 shell 软件
cat /etc/shells
#查看用户登录后默认使用的shell(当前用户时li)
cat /etc/passwd|grep ^li:
# 查看所有shell
chsh -l
# 切换shell
chsh
```

linux 的用户分为以下几类

1. root 用户，拥有系统的最高权限，任何文件的权限对 root 用户都是无效的。
2. 普通用户，指可以登录系统，拥有自己的主目录并且能够在主目录创建目录和操作文件的用户
3. 系统用户，又称虚拟用户和伪用户，其不具备登录系统的能力。这些用户用于特定的系统目的，如用来执行特定子系统完成服务所需要的进程等。系统用户的账号不属于任何人，是在系统安装或软件安装过程中默认创建的。
4. 当使用`sudo`还是无法运行命令时，需要将当前用户写入到`/ect/sudoers`配置中，在
   `root ALL=(ALL) ALL`下新增一行`[user] ALL = (ALL) ALL`

在 linux 系统下创建的用户的信息都被写在`/etc/passwd`这个文件中永久性保存，用户的密码经过 MD5 加密后存放在称为影子文件的`/etc/shadow`中

- w 查看当前登录用户

1. {% post_link linux环境变量 %}
2. {% post_link linux进程管理 %}
3. {% post_link linux查看 %}
4. {% post_link linux搜索 %}
5. {% post_link linux常用命令 %}
6. {% post_link linux文件系统 %}
