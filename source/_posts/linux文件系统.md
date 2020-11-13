---
title: linux文件系统
date: 2020-05-13 23:38:32
categories: linux
tags:
---

linux 使用虚拟目录来管理硬盘，第一个被加载的硬盘被视为 root 驱动器，root 驱动包含虚拟目录的核心部分，在 root 驱动器上，linux 创建一个特殊的目录被称为 mount points,用来挂载其他硬盘。使用虚拟目录可以将所有文件都存储在一起，尽管他们可能存储在不同的硬盘上，通常来说，系统的核心文件存储在 root 驱动器上。

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

```shell
# 查看文件的inode节点编号，权限，创建日期，修改日期等
stat <file>

# 根据inode节点删除文件
find . -inum <inum> -exec rm -i {} \;
```

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

## 文件描述符

在 linux 中，对于每个进程(pid)，所有打开的文件都是通过文件描述符引用的，文件描述符就是从 0 开始的小的非负整数，内核用以标识一个特定进程正在访问的文件。当打开一个文件或创建一个文件，就会在`/proc/{pid}/fd`生成一个可以访问该文件的文件描述符，通过该文件描述符，可以直接去访问该文件

我们可以在`/proc/{pid}/fd`中查看到当前进程相关的文件描述符

```shell
#self 代表当前进程
$ ll /proc/self/fd
total 0
lrwx------. 1 root root 64 2020-09-20 06:36:30 0 -> /dev/pts/0
lrwx------. 1 root root 64 2020-09-20 06:36:30 1 -> /dev/pts/0
lrwx------. 1 root root 64 2020-09-20 06:36:30 2 -> /dev/pts/0
lr-x------. 1 root root 64 2020-09-20 06:36:30 3 -> /proc/4781/fd


#查看当前文件描述
$ lsof -a -p $$

# 查看文件描述符0，1，2
$ lsof -a -p $$ -d 0,1,2
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
bash    6145   li    0u   CHR  136,1      0t0    4 /dev/pts/1
bash    6145   li    1u   CHR  136,1      0t0    4 /dev/pts/1
bash    6145   li    2u   CHR  136,1      0t0    4 /dev/pts/1

```

Linux 进程默认情况下会有三个缺省打开的文件描述符

- 0（标准输入）`stdin`
- 1（标准输出）`stdout`
- 2（标准错误）`stderr`

我们可以看到`0`，`1`，`2`都执行`/dev/pts/0`，其代表当前登录的 bash 终端，也就是说默认情况下输入输出错误都是在终端的 bash 界面上操作的

```shell
$ tty
/dev/pts/0
```

当我们以另外一个用户登录并`tail -f`文件

```shell
$ ps -ef|grep tail
li       10570  7534  0 21:04 pts/2    00:00:00 tail -f 1.txt

# 我们查看其fd
$ ll /proc/10570/fd
total 0
lrwx------. 1 li li 64 2020-09-17 21:04:59 0 -> /dev/pts/2
lrwx------. 1 li li 64 2020-09-17 21:04:59 1 -> /dev/pts/2
lrwx------. 1 li li 64 2020-09-17 21:04:19 2 -> /dev/pts/2
lr-x------. 1 li li 64 2020-09-17 21:04:59 3 -> /home/li/1.txt
lr-x------. 1 li li 64 2020-09-17 21:04:59 4 -> anon_inode:inotify

# 我们向文件描述符写入一些msg
$ echo '0' > 0
$ echo '1' > 1
$ echo '2' > 2
$ echo '3' > 3

#我们可以在li这个终端上观察到

li$ tail -f 1.txt
0
1
2
3

#我们可以看到1.txt被写入了内容
li$ more 1.txt
3

```

## proc 目录

Linux 内核提供了一种通过 proc 文件系统，在运行时访问内核内部数据结构、改变内核设置的机制。proc 文件系统是一个伪文件系统，它只存在内存当中，而不占用外存空间。它以文件系统的方式为访问系统内核数据的操作提供接口。

1. cmdline 启动时传递给 kernel 的参数信息
2. cpuinfo cpu 的信息
3. filesystems 内核当前支持的文件系统类型
4. locks 内核锁住的文件列表
5. meminfo RAM 使用的相关信息
6. swaps 交换空间的使用情况
7. version Linux 内核版本和 gcc 版本
8. self 链接到当前正在运行的进程

proc 目录下一些以数字命名的目录，它们是进程目录。系统中当前运行的每一个进程都有对应的一个目录在 proc 下，以进程的 PID 号为目录名，它们是读取进程信息的接口。而 self 目录则是读取进程本身的信息接口，是一个 link。

1. `/proc/[pid]/cmdline` 该进程的命令及参数
2. `/proc/[pid]/comm` 该进程的命令
3. `/proc/[pid]/cwd` 进程工作目录
4. `/proc/[pid]/environ` 该进程的环境变量
5. `/proc/[pid]/exe` 该进程命令的实际命令地址
6. `/proc/[pid]/fd` 该进程打开的文件描述符
7. `/proc/[pid]/maps` 显示进程的内存区域映射信息
8. `/proc/[pid]/statm` 显示进程所占用内存大小的统计信息 。包含七个值，度量单位是 page(page 大小可通过 getconf PAGESIZE 得到)。举例如下：

   ```shell
   $ cat statm
   26999 154 130 15 0 79 0

   ```

   - a）进程占用的总的内存
   - b）进程当前时刻占用的物理内存
   - c）同其它进程共享的内存
   - d）进程的代码段
   - e）共享库(从 2.6 版本起，这个值为 0)
   - f）进程的堆栈
   - g）dirty pages(从 2.6 版本起，这个值为 0)

9. `/proc/[pid]/status` 包含进程的状态信息。

   ```shell
   $ cat /proc/2406/status
   Name:   frps
   State:  S (sleeping)
   Tgid:   2406
   Ngid:   0
   Pid:    2406
   PPid:   2130
   TracerPid:  0
   Uid:    0   0   0   0
   Gid:    0   0   0   0
   FDSize: 128
   Groups: 0
   NStgid: 2406
   NSpid:  2406
   NSpgid: 2406
   NSsid:  2130
   VmPeak:    54880 kB
   VmSize:    54880 kB
   VmLck:         0 kB
   VmPin:         0 kB
   VmHWM:     34872 kB
   VmRSS:     10468 kB
   VmData:    47896 kB
   VmStk:       132 kB
   VmExe:      2984 kB
   VmLib:         0 kB
   VmPTE:        68 kB
   VmPMD:        20 kB
   VmSwap:        0 kB
   HugetlbPages:          0 kB
   Threads:    11
   SigQ:   0/31834
   SigPnd: 0000000000000000
   ShdPnd: 0000000000000000
   SigBlk: 0000000000000000
   SigIgn: 0000000000000000
   SigCgt: fffffffe7fc1feff
   CapInh: 0000000000000000
   CapPrm: 0000003fffffffff
   CapEff: 0000003fffffffff
   CapBnd: 0000003fffffffff
   CapAmb: 0000000000000000
   Seccomp:    0
   Cpus_allowed:   f
   Cpus_allowed_list:  0-3
   Mems_allowed:   00000000,00000001
   Mems_allowed_list:  0
   voluntary_ctxt_switches:    2251028
   nonvoluntary_ctxt_switches: 18031
   ```

## mdls

查看文件的 meta 信息
