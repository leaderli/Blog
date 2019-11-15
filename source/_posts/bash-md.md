---
title: bash.md
date: 2019-10-15 20:38:27
categories: linux
tags:
  - bash
  - shell
---

## 重定向符

在`shell`中，每个进程都和三个系统文件 相关联：标准输入`stdin`，标准输出`stdout`、标准错误`stderr`，三个系统文件的文件描述符分别为`0，1、2`。所以这里`2>&1` 的意思就是将标准错误也输出到标准输出当中。

`shell`中可能经常能看到：`echo log > /dev/null 2>&1`,命令的结果可以通过`%>`的形式来定义输出,`/dev/null` ：代表空设备文件

_`1 > /dev/null 2>&1` 语句含义,_

1. `1 > /dev/null` ： 首先表示标准输出重定向到空设备文件，也就是不输出任何信息到终端，说白了就是不显示任何信息。
2. 2>&1 ：接着，标准错误输出重定向（等同于）标准输出，因为之前标准输出已经重定向到了空设备文件，所以标准错误输出也重定向到空设备文件。

_`cmd >a 2>a` 和 `cmd >a 2>&1` 为什么不同？_

1. `cmd >a 2>a` ：`stdout`和`stderr`都直接送往文件 `a` ，`a`文件会被打开两遍，由此导致`stdout`和`stderr`互相覆盖。`cmd >a 2>a` 相当于使用了`FD1`、`FD2`两个互相竞争使用文件 `a` 的管道；
2. `cmd >a 2>&1` ：`stdout`直接送往文件`a`，`stderr`是继承了`FD1`的管道之后，再被送往文件`a` 。`a`文件只被打开一遍，就是`FD1`将其打开。`cmd >a 2>&1` 只使用了一个管道`FD1`，但已经包括了`stdout`和`stderr`。从`IO`效率上来讲，`cmd >a 2>&1`的效率更高。

## 组合命令

可通过`&&`,让多个命令顺序执行，也可以通过`;`,不同的地方为`&&`当前一个命令执行成功后，才会执行后一个命令
例如

```shell
cd ~/Downloads/ && rm -rf temp`
```

## `rm`

在使用`cd dir && rm -rf file`时需要注意，当`dir`不存在时，`rm`会直接删除当前目录的文件，因此`rm`后跟文件绝对路径

## `ssh免密及执行远程命令`

操作机上生成秘钥`ssh-keygen -t rsa`,将会生成一对秘钥，将公钥内容追加到服务器的`~/.ssh/authorized_keys`中，
可通过**远程命令**`ssh user@example.com 'cat id_rsa.pub >> ~/.ssh/authorized_keys'`去执行,可以简单的使用`ssh-copy-id user@example.com`,这种方式
采用的是默认的`22`端口，拷贝的公钥是默认的`id_rsa.pub`

确保服务器的文件及目录权限

1. 设置 authorized_keys 权限  
   `chmod 600 authorized_keys`
2. 设置.ssh 目录权限  
   `chmod 700 -R .ssh`
3. 设置用户目录权限  
   `chomd go-w ~`

后续再执行`ssh`操作，或者`scp`等操作，则不需要再输入密码

通过系统日志文件我们可以查看无法登陆远程服务器的原因  
`tail /var/log/secure -n 20`

## 参数

命令可以作为参数传入 shell 脚本中

```shell
echo $1
echo $2
$1 $2
```

## `CURL`

```shell
response=$(curl --write-out %{http_code} --silent --output /dev/null servername)
echo $response

```

## 搜索

使用`**/`来递归搜索

```shell
ls -a **/*.log
```

全局搜索`locate`

递归查找指定文件的制定内容，显示文件名行号内容

```shell
grep -rn 'stream' . --include='*.cpp'
```

## `XARGS`

传递参数

```shell
ls *.jar|xargs -I {} jadx {} -d src
```

## `svn`

通过 `svn info`判断服务器和本地的版本号是否相同，可使用`grep`和`awk`组合

## 用`wget`递归下载

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

## 其他

命令查看当前目录下所有文件夹的大小 `-d` 指深度，后面加一个数值

```shell
du -d 1 -h
```

将输出的每一行加上行号。例如：`'cat 1.txt | nl'`，输出`1.txt`的文件并加上行号

排序`sort`

去重`uniq`,`uniq`默认仅会比较相邻的字符串

按文件大小顺序显示`ls -LS`

快速删除大文件

```shell
cat /dev/null > access.log
```
