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

### 离线安装 rpm 忽略依赖

```shell
rpm -ivu *.rpm --nodeps --force
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

### expr

expr 命令是一个手工命令行计数器，用于在 UNIX/LINUX 下求表达式变量的值，一般用于整数值，也可用于字符串。

1、计算字串长度

```shell
$ expr length “this is a test”
14
```

2、抓取字串

```shell
$ expr substr “this is a test” 3 5
is is
```

3、抓取第一个字符数字串出现的位置

```shell
$ expr index "sarasara" a
2
```

4、整数运算

```shell
$ expr 14 % 9
5
$ expr 10 + 10
20
$ expr 1000 + 900
1900
$ expr 30 / 3 / 2
5
$ expr 30 \* 3 #使用乘号时，必须用反斜线屏蔽其特定含义。因为 shell 可能会误解显示星号的意义
90
$ expr 30 \* 3
$ expr: Syntax error
```

### 更新系统时间

```shell
# 同步上海的时间
ntpdate  ntp.api.bz
# 查看时区
date -R
```

### 查看文件格式

```shell
file xxx.txt
```

### 显示所有端口

```shell
netstat -tulpn
```

### 统计

```shell
$ wc freeswitch.md
#   行数     单词数  byte字节数
    1081    2968   41953 freeswitch.md
$ wc -m freeswitch.md
#   char字数
   30744 freeswitch.md
```

### sed

sed 命令是利用脚本来处理文本文件。sed 可依照脚本的指令来处理、编辑文本文件。
语法

```shell
sed [-hnV][-e<script>][-f<script 文件>][文本文件]
```

参数说明：

- -e 指定脚本的表达式，不会修改源文件，仅将修改后的内容输出到控制台
- -f 指定脚本的文件
- -i 指定脚本的表示式，会直接修改源文件
- -n 仅显示脚本所包含模板的行

其中脚本的指令支持

- a ：新增， a 的后面可以接字串，而这些字串会在新的一行出现(目前的下一行)～
- c ：取代， c 的后面可以接字串，这些字串可以取代 n1,n2 之间的行！
- d ：删除，因为是删除啊，所以 d 后面通常不接任何咚咚；
- i ：插入， i 的后面可以接字串，而这些字串会在新的一行出现(目前的上一行)；
- p ：打印，亦即将某个选择的数据印出。通常 p 会与参数 sed -n 一起运行～
- s ：取代，可以直接进行取代的工作哩！通常这个 s 的动作可以搭配正规表示法！例如 1,20s/old/new/g 就是啦！
- g ： 在行内进行全局替换
- w 将所选的行写入文件
- ! 对所选行以外的行执行
- l 列出非打印字符

脚本的指令可以在指定行范围内执行，例如

```shell
# 第四行行尾  新行+newline
sed -e  4a\newline testfile
# 第一到第四行行尾  新行+newline
sed -e  1，4a\newline testfile
# 最后一行 新行+newline
sed -e  $a\newline testfile


# 使用shell变量
var=hello
sed -e  '1a'${var} testfile
```

与 grep 一样，sed 也支持特殊元字符，来进行模式查找、替换。不同的是，sed 使用的正则表达式是括在斜杠线"/"之间的模式。
如果要把正则表达式分隔符"/"改为另一个字符，比如 o，只要在这个字符前加一个反斜线，在字符后跟上正则表达式，再跟上这个字符即可。例如：sed -n '\o^Myop' datafile
sed 的正则表达式语法支持功能比较少
| 元字符| 功能|
| :---- | :---- |
|^ |行首定位符|
|\$ |行尾定位符|
|. |匹配除换行符以外的单个字符 |
|\* |匹配零个或多个前导字符 |
|[] | 匹配指定字符组内的任一字符|
|[^]| 匹配不在指定字符组内的任一字符|
|& |`保存查找串以便在替换串中引用 s/my/**&**/ 符号&代表查找串。my 将被替换为**my**`|
|\< | 词首定位符 /\<my/ 匹配包含以 my 开头的单词的行|
|\> | 词尾定位符 /my\>/ 匹配包含以 my 结尾的单词的行|
|x\{m\} | 连续 m 个 x|
|x\{m,\}| 至少 m 个 x|
|x\{m,n\}| 至少 m 个，但不超过 n 个 x|

特殊字符

- `\` 新行

示例

```shell
# nl 输出行号 搜索包含root的行并打印
nl  testfile|sed -n '/root/p'
# nl 输出行号 搜索包含root的行并删除
nl  testfile|sed -n '/root/d'
# 使用正则替换
sed 's/pattern/replace/g'
```
