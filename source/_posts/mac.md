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

`jenv`
多java版本管理


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

[workflow 插件地址](http://alfredworkflow.com/)

### 自定义插件

file types 指的是文件的 metadata 信息中的 kMDItemContentTypeTree

```shell
$ mdls vim.md
_kMDItemOwnerUserID            = 501
kMDItemContentCreationDate     = 2020-09-16 07:06:53 +0000
kMDItemContentModificationDate = 2020-09-16 07:06:53 +0000
kMDItemContentType             = "net.daringfireball.markdown"
kMDItemContentTypeTree         = (
    "net.daringfireball.markdown",
    "public.plain-text",
    "public.text",
    "public.data",
    "public.item",
    "public.content"
)
kMDItemDateAdded               = 2020-09-16 07:06:53 +0000
kMDItemDisplayName             = "vim.md"
kMDItemFSContentChangeDate     = 2020-09-16 07:06:53 +0000
kMDItemFSCreationDate          = 2020-09-16 07:06:53 +0000
kMDItemFSCreatorCode           = ""
kMDItemFSFinderFlags           = 0
kMDItemFSHasCustomIcon         = (null)
kMDItemFSInvisible             = 0
kMDItemFSIsExtensionHidden     = 0
kMDItemFSIsStationery          = (null)
kMDItemFSLabel                 = 0
kMDItemFSName                  = "vim.md"
kMDItemFSNodeCount             = (null)
kMDItemFSOwnerGroupID          = 20
kMDItemFSOwnerUserID           = 501
kMDItemFSSize                  = 6093
kMDItemFSTypeCode              = ""
kMDItemKind                    = "Visual Studio Code document"
kMDItemLastUsedDate            = 2020-11-03 01:50:05 +0000
kMDItemLogicalSize             = 6093
kMDItemPhysicalSize            = 8192
kMDItemUseCount                = 6
kMDItemUsedDates               = (
    "2020-09-17 16:00:00 +0000",
    "2020-09-20 16:00:00 +0000",
    "2020-10-26 16:00:00 +0000",
    "2020-10-28 16:00:00 +0000",
    "2020-10-29 16:00:00 +0000",
    "2020-11-02 16:00:00 +0000"
)

```

## 命令行连接 wifi 脚本

```shell
wifi(){
   networksetup -setairportpower en0 off
   networksetup -setairportpower en0 on
   status=`networksetup -setairportnetwork en0 semaphore asdfv123456`

   if [ ! -n "$status" ];then
      eixt
   fi

}

for (( a=1;a<4;a++))
do
   wifi
   sleep 1s
done
```
