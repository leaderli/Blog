---
title: linux常用命令
date: 2020-05-13 21:53:18
categories: linux
tags:
---

### wall

向系统的全部在线用户发送信息 `wall [n] [messege]`

### write

向其他用户发送信息`write [options] <user> [ttyname]

### 命令可以作为参数传入 shell 脚本中

```shell
echo $1
echo $2
$1 $2 #直接执行
```

### 快速删除大文件

```shell
cat /dev/null > access.log
```

### 快速清空大文件内容

```shell
:> big.txt
```

### 清空文件内容

```shell
:> file.log
```

### 快速备份

逗号用来分割旧新文件后缀名

```shell
cp httpd.conf{,.bak}
cp  demo.{txt,sh}
```

### xargs 引用参数

```shell
ls *.jar|xargs -I {} echo {}

```

### awk

`awk`可以用来快速切割文本，默认使用空格分隔符。`'{}'`中对每行都进行操作
`$0`表示当前行，`$1`表示切割的数组的第一个元素，`'{print $1}'`表示打印第一个元素

`-F ’-‘` 增加切割符

### 查看内存信息

```shell
cat /proc/meminfo | grep MemTotal
```

### `apt-get`国内镜像

修改配置文件
`vim /etc/apt/sources.list`

```shell
deb http://mirrors.ustc.edu.cn/ubuntu/ xenial main restricted universe multiverse
deb http://mirrors.ustc.edu.cn/ubuntu/ xenial-security main restricted universe multiverse
deb http://mirrors.ustc.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse
deb http://mirrors.ustc.edu.cn/ubuntu/ xenial-proposed main restricted universe multiverse
deb http://mirrors.ustc.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse
deb-src http://mirrors.ustc.edu.cn/ubuntu/ xenial main restricted universe multiverse
deb-src http://mirrors.ustc.edu.cn/ubuntu/ xenial-security main restricted universe multiverse
deb-src http://mirrors.ustc.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse
deb-src http://mirrors.ustc.edu.cn/ubuntu/ xenial-proposed main restricted universe multiverse
deb-src http://mirrors.ustc.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse

```

然后执行`apt-get update`

### 查看`java`安装目录

```shell
han@ubuntu:/etc$ whereis java
java: /usr/bin/java /usr/share/java /usr/lib/jvm/java-8-openjdk-amd64/bin/java /usr/share/man/man1/java.1.gz
han@ubuntu:/etc$ ls -lrt /usr/bin/java
lrwxrwxrwx 1 root root 22 4月   2 15:54 /usr/bin/java -> /etc/alternatives/java
han@ubuntu:/etc$ ls -lrt /etc/alternatives/java
lrwxrwxrwx 1 root root 46 4月   2 15:54 /etc/alternatives/java -> /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
```

### 离线安装 git

```shell
rpm2cpio git-1.7.9.6-1.e16.rfx.x86_64.rpm|cpio -idmv
```

然后在`~/.bash_profile`中配置一个`alias`即可，或者在`PATH`更新`git`的`/usr/bin`路径

### 定时任务

为当前用户创建 cron 服务

1. 键入 crontab -e 编辑 crontab 服务文件

   例如 文件内容如下：

   ```css
    */2 * * * * /bin/sh  /home/admin/jiaoben/buy/deleteFile.sh
    :wq #保存文件并并退出
   ```

   /bin/sh /home/admin/jiaoben/buy/deleteFile.sh 这一字段可以设定你要执行的脚本，这里要注意一下 bin/sh 是指运行 脚本的命令 后面一段时指脚本存放的路径

2. 查看该用户下的 crontab 服务是否创建成功， 用 crontab -l 命令

3. 启动 crontab 服务

   一般启动服务用 /sbin/service crond start 若是根用户的 cron 服务可以用 sudo service crond start， 这里还是要注意 下 不同版本 Linux 系统启动的服务的命令也不同 ，像我的虚拟机里只需用 sudo service cron restart 即可，若是在根用下直接键入 service cron start 就能启动服务

4. 查看服务是否已经运行用 ps -ax | grep cron

5. crontab 命令

   ```css
   cron服务提供crontab命令来设定cron服务的，以下是这个命令的一些参数与说明:

   crontab -u //设定某个用户的cron服务，一般root用户在执行这个命令的时候需要此参数
   crontab -l //列出某个用户cron服务的详细内容
   crontab -r //删除某个用户的cron服务
   crontab -e //编辑某个用户的cron服务
   比如说root查看自己的cron设置:crontab -u root -l
   再例如，root想删除fred的cron设置:crontab -u fred -r
   在编辑cron服务时，编辑的内容有一些格式和约定，输入:crontab -u root -e
   进入vi编辑模式，编辑的内容一定要符合下面的格式:*/1 * * * * ls >> /tmp/ls.txt
   任务调度的crond常驻命令
   crond 是linux用来定期执行程序的命令。当安装完成操作系统之后，默认便会启动此任务调度命令。crond命令每分锺会定期检查是否有要执行的工作，如果有要执行的工作便会自动执行该工作。

   ```

6. cron 文件语法

   ```css
   分     小时    日       月      星期     命令
   0-59   0-23   1-31   1-12     0-6     command     (取值范围,0表示周日一般一行对应一个任务)

   记住几个特殊符号的含义:
   “*”代表取值范围内的数字,
   “/”代表”每”,
   “-”代表从某个数字到某个数字,
   “,”分开几个离散的数字
   ```

### 合并上下行

```shell
sed 'N;s/\n/ /' file.txt
```

### 清屏

clear 或者使用`ctrl + l`

### 查看当前是否 root

```shell
# 0既是root
echo $UID
```

### 合并多行

```shell
ls -1 | paste -sd "," -
```

### 显示当前 IP 的 hostname

```shell
echo $HOSTNAME

#显示当前ip
hostname -i
```

### 比较文件差异

```shell
# -y 左右对比
# --suppress-common-lines 忽略相同
diff -y alpha1.txt alpha2.txt --suppress-common-lines
```

### 显示 ASCII 表

```shell
man ascii
```

### watch

watch 指令可以间歇性的执行程序，将输出结果以全屏的方式显示，默认是 2s 执行一次。watch 将一直运行，直到被中断。

- -d | --differences 高亮显示差异部分
- --cumulative 高亮显示“sticky”
- -n  指定时间间隔
- -t | --no-title 不显示日期时间以及间隔秒数

### 重复执行上次命令

1. 使用上方向键，并回车执行。
2. 按 !! 并回车执行。
3. 输入 !-1 并回车执行。`!-n`执行上第 n 条命令
4. 按 Ctrl+P 并回车执行。

可以使用`sudo`，以 root 用户执行上条命令
`sudo !!`
`sudo !-1`
