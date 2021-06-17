---
title: linux常用命令
date: 2020-05-13 21:53:18
categories: linux
tags:
---

### echo

- -e 对输出内容进行格式调整，命令格式`echo -e "\033[字背景颜色;文字颜色m字符串\033[0m"`
  示例

  ```shell
  echo -e "\033[30m 黑色字 \033[0m"
  echo -e "\033[31m 红色字 \033[0m"
  echo -e "\033[32m 绿色字 \033[0m"
  echo -e "\033[33m 黄色字 \033[0m"
  echo -e "\033[34m 蓝色字 \033[0m"
  echo -e "\033[35m 紫色字 \033[0m"
  echo -e "\033[36m 天蓝字 \033[0m"
  echo -e "\033[37m 白色字 \033[0m"

  echo -e "\033[40;37m 黑底白字 \033[0m"
  echo -e "\033[41;37m 红底白字 \033[0m"
  echo -e "\033[42;37m 绿底白字 \033[0m"
  echo -e "\033[43;37m 黄底白字 \033[0m"
  echo -e "\033[44;37m 蓝底白字 \033[0m"
  echo -e "\033[45;37m 紫底白字 \033[0m"
  echo -e "\033[46;37m 天蓝底白字 \033[0m"
  echo -e "\033[47;30m 白底黑字 \033[0m"
  ```

### `sort`

对输出内容进行排序，默认情况下`sort`仅比较`ASCII`字符。

- -n 以数组大小来排序
- -k, --key=KEYDEF 指定使用第几个字段进行排序
- -t，--field-separator=SEP 使用 SEP 替换默认的空格作为间隔符
- -r 反向排序

```shell
~$ cat 1.txt
2   c
10  a
300 b

~$ sort 1.txt
10  a
2   c
300 b

~$ sort -n 1.txt
2   c
10  a
300 b

~$ sort -k 2 1.txt
10  a
300 b
2   c

~$ cat 2.txt
2:c
10:a
300:b

~$ sort  -t ':' -k 2  2.txt
10:a
300:b
2:c

```

### read

read 命令用于从标准输入读取数值。

```shell
#!/bin/bash

#这里默认会换行
echo "输入网站名: "
#读取从键盘的输入
read website
echo "你输入的网站名是 $website"
exit 0  #退出
```

- -p 参数，允许在 read 命令行中直接指定一个提示
- -s 选项能够使 read 命令中输入的数据不显示在命令终端上
- -t 参数指定 read 命令等待输入的秒数，当计时满时，read 命令返回一个非零退出状态。
- -n 参数设置 read 命令计数输入的字符。当输入的字符数目达到预定数目时，
- -e 参数，以下实例输入字符 a 后按下 Tab 键就会输出相关的文件名(该目录存在的)：

  ```shell
  $ read -e -p "输入文件名:" str
  输入文件名:a
  a.out a.py a.pyc abc.txt
  输入文件名:a
  ```

<hi>read 不能单独用在管道命令上</hi>

读取命令的输出，当指定多个变量时根据 IFS 规则分割变量

配合 while 使用

例如 while read line

read 通过输入重定向，把 file 的第一行所有的内容赋值给变量 line，循环体内的命令一般包含对变量 line 的处理；然后循环处理 file 的第二行、第三行。。。一直到 file 的最后一行。还记得 while 根据其后的命令退出状态来判断是否执行循环体吗？是的，read 命令也有退出状态，当它从文件 file 中读到内容时，退出状态为 0，循环继续惊醒；当 read 从文件中读完最后一行后，下次便没有内容可读了，此时 read 的退出状态为非 0，所以循环才会退出。

```shell
# line 仅仅是个变量名
while read line
do
   echo $line
done < file
```

另一种也很常见的用法：

```shell
command | while read line
do
   echo $line
done
```

如果你还记得管道的用法，这个结构应该不难理解吧。command 命令的输出作为 read 循环的输入，这种结构长用于处理超过一行的输出，当然 awk 也很擅长做这种事。

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

### 更改文件组

```shell
chown user:group file

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

ls *.jar|xargs -i  echo {}
#或
ls *.jar|xargs -I {} echo {}


```

### awk

awk的基本语法为
> pattern { action }

pattern用来确定是否执行action，awk命令是行驱动的，即针对每行文本，判断是否满足pattern，若满足则执行action。BEGIN和END，则是在第一行之前和最后一行之后执行的特殊的pattern

```awk
BEGIN { print "START" }
      { print         }
END   { print "STOP"  }
```

awk可使用变量

```awk
BEGIN {x=5}
{print x,$x}
END {print "done"}
```

执行

```shell
$ echo abc |awk -f 1.awk
5 
done
```

1. 基于位置的形参，类似shell脚本的命令行参数,使用IFS分割字符串作为函数参数，`$0`表示当前行，`$1`表示切割的数组的第一个元素，`'{print $1}'`表示打印第一个元素，可使用 `-F` 指定其他切割符

2. 支持常用的算术运算，字符串操作等。例如使用`<space>`连接字符串，例如`7 3`输出`73`

3. 内置函数

   - system 调用其他shell脚本

   ```shell
   echo abc |awk  '{print $1;system("echo "$1" >> 2.txt")}'
   #system中的脚本的变量是独立的，因此不可直接使用$1
   ```

   - exit 提前退出脚本

   ```shell
   #当行有abc时退出脚本
   echo abc |awk  '/abc/{exit}'
   ```

4. 使用正则表达式

   ```shell
   echo abc |awk  '/a/{print}' #正则匹配
   echo abc |awk  '!/a/{print}'#正则不匹配
   ```

5. 注意事项

   - awk脚本中不可以使用`'`

   - 一般情况下awk与grep无法配合使用，当grep使用参数`--line-buffered`时，则可以

   示例：

   根据搜索条件追踪相关日志

   ```shell
   #!/bin/bash
   log="$1"
   filter="$2"
   #06/04/2021 16:55:55:221 INFO - 010000012345678 0012345
   ucid=`awk '/'"$filter"'/{exit};END{print $5}' < <(tail -n0 -f "$log")`
   #06/04/2021 16:55:55:221 INFO - 010000012345678 End
   awk '{print};/'"$ucid"' End/{exit}' < <(tail -n0 -f "$log"|grep --line-buffered "$ucid")
   ```

### tail

- -n 输出最后几行 `-n0`即一个也不输出

```shell
awk '{print};/222/{exit}' < <(tail -f -n0 1.txt|grep --line-buffered 1)
#当向文件1.txt分别输入000,001,222,1222时，会
001
1222 #命令结束执行
```

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

然后在`~/.bash_profile`中配置一个`alias`即可，或者在`PATH`更新`git`的`/usr/bin`路径，例如`export PATH="$PATH:/usr/bin"`

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

示例

```shell
0,1,2 * * * * sh ~/demo.sh
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

### 关闭自动退出

```shell
# vi /etc/profile

unset TMOUT
# 或者
TMOUT=0

```

### 当前用户

```shell
# 当前登录终端字符设备号
tty
# 当前所有登录的用户
w


```

### tee

同时向某个文件写入内容

```shell
$ echo 123|tee 1.txt
123
$ cat 1.txt
123
```

- -a 追加

### file

猜测文件的编码

```shell
file -i *
1.txt:                           text/plain; charset=us-ascii
2.txt:                           text/plain; charset=utf-8
```

### iconv

转换文件编码

```shell
iconv -f gbk -t utf8  1.txt >  2.txt
```
