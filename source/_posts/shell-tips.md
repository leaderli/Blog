---
title: shell-tips
date: 2020-06-04 22:25:37
categories: linux
tags:
---

## 多命令

多个命令用`;`分割，可以一起执行

## curl

### 显示请求详情

```shell
curl -v http://example.com
```

示例

```shell
~$ curl -v http://centos7:8888
* Rebuilt URL to: http://centos7:8888/
*   Trying 10.211.55.5...
* Connected to centos7 (10.211.55.5) port 8888 (#0)
> GET / HTTP/1.1
> Host: centos7:8888
> User-Agent: curl/7.43.0
> Accept: */*
>
< HTTP/1.1 502 Bad Gateway
< Server: nginx/1.19.0
< Date: Fri, 19 Jun 2020 13:33:46 GMT
< Content-Type: text/html
< Content-Length: 157
< Connection: keep-alive
<
<html>
<head><title>502 Bad Gateway</title></head>
<body>
<center><h1>502 Bad Gateway</h1></center>
<hr><center>nginx/1.19.0</center>
</body>
</html>
* Connection #0 to host centos7 left intact

```

### 重定向

当使用`curl`或者在 java 中请求一个远程接口时，当服务器将请求转发即`redirect`时，将无法得到返回报文。
服务器的返回头中，会有 redirect 的目标地址。
若使用 curl，我们可以使用`curl -iL --max-redirs 1 http://example.com`,将返回头打印出来

```shell
HTTP/1.1 301 Moved Permanently
Date: Thu, 18 Apr 2019 02:39:59 GMT
Transfer-Encoding: chunked
Connection: keep-alive
Location: https://example.com/about
```

返回头中的`Location`，即重定向的地址。我们再次请求重定向的地址，即可得到想要的结果

### 获取 http 返回码

```shell
response=$(curl --write-out %{http_code} --silent --output /dev/null servername)
echo $response

```

## 死循环

无线循环并睡眠 1 秒

```bash

#!/bin/bash
while [ 1 ]
do
      sleep 1s
done

```

## 后台进程

`nohup`可以用来将脚本在后台运行，默认会将脚本的输出信息打印到`nohup.out`中

若需要不输出日志信息可以使用

```shell
nohup ./program >/dev/null 2>&1 &
```

## ls

按文件大小顺序显示

`ls -LS`

## nl

将输出的每一行加上行号。例如：`'cat 1.txt | nl'`，输出`1.txt`的文件并加上行号

## `rm`

在使用`cd dir && rm -rf file`时需要注意，当`dir`不存在时，`rm`会直接删除当前目录的文件，因此`rm`后跟文件绝对路径

## 向远程服务器文件写入

使用管道符基本用法如

```shell
<command> | ssh user@remote-server "cat > output.txt"
```

例如

```shell
echo "qwerty" | ssh user@Server-2 "cat > output.txt"
ssh user@Server-1 "<command>" | ssh user@Server-2 "cat > output.txt"
```

## `ssh免密及执行远程命令`

操作机上生成秘钥`ssh-keygen -t rsa`,将会生成一对秘钥，将公钥内容追加到服务器的`~/.ssh/authorized_keys`中，
可通过**远程命令**`cat ~/.ssh/id_rsa.pub |ssh user@example.com 'cat >> ~/.ssh/authorized_keys'`去执行,可以简单的使用`ssh-copy-id user@example.com`,这种方式
采用的是默认的`22`端口，拷贝的公钥是默认的`id_rsa.pub`

确保服务器的文件及目录权限

1. 设置 authorized_keys 权限  
   `chmod 600 authorized_keys`
2. 设置.ssh 目录权限  
   `chmod 700 -R .ssh`
3. 设置用户目录权限  
   `chmod go-w ~`
4. 检查 AuthorizedKeysFile 配置是否启用 authorized_keys

   ```shell
   $ cat /etc/ssh/sshd_config |egrep AuthorizedKeysFile
   #AuthorizedKeysFile    .ssh/authorized_keys
   ```

   把下面几个选项打开

   ```conf
   AuthorizedKeysFile  .ssh/authorized_keys
   ```

后续再执行`ssh`操作，或者`scp`等操作，则不需要再输入密码

通过系统日志文件我们可以查看无法登陆远程服务器的原因

