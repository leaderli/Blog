---
title: mac
date: 2019-10-17 20:49:58
categories: mac
tags: mac
---

mac无法直接输入汉字,杀进程就行了

`safari`连接不上网络,`sudo killall -9 networkd`

## 命令

`more 1.txt|pbcopy`  
将文件内容复制到剪切板  
`pbpaste >> 1.txt`  
将剪切板内容复制到文件  
`pandoc`  
markdown转换为doc，pdf等  
`ncdu`  
查看当前目录文件大小  
`mdfind`  
spotlight搜索  
`fzf`  
模糊搜索工具,进入fzf模式  
`enca`  
字符集转码  
`bwm-ng`  
实时网速显示  
`ag`  
文本搜索工具  

## 合并PDF

```shell
"/System/Library/Automator/Combine PDF Pages.action/Contents/Resources/join.py" -o  ~/Downloads/1.pdf    ~/*.pdf

"/System/Library/Automator/Combine PDF Pages.action/Contents/Resources/join.py" -o  ~/Downloads/1.pdf    ~/1.pdf ~/2.pdf

```

## 打开`class`文件

```shell
vim -b XXX.class
:%!xxd
```
