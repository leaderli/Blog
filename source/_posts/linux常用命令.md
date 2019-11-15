---
layout: posts
title: linux常用命令
date: 2019-07-04 00:49:32
categories: linux
tags:
- linux
- tips
---

### 快速杀进程

```shell
ps -ef|grep java|grep -v grep|awk '{print "kill -9 "$2}'|sh
```

### 获取当前日期

```shell
dt=`date +'%Y-%m-%d'`
```

### 命令可以作为参数传入shell脚本中

```shell
echo $1
echo $2
$1 $2 #直接执行
```

### 命令查看当前目录下所有文件夹的大小 -d 指深度，后面加一个数值

```shell
du -d 1 -h  
```

### 递归查找指定文件的制定内容，显示文件名行号内容

```shell
grep -rn 'stream' . --include='*.cpp'
```

### 快速删除大文件

```shell
cat /dev/null > access.log
```

### 快速备份

```shell
cp httpd.conf{,.bak}
```

### xargs引用参数

```shell
ls *.jar|xargs -I {} echo {}

```

## awk

`awk`可以用来快速切割文本，默认使用空格分隔符。`'{}'`中对每行都进行操作
`$0`表示当前行，`$1`表示切割的数组的第一个元素，`'{print $1}'`表示打印第一个元素

`-F ’-‘` 增加切割符