```shell
tail /var/log/secure -n 20
#也可以在使用ssh时将详情打印出来
ssh -vvv root@192.168.0.1
```

默认情况下，ssh 去`~/.ssh/`目录下去找私钥，有时候无法，可以使用`ssh-agent`将私钥加载到内存中

```shell
# 启动ssh代理
$ eval `ssh-agent`
# 将私钥注册到agent
$ ssh-add  ~/.ssh/id_rsa
```

## `XARGS`

传递参数

```shell
ls *.jar|xargs -I {} jadx {} -d src
```

## `top`

使用`top`命令查看进程占用情况，可配合`grep`来实现查看想要的信息
`top|grep java`

## `svn`

通过 `svn info`判断服务器和本地的版本号是否相同，可使用`grep`和`awk`组合

## WGET

用`wget`递归下载

`wget -r -np --reject=html www.download.example`
或者可以把`reject`换做 `--accept`=`iso,c,h`，表示只接受以此结尾的文件，分隔符为逗号`（comma-separated）`

## `AWK`

默认情况下`awk`以空格进行分割字符串，`-F`，可以指定分割符  
`‘{print $1}’`，输出第几个分割字符

截取除第一位之后的所有元素

```shell
echo  1 2 3 4 5|awk '{first = $1; $1 = ""; print $0 }'
```

示例：

```shell
more 1.txt|awk -F ',' '{print $2}'
```

使用条件判断筛选数据

```shell
awk 'length($2) ==12 && $2 > 20190101 && $2 <= 20191212 {print $0}'


```

## `history`

设置历史记录不重复

```bash
export HISTIGNORE='ls:bg:fg:history'
shopt -s histappend # append new history items to .bash_history
export HISTCONTROL=ignoreboth:erasedups
export HISTFILESIZE=10000       # increase history file size (default is 500)
export HISTSIZE=${HISTFILESIZE} # increase history size (default is 500)
# ensure synchronization between Bash memory and history file
#export PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"
shopt -s cmdhist
# Append new history lines, clear the history list, re-read the history list, print prompt.
export PROMPT_COMMAND="history -n; history -w; history -c; history -r;history -a; $PROMPT_COMMAND"
```

## `uniq`

去重`uniq`,`uniq`默认仅会比较相邻的字符串

会统计重复的次数

```bash
uniq -c
```

## 显示所有系统变量

```shell
env
```

## 显示内存占用较多的进程

```shell
ps -aux --sort=-rss|head 10
```

## type

查看命令的详情

- -a 列出包含别名(alias)在内的指定命令名的命令
- -p 显示完整的文件名称
- -t 显示文件类型，其文件类型主要有两种，一种是 builtin，为 bash 的内置命令；另一种是 file，为外部命令

## 计算 shell 执行时间

`time [command]`

## 读取文件内容到变量

```shell
content=`cat file.txt`
```

## echo

不换行输出

```shell
`echo -n 'hello:'
```

## 判断当前是否为 root 用户执行

```shell
#!/bin/bash
if [[ $EUID -eq 0 ]]; then
   echo "this is root"
   exit 1
fi
```

## 获取时间戳

使用`date --help`查看具体语法

节选部分

```shell
  %p   locale's equivalent of either AM or PM; blank if not known
  %P   like %p, but lower case
  %r   locale's 12-hour clock time (e.g., 11:11:04 PM)
  %R   24-hour hour and minute; same as %H:%M
  %s   seconds since 1970-01-01 00:00:00 UTC
  %S   second (00..60)

```

```shell
timestamp() {
  date +"%s" # seconds since 1970-01-01 00:00:00 UTC

}
```

## mktemp

可以使用 mktemp 命令创建临时文件，文件名会自动生成

```shell
#根据后面的X个数随机生成n个字符的名称
tempfile=`mktemp -t tmp.XXXXXX`
echo $tempfile
tempdir=`mktemp -d tmp.XXXXXX`
cd $tempdir
#/tmp/tmp.dOH3ir

```

## 判断是否连接网络

```shell
ping -o -t 2 www.baidu.com >&/dev/null;
if ((  $? == 0 )) ;then #判断ping命令执行结果 为0表示ping通
echo ok
else
echo no
fi
```
