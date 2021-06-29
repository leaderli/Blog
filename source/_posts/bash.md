---
title: bash.md
date: 2019-10-15 20:38:27
categories: linux
tags:
  - bash
  - shell
---

## 概述

每条`shell`命令执行都会有个状态码`0`表示成功，`1`表示失败。可以使用`$?`得到上一条命令的执行结果来决定是否执行后续命令，快速的用法是使用`&&`,`||`

{% post_link shell-变量 %}

## 重定向符

重定向符有四个

- `>` 将输出保持到文件中，会覆盖已存在文件，可以使用`set -C`禁止覆盖
- `>>` 将输出追加到文件中
- `<` 将文件内容作为输入源
- `<<` [here 文档](<#here\ 文档>)

linux 中默认输入输出是指向文件描述符`0`,`1`,`2`的，当我们需要将
所以`2>&1` 的意思就是将标准错误也输出到标准输出当中。

默认情况下输出的源文件描述符为`0`，

```shell
$ ls
1.txt
# 1和>没有空格
# 完整的表达式为 cat 1.txt  2.txt 1> 3.txt
$ cat 1.txt  2.txt > 3.txt
cat: 2.txt: No such file or directory
$ more 3.txt
1.txt
```

`shell`中可能经常能看到：`echo log > /dev/null 2>&1`,命令的结果可以通过`>`的形式来定义输出,`/dev/null` ：代表空设备文件

- `1 > /dev/null 2>&1` 语句含义

  1. `1 > /dev/null` ： 首先表示标准输出重定向到空设备文件，也就是不输出任何信息到终端，说白了就是不显示任何信息。
  2. 2>&1 ：接着，标准错误输出重定向（等同于）标准输出，因为之前标准输出已经重定向到了空设备文件，所以标准错误输出也重定向到空设备文件。

- `cmd >a 2>a` 和 `cmd >a 2>&1` 为什么不同？

  1. `cmd >a 2>a` ：`stdout`和`stderr`都直接送往文件 `a` ，`a`文件会被打开两遍，由此导致`stdout`和`stderr`互相覆盖。`cmd >a 2>a` 相当于使用了`FD1`、`FD2`两个互相竞争使用文件 `a` 的管道；
  2. `cmd >a 2>&1` ：`stdout`直接送往文件`a`，`stderr`是继承了`FD1`的管道之后，再被送往文件`a` 。`a`文件只被打开一遍，就是`FD1`将其打开。`cmd >a 2>&1` 只使用了一个管道`FD1`，但已经包括了`stdout`和`stderr`。从`IO`效率上来讲，`cmd >a 2>&1`的效率更高。

### 使错误日志重定向到正常输出

```shell
sh error.sh > messge.log 2>&1
#也可以这样写
sh error.sh  1>$messge.log
```

### 当前脚本永久重定向

```shell
exec 1>1.log
exec 2>1.log

#关闭某个文件描述符
exec 1>$-

```

### here 文档

又称作 heredoc、hereis、here-字串或 here-脚本，here 文档最通用的语法是<<紧跟一个标识符，从下一行开始是想要引用的文字，然后再在单独的一行用相同的标识符关闭。在 Unix shell 里，here 文档通常用于给命令提供输入内容。

在以下几个例子中，文字用 here 文档传递给 tr 命令。

```shell
$ tr a-z A-Z <<END_TEXT
 > one two three
 > uno dos tres
 > END_TEXT
 ONE TWO THREE
 UNO DOS TRES
```

默认地，会进行变量替换和命令替换：

```shell
 $ cat << EOF
 > Working dir $PWD
 > EOF
 Working dir /home/user
```

### 管道符

使用管道符，可以将一个命令的输出重定向到另一个命令的输入，默认情况下只会讲标准输出(fd 为 1)重定向到另一个命令

```shell
command1|command2
```

当 command2 命令结束或被打断时，从 command1 接收的`/dev/stdout`的管道则会销毁，但是并不会马上打断 command1 的执行。我们可以使用进程替代

```shell
#< <直接有空格
awk '/STOP/{exit}1' < <(tail -f logfile)
```

### 进程替换

- `<(command_list)` 该表达式表示 command_list 命令的执行的 output 将指向一个`/dev/fd/<n>`下的文件
- `>(command_list)` 该表达式表示 command_list 命令前的 output 指向一个`/dev/fd/<n>`下的文件,command_list 的 input 则为这个文件的内容

可以使用重定向符去操作`/dev/fd/<n>`

例如

```shell
diff <(ls dirA) <(ls dirB)
```

```shell
$ cat <(ls)
1.txt
2.txt

$ echo  <(ls)
/dev/fd/63

#重定向
$ while read lines ; do echo $lines ;done < <(ls)

1.txt
2.txt

$ cat
```

替换进程命令需要在脚本上声明

```shell
!#/bin/bash
```

或者使用`bash xxx.sh`去执行

## 组合命令

可通过`&&`,让多个命令顺序执行，也可以通过`;`,不同的地方为`&&`，当前一个命令的返回码为 0 时，才会执行后一个命令
例如

```shell
cd ~/Downloads/ && rm -rf temp`
```

`||`,与`&&`相反，当前一个命令的返回码大于 0 才执行第二条

`[]`也可以组合使用

```shell
[ condition1 ] && [ condition2 ]
[ condition1 ] || [ condition2 ]
```

## `[` 和`[[`

`[`是 shell 的一个内置命令（和命令 test 是一样的），`[`到`]`之间都被视为`[`的参数
`[[`是一个关键字，它的参数会根据一定规则进行处理，其他的和`[`是一样的

所以下述用法就是不对的

```shell
$ name="here and there"
$ [ -n $name ]
>  then
>  echo not empty
>  fi
bash: [: too many arguments

#正确的用法
$ [ -n "$name" ]
>  then
>  echo not empty
>  fi
not empty

# test

$ test -n "$name"
>  then
>  echo not empty
>  fi
not empty
```

`[`的常用语法有

1. 判断

   | 操作符 | 含义                                        |
   | -----: | :------------------------------------------ |
   |     -a | 检查文件是否存在                            |
   |     -b | 检查是否为块特殊文件[1]                     |
   |     -c | 检查是否为字符特殊文件[2]                   |
   |     -d | 检查是否为文件夹                            |
   |     -e | 检查文件是否存在                            |
   |     -f | 检查是否为常规文件[3]                       |
   |     -g | 检查 gid[4]是否被置位                       |
   |     -G | 检查是否有相同的组 ID                       |
   |     -k | 检查防删除位是否被置位                      |
   |     -L | 检查是否为符号链接[5]                       |
   |     -n | 判断字符串长度是否不为 0                    |
   |     -O | 检查文件是否被当前进程的 user ID 拥有       |
   |     -p | 检查文件是否为 FIFO[6]特殊文件或命名管道[7] |
   |     -r | 检查文件是否可读                            |
   |     -s | 检查文件大小是否大于 0                      |
   |     -S | 检查文件是否为 socket 文件                  |
   |     -t | 检查文件描述符是否打开                      |
   |     -u | 检查 uid[8]是否被置位                       |
   |     -w | 检查文件是否可写                            |
   |     -x | 检查文件是否可执行                          |
   |     -z | 判断字符串长度是否为 0                      |

   示例

   ```shell
   if [  -e "$myPath"]; then
     echo 'ok'
   fi

   if [ ! -f /tmp/foo.txt ]; then
       echo "File not found!"
   fi

   if test -n "$name"
   then
   echo name not empty
   fi

   if test -z "$name"
   then
   echo name is empty
   fi
   ```

2. 逻辑判断

   在 linux 中 命令执行状态：0 为真，其他为假

   | 操作符 | 解释              |
   | -----: | :---------------- |
   |    -eq | 等于              |
   |    -ne | 不等于            |
   |    -gt | 大于 （greater ） |
   |    -lt | 小于 （less）     |
   |    -ge | 大于等于          |
   |    -le | 小于等于          |

`[[`的用法示例

```shell
#比较两个字符串

if [[ "$a" > "$b" ]];then
  echo ''
fi
```

## 数值运算

在 bool 运算中使用`((expression))`

```shell
var=10
if (( $var ** 2 > 90))
then
   echo ok
fi


num=$(( 1 + 1))
# 等效
num=$[ 1 + 1 ]



```

## case

```shell
case 值 in
模式1)
    command1
    command2
    command3
    ;;
模式2|模式3）
    command1
    command2
    command3
    ;;
*)
    command1
    command2
    command3
    ;;
esac
```

## 变量

### 变量引用

一般情况下使用 `$variable`来引用变量值，它是`${variable}`的一种缩写

- `${VALUE:-WORD}`：当变量未定义或者值为空时，返回值为 WORD 的内容，否则返回变量的值。
- `${VALUE:=WORD}`：当变量未定义或者值为空时，返回 WORD 的值的同时并将 WORD 赋值给 VALUE，否则返回变量的值。
- `${VALUE:+WORD}`：当变量已赋值时，其值才用 WORD 替换，否则不进行任何替换。
- `${VALUE:?MESSAGE}`：当变量已赋值时，正常替换。否则将消息 MESSAGE 送到标准错误输出（若此替换出现在 SHELL 程序中，那么该程序将终止运行）

  ```shell
  #当变量为空时，name 就为 hello
  name=${variable:-hello}
  #当变量为空时，variable被赋为hello，且返回hello
  name=${variable:=hello}
  #当变量为不为空时，返回hello
  name=${variable:+hello}
  #当变量为不为空时，variable被赋为hello，否则输出错误信息
  name=${variable:+hello}
  ```

### 基于位置的参数

命令可以作为参数传入 shell 脚本中

```shell
echo $1
echo $2
$1 $2
```

shell 脚本可以读取执行时传入的参数

- `$0` 表示`shell`脚本本身
- `$[n]` 表示`shell`第几个参数，`$10` 不能获取第十个参数，获取第十个参数需要`${10}`。当 n>=10 时，需要使用`${n}`来获取参数。
- `$*` 表示所有参数，将所有参数视为一个单词
- `$@` 表示所有参数，将所有参数视为一个数组
- `${@:n}` 表示除 n 前的所有参数，例如`${@:2}`表示除了第一个参数之外的所有参数
- `$#` 获取变量个数
- `$?` 显示最后命令的退出状态。0 表示没有错误，其他任何值表明有错误
  |code|描述|
  |:-|:-|
  |0|成功执行|
  |1|常规错误|
  |2|shell 错误使用|
  |126|无法执行|
  |127|找不到命令|
  |128|错误的退出参数|
  |128+|linux 信号错误|
  |130+|命令被 Ctl-C 终止|
  |255|退出状态溢出|
- `$$` 脚本运行的当前进程 ID 号
- `$!` 后台运行的最后一个进程的 ID 号
- `*` 表示当前目录所有文件，相当于 ls
- `shift n`向左移动 n 个参数

  ```shell
  ~$ cat 1.sh
  echo $_
  shift
  echo \$_
  ~$ sh 1.sh 1 2 3
  1 2 3
  2 3
  ```

### getopts 获取参数

getopts(shell 内置命令)，不能直接处理长命令（如：--prefix=/home 等，如有需要可以使用 getopt）

- getopts 有两个参数，第一个参数是一个字符串，包括字符和`:`，每一个字符都是一个有效的选项，getopts 从命令中获取这些参数，并且删去了 `-`
- 字符后面带有`:`，表示这个字符有自己的参数（有自己参数的选项，不能和别的选项写在一起）。
- `$OPTARG` 总是存储有参数的选项的参数值
- `$OPTIND`总是存储原始参数`$*`下一个要处理的元素位置
- 第一个冒号表示忽略错误

```shell
#!/bin/bash

echo original parameters=[$*]
echo original OPTIND=[$OPTIND]
while getopts ":a:bc" opt
do
    case $opt in
        a)
            echo "this is -a option. OPTARG=[$OPTARG] OPTIND=[$OPTIND]"
            ;;
        b)
            echo "this is -b option. OPTARG=[$OPTARG] OPTIND=[$OPTIND]"
            ;;
        c)
            echo "this is -c option. OPTARG=[$OPTARG] OPTIND=[$OPTIND]"
            ;;
        ?)
            echo "there is unrecognized parameter."
            exit 1
            ;;
    esac
done
#通过shift $(($OPTIND - 1))的处理，$*中就只保留了除去选项内容的参数，
#可以在后面的shell程序中进行处理
shift $(($OPTIND - 1))

echo remaining parameters=[$*]
echo \$1=[$1]
echo \$2=[$2]

# 执行脚本
$ bash getopts.sh -a 12 -b -c file1 file2
original parameters=[-a 12 -b -c file1 file2]
original OPTIND=[1]
this is -a option. OPTARG=[12] OPTIND=[3]
this is -b option. OPTARG=[] OPTIND=[4]
this is -c option. OPTARG=[] OPTIND=[5]
remaining parameters=[file1 file2]
$1=[file1]
$2=[file2]


#可以z这样缩写
$ bash getopts.sh  -bca 12 file1 file2
original parameters=[-bca 12 file1 file2]
original OPTIND=[1]
this is -b option. OPTARG=[] OPTIND=[1]
this is -c option. OPTARG=[] OPTIND=[1]
this is -a option. OPTARG=[12] OPTIND=[3]
remaining parameters=[file1 file2]

#如果这样写就不对
$ bash getopts.sh  -abc 12  file1 file2
original parameters=[-abc 12 file1 file2]
original OPTIND=[1]
this is -a option. OPTARG=[bc] OPTIND=[2]
remaining parameters=[12 file1 file2]
$1=[12]
$2=[file1]
```

### 标准的参数选项

linux 有一些标准的参数选项，通过该选项我们大概可以知道该参数的含义

| option | description              |
| :----- | :----------------------- |
| -a     | 显示所有                 |
| -c     | 计数                     |
| -d     | 指定一个目录             |
| -e     | 扩展                     |
| -f     | 读取一个指定的文件       |
| -h     | 帮助信息                 |
| -i     | 忽略大小写               |
| -l     | 展示一个长格式的输出信息 |
| -n     | 使用非交互模式           |
| -o     | 指定一个输出文件         |
| -q     | 不打印输出               |
| -r     | 递归                     |
| -s     | 不打印输入               |
| -v     | 输出详细信息             |
| -x     | 包含某个对象             |

### 数组 arrays

```shell
a=(1 2 3 4)
echo $a        #取第一个元素
echo ${a[1]}   #取角标为1的元素
a[1]=100       #赋值
echo ${a[*]}   #取所有元素
unset a[1]     #移除角标1的元素
echo ${a[*]}
unset a        #移除整个array
echo ${a[*]}
# 1
# 2
# 1 100 3 4
# 1 3 4
#

```

```shell
#!/bin/bash

string="hello,shell,split,test"
array=(${string//,/ })

# 迭代数组
for var in ${array[@]}
do
   echo $var
done



```

### 字符串变量相关

- 字符串长度

  ```shell
  len=${#variable}
  ```

- `${variable#*string}`从左往右，删除最短的一个以 string 结尾的子串，即截取第一个 string 子串之后的字符串
- `${variable##*string}`从左往右，删除最长的一个以 string 结尾的子串，即截取最后一个 string 子串之后的字符串
- `${variable%string*}`从右往左，删除最短的一个以 string 开头的子串，即截取最后一个 string 子串之前的字符串
- `${variable%%string*}`从右往左，删除最长的一个以 string 开头的子串，即截取第一个 string 子串之前的字符串
- `${variable/OLD/NEW}`或`${variable//OLD/NEW}`：用 NEW 子串替换 VALUE 字符串中匹配的 OLD 子串。

```bash
TEST=123abc456abc789
echo ${TEST#*abc}  #删掉 123abc 剩下 456abc789
echo ${TEST##*abc} #删掉 123abc456abc 剩下"789
echo ${TEST%abc*}  #删掉 abc789 剩下 123abc456
echo ${TEST%%abc*} #删掉 abc456abc789 剩下 123
```

固定位置截取

`${varible:start:len}`:截取变量 varible 从位置 start 开始长度为 len 的子串。第一个字符的位置为 0。

```bash
TEST=123abc456abc789
echo ${TEST:0:3} #123
echo ${TEST:3:3} #abc"
```

包含

```shell

origin='12345677899'
sub=`567`

if [[ "$origin" == *"$sub"*]] #顺序不能反
then
   echo ok
fi


```

### 引号

1. 单引号`''`,被称作弱引用，在`'`内的字符串会被直接使用，不会被替换。

   ```shell
   echo ''\'''
   #输出结果
   # '
   ```

   在单引号中转义单引号

   ```shell
   alias rxvt='urxvt -fg '"'"'#111111'"'"' -bg '"'"'#111111'"'"
   #                     ^^^^^       ^^^^^     ^^^^^       ^^^^
   #                     12345       12345     12345       1234
   ```

   上述转义是如何被解析的

   1. ' 第一个引用的结束，使用单引号
   2. " 第二个引用的开始，使用双引号
   3. ' 被引用的字符
   4. " 第二个引用的结束，使用双引号
   5. ' 第三个引用的开始

2. 双引号`""`,被称做强引用，在`"`的字符串的变量引用会被直接替换为实际的值

3. 反引号\`\`, 反引号括起来的字串被 Shell 解释为命令，在执行时，Shell 首先执行该命令，并以它的标准输出结果取代整个反引号（包括两个反引号）部分，也可以使用`$()`达到同样的效果，shell 会以子进程的方式去调用被替换的命令，其替换后的值为子进程命令的 stdout 输出，其文件描述符为`1`，

### 容错断言

如果一个或多个必要的环境变量没被设置的话, 就打印错误信息.下面是两种方式

```shell
${HOSTNAME?}  #正常
${HOSTNAME1?} #HOSTNAME1: parameter null or not set
```

### 设置静态变量

```shell
readonly MY_PATH=/usr/bin
```

### 变量使用`*`

在编写 shell 脚本的过程中，有的时候难免会用到一些变量值被定义为(`*`)的变量，但是当我们试图引用这个变量的时候 bash 有默认会把（`*`）替换成当前目录下的所有文件名的列表，如下：

```shell
[root@vm_102 ~]# a=*
[root@vm_102 ~]# echo $a
anaconda-ks.cfg install.log install.log.syslog
[root@vm_102 ~]# ls
anaconda-ks.cfg  install.log  install.log.syslog
```

这个时候我们可以考虑一个问题：这里的（`*`）是在哪一步被替换成当前目录下面的文件列表的呢：是在第一步，变量赋值的时候就被替换的呢还是说，在 echo 变量值的时候被替换的呢？
事实是这样子的：
1、当变量复制的时候，bash 会直接将(`*`)赋值给变量 a；
2、但是在第二步引用变量的时候，bash 默认会把(`*`)替换成当前目录下的所有文件的列表，大家可以这么实验一下：

```shell
[root@vm_102 ~]# echo *
anaconda-ks.cfg install.log install.log.syslog
```

## 输入

```shell
echo 'please input your name'
read name
echo 'you name is '$name
```

对于有多行输出的脚本，可以使用`while read`来读取每一行，每一个字端

```shell
git status -s |while read mode file;
do
   echo $mode
   echo $file
done


```

从管道中读取输入

```shell
name=`git branch|while read branch
do
   if test "dev" == "$branch"
   then
      echo "dev"
      break
   fi
done
`
```

## 捕获信号

```shell
#!/bin/bash
#捕获EXIT信号
trap "echo byebye" EXIT
sleep 100;
#移除捕获EXIT信号
trap - EXIT

```

```shell
# 列出所有信号，trap可以使用信号的编号
$ trap -l
# 向某个进程发出指定信号
$ kill -s <signal> <pid>
```

例如

```shell
# 杀掉某进程
kill -9  12345

# 一个简单的守护进程

while kill -0 "$pid" >/dev/null 2>&1
do
   echo 'progress is running'
   sleep 1
done

echo 'progress terminated'

```

当使用 ctl-c 中断时，会执行 trap 里的命令

忽略信号：

```shell
#如果陷阱列出的命令是空的，指定的信号接收时，将被忽略。例如，下面的命令：
$ trap '' 2
```

## 函数

shell 中函数的有两种方式

```shell

function name{
   commands
}

name(){
   commands
}

```

1. 返回值（仅允许为 0~255 的数值），可以显示加：return 返回，如果不加，将以最后一条命令运行结果，作为返回值。
2. 函数返回值在调用该函数后通过 \$? 来获得。
3. 调用函数时可以向其传递参数。在函数体内部，通过 $n 的形式来获取参数的值，例如，$1 表示第一个参数，\$2 表示第二个参数
4. 函数的输出可以使用替换命令来得到，即使用`` `command` ``或`$(command)`（不是所有 linux 都支持`$()`)
5. 可以使用`local`声明函数内部的变量，使其作用域仅限于函数内

示例

```shell
fun(){
   echo $1
   return 1
}

fun 'hello'
echo $?

```

### 引入外部脚本

格式
`. filename` 注意点号`.`和文件名中间有一空格
或
`source filename`

## 脚本运行时参数

在写脚本的一开始加上`set -xeuo pipefail`，一般用于调试脚本

示例

```shell
#!/bin/bash
set -x
...
```

> -x: 在执行每一个命令之前把经过变量展开之后的命令打印出来
> -e: 在遇到一个命令失败时，立即退出
> -u: 试图使用未经定义的变量，立即退出
> -o pipefail: 只要管道中的一个子命令失败，整个管道命令就失败。

## 循环

c 风格的 for 循环

```shell
for (( a=1;a<10;a++))
do
   echo $a;
done
```

### break 和 continue

`break n`可以跳出 n 层循环，`continue n`的用法类似

```shell
for (( a=1;a<5;a++))
do
   for (( b=1;b<5;b++))
   do
      if [ $a -gt 2 ] && [ $b -gt 3 ]
      then
         break 2
         # continue 2
      fi
   done
done
```

### done

可以在 done 处使用重定向符，管道符，类似的用法可以在 if 的结束 fi 上使用，case 的 esac 处使用

```shell
for (( a=1;a<100;a++))
do
   echo $a;
done |grep 5

for (( a=1;a<100;a++))
do
   echo $a;
done  > 1.txt


if [ -n "$1" ]
then
echo $1
fi > 1.txt

```

## 数据库相关

查询数据库字段将其赋值给变量

```shell
db2 "connect to ${1} user ${2} using ${3}"
db2 "set schema ${4}"

db2 -x "select status,timestamp from results where id = 1" | while read status timestamp ; do
    echo $status
    echo $timestamp
done
```

## 图形化

### 菜单

select 命令只需要一条命令就可以创建出菜单，然后获取输入的答案并自动处理。
命令格式如下：

```shell
select variable in list
do
commands
done
```

list 参数是由空格分隔的文本选项列表，这些列表构成了整个菜单。select 命令会将每个列表项显示成一个带编号的选项，然后为选项显示一个由 PS3 环境变量定义的特殊提示符。

例如：

```shell
#!/bin/bash
# using select in the menu

function diskspace {
 clear
 df -k
}

function whoseon {
 clear
 who
}

function memusage {
 clear
 cat /proc/meminfo
}

PS3="Enter an option: "
select option in "Display disk space" "Display logged on users" "Display memory usage" "Exit program"
do
 case $option in
 "Exit program")
 break ;;
 "Display disk space")
 diskspace ;;
 "Display logged on users")
 memusage ;;
 "Display memory usage"）
 memusage ;;
 *)
 clear
 echo "Sorry, wrong selection";;
 esac
done
clear
```

> wsx@wsx:~/tmp\$ ./smenu1
>
> 1. Display disk space 3) Display memory usage
> 2. Display logged on users 4) Exit program

## 免密

### sudo 执行不输密码

在`/etc/sudoers`最后一行新增规则，即可达到免密执行

```shell
# li 为登陆用户
li ALL=(root) NOPASSWD: /root/dhclient.sh
```

## 错误问题

执行 sh 脚本时报错

> '\r':command not found

这是因为在 win 上的格式有问题，使用 dos2unix 命令转换一下脚本即可
