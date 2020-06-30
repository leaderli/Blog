---
title: linux环境变量
date: 2020-05-11 21:51:47
categories: linux
tags:
  - linux
  - 环境变量
---

## 配置文件加载

### login shell

`login shell`是需要用户输入账号和密码进入`shell`，进行一个完整的登录流程。这种登录方式加载配置文件的方式如下

1. 加载全局配置文件`/etc/profile`
2. 加载用户配置文件，~/.bash_profile 或 ~/.bash_login 或~/.profile。上述三个文件只会读取一个，优先级依次降低
   login shell 是说在取得 bash 时需要完整的登陆流程。什么时候取得 bash 呢？当然就是用户登陆的时候。当你在 tty1~tty6 登陆，需要输入账号和密码，此时取得的 bash 就是 login shell。

### non-login shell

`non-login shell` 就是取得 bash 不需要重复登录，就像你在桌面视图中用`ctrl+alt+T`启动的 shell 输入窗口就是`non-login shell`。还有就是你在 shell 窗口直接 su 切换的用户，都属于`non-login shell`。
`non-login shell` 只会读取~/.bashrc 这个文件

> 当使用`su <user>`切换用户的时，是以`non-login shell`的方式取得 bash 的，所以你的环境变量 PATH 等是不会改变的，如果你需要读取`/etc/profile`的话， 你需要用`su - <user>`的方式登录。`su -`就是`su -l`即`su --login`的意思
> 配置文件修改后需要使用`source`命令让它立即生效，例如`source ~/.bashrc`

## 相关配置

### 设定文件日期显示格式

1、编辑全局配置文件：/etc/profile，使所有用户均显示该格式：

```shell
#vi  /etc/profile
export TIME_STYLE="+%Y-%m-%d %H:%M:%S"
```

### `PATH`

当程序在`PATH`的目录中且具有执行权限的时候，就可以在任意地方直接运行
