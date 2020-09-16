---
title: make
date: 2020-09-14 16:56:50
categories:
tags:
---

基本执行过程

```shell
.configure
make
```

## libvpx

```shell
./configure --enable-pic --enable-static --enable-shared --as=yasm --target=generic-gnu
# 清空编译临时文件目录
make clean
make
```
