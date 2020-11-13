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

1. 加载全局配置文件`/etc/profile` ， 该脚本会将`/etc/profile.d`目录下的 sh 文件全部执行
2. 加载用户配置文件，~/.bash_profile 或 ~/.bash_login 或~/.profile。上述三个文件只会读取一个，优先级依次降低
   login shell 是说在取得 bash 时需要完整的登陆流程。什么时候取得 bash 呢？当然就是用户登陆的时候。当你在 tty1~tty6 登陆，需要输入账号和密码，此时取得的 bash 就是 login shell。

### interactive shell

当使用非登录的方式启动一个 bash 时 ，就像你在桌面视图中用`ctrl+alt+T`启动的 shell 输入窗口就是`non-login shell`。还有就是你在 shell 窗口直接 su 切换的用户，都属于`non-login shell`。
`non-login shell`

1. 加载全局配置文件`/etc/bashrc`
2. 加载`~/.bashrc`

> 当使用`su <user>`切换用户的时，是以`non-login shell`的方式取得 bash 的，所以你的环境变量 PATH 等是不会改变的，如果你需要读取`/etc/profile`的话， 你需要用`su - <user>`的方式登录。`su -`就是`su -l`即`su --login`的意思
> 配置文件修改后需要使用`source`命令让它立即生效，例如`source ~/.bashrc`

### Non-interactive shell

在脚本中执行的 shell

## 全局变量

```shell
printenv #打印所有全局变量
```

## 临时变量

```shell
set             # 打印所有临时变量
set hello=you   # 设置临时变量
unset hello     # 移除变量，当你尝试移除一个全局变量时，仅仅移除当前环境的变量，在退出当前执行进程后，该变量依然存在

```

## 一些常见变量

| 变量 | 描述                                           |
| :--- | :--------------------------------------------- |
| IFS  | 一系列用于区分不同属性的字符串集合，默认是空格 |
| PATH | shell 用来查找命令的目录，不同的目录用`:`分割  |
| PS1  | 原始的 shell 提示字符串                        |
| PS2  | 提示继续进行输入的提示符                       |
| PWD  | 当前目录                                       |

## 相关配置

### 设定文件日期显示格式

1、编辑全局配置文件：/etc/profile，使所有用户均显示该格式：

```shell
#vi  /etc/profile
export TIME_STYLE="+%Y-%m-%d %H:%M:%S"
```

#### IFS

Shell 脚本中有个变量叫 IFS(Internal Field Seprator) ，内部域分隔符，shell 根据 IFS 的值，默认是 space, tab, newline 来拆解读入的变量，然后对特殊字符进行处理，最后重新组合赋值给该变量。

```shell
#!/bin/bash

string="hello,shell,split,test"

#对IFS变量 进行替换处理
OLD_IFS="$IFS"
IFS=","
array=($string)
IFS="$OLD_IFS"

for var in ${array[@]}
do
   echo $var
done
```
