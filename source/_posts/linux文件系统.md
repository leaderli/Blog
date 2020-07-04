---
title: linux文件系统
date: 2020-05-13 23:38:32
categories: linux
tags:
---

## 链接

软链接，全称是软链接文件，英文叫作 symbolic link。这类文件其实非常类似于 Windows 里的快捷方式，这个软链接文件（假设叫 VA）的内容，其实是另外一个文件（假设叫 B）的路径和名称，当打开 A 文件时，实际上系统会根据其内容找到并打开 B 文件。

```shell
#软链接
ln  -s [source] [link]
```

而硬链接，全称叫作硬链接文件，英文名称是 hard link。这类文件比较特殊，这类文件（假设叫 A）会拥有自己的 inode 节点和名称，其 inode 会指向文件内容所在的数据块。与此同时，该文件内容所在的数据块的引用计数会加 1。当此数据块的引用计数大于等于 2 时，则表示有多个文件同时指向了这一数据块。一个文件修改，多个文件都会生效。当删除其中某个文件时，对另一个文件不会有影响，仅仅是数据块的引用计数减 1。当引用计数为 0 时，则系统才会清除此数据块。

```shell
ln -n [source] [link]
```

**_软链接可以指向目录，而硬链接不可以_**

## df

查看文件系统以及它们的相关信息

## cp

复制文件

- -v 显示复制的详情

## tar

```shell
#压缩
tar -zcvf myfile.tgz file1 file2
# 解压
tar -xvf file.tar
```

## rsync

同步命令，可用于备份应用。该命令做数据的同步备份，会对比数据源目录和数据备份目录的数据，并把不同的数据同步到备份目录。其也可以同步到其他服务器，用法类似 scp

- -v 显示同步详情
- -p 显示同步百分比
- --delete 默认情况下 source 中被删除的文件不会同步到 target 中，需要加上该参数才会同步删除命令
- --exclude 不同步符合[pattern]的文件，[pattern]表达式要匹配的相对路径下的文件名称，包含路径
  例如

  ```shell
  rsync -avp   --exclude='dir/*' /etc/ /data/etc/
  ```

- --include 要配置`--exclude`一起使用，表示不执行符合[pattern]的`--exclude`
  例如

  ```shell
  # 表示不同步/etc/log下的文件，除了/etc/log/important相关文件
  rsync -avp  --include='/etc/*' --include='/etc/log/important*' --exclude='/etc/log/*' /etc/ /data/etc/
  ```
