---
title: linux相关问题
date: 2019-07-14 12:57:38
categories: linux
tags:
- linux
- unix
- problem
---

## root用户无法加载bash_profile

在尝试通过使用`su root`登录到root用户，`/var/root/.bash_profile`的环境变量始终无法加载。
通过查看`su`的文档
`su`会以当前登录用户的session去切换用户，而`su -`会重新登录

    The su command is used to become another user during a login session. Invoked without a username, su defaults to becoming the superuser. The optional argument - may be used to provide an environment similar to what the user would expect had the user logged in directly.

同时

    -, -l, --login
    Provide an environment similar to what the user would expect had the user logged in directly.

使用`su - root`则可正常加载环境配置
