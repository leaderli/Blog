---
title: centos
date: 2020-07-04 09:08:41
categories: linux
tags:
---

## 安装 iso 镜像文件

虚拟机内 centos 挂载了 iso 的镜像后，使用

```shell
#可以看到挂载的iso文件
 $ blkid
/dev/sr0: UUID="2018-09-07-13-27-15-00" LABEL="Parallels Tools" TYPE="iso9660"
/dev/sda1: UUID="0ae18c31-cc28-4d90-bf6a-f65a96b2f57a" TYPE="xfs"
/dev/sda2: UUID="yaZCkD-Sek2-Xluo-rItp-Ed3V-vWuv-jOdAfy" TYPE="LVM2_member"
/dev/mapper/centos-root: UUID="3e9bbf71-0636-4505-b38f-7b88784faaab" TYPE="xfs"
/dev/mapper/centos-swap: UUID="8362ec6f-0e9a-4baa-8187-ea0d434de878" TYPE="swap"

$ mount /dev/sr0 /media/iso/
mount: /dev/sr0 is write-protected, mounting read-only
$ ls /media/iso/
install  install-gui  installer  kmods  tools  version

#可以开始安装了，安装过程中需要下载依赖，需要保持网络链接正常
$ ./media/iso/install
```

上述安装过程可能会失败，可能相关依赖无法自动安装成功，根据提示信息，将缺失的包依次安装后再次安装即可。

## 虚拟机无法链接网络

会自动获取 IP

```shell
#需要以root用户执行
$ dhclient -v
```

## yum

### yum 禁用 fastestmirror

```shell
$ sudo vi /etc/yum/pluginconf.d/fastestmirror.conf
#将`enabled=1`更改为`enabled=0`后
$ sudo yum clean all
```

### yum 安装依赖

使用 yum-builddep 提前安装某个库的依赖库

```shell
# 安装freeswitch的依赖库
yum-builddep -y freeswitch
```

### yum 清理无用依赖

```shell
package-cleanup
```

### 清理未完成的事务

安装过程失败或中断等，使用 yum-complete-transaction 清理未完成事务，需要 yum-utils 支持

```shell
yum install yum-utils
yum clean all
yum-complete-transaction --cleanup-only
```
