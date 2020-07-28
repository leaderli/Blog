---
title: mac
date: 2019-10-17 20:49:58
categories: tips
tags: mac
---

## 常见问题

1. mac 无法直接输入汉字,杀进程就行了

   `safari`连接不上网络,`sudo killall -9 networkd`

2. terminal 切换到 root 提示

   > sh: autojump_add_to_database: command not found

   切换 root 使用`su - root`即可解决这个问题

3. command + tab 切换应用无反应
   Command+tab 键，选中到那个应用之后，再松开 tab 键，按住 option 键，然后再松开 Command 键就可以显示窗口了

## 命令

`more 1.txt|pbcopy`  
将文件内容复制到剪切板  
`pbpaste >> 1.txt`  
将剪切板内容复制到文件  
`pandoc`  
markdown 转换为 doc，pdf 等  
`ncdu`  
查看当前目录文件大小  
`mdfind`  
spotlight 搜索  
`fzf`  
模糊搜索工具,进入 fzf 模式  
`enca`  
字符集转码  
`bwm-ng`  
实时网速显示  
`ag`  
文本搜索工具

## 合并 PDF

```shell
"/System/Library/Automator/Combine PDF Pages.action/Contents/Resources/join.py" -o  ~/Downloads/1.pdf    ~/*.pdf

"/System/Library/Automator/Combine PDF Pages.action/Contents/Resources/join.py" -o  ~/Downloads/1.pdf    ~/1.pdf ~/2.pdf

```

## 打开`class`文件

```shell
vim -b XXX.class
:%!xxd
```

## 快速搜索文本

使用 grep 命令搜索文件时输出行号（`grep -n`），在 iTerm2 中打开可以直接定位到行

## 虚拟机 ip 固定

在虚拟机/etc/hosts 配置 ip

## alfred

模糊搜索时使用空格
