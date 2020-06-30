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

对于内核而言，所有打开的文件都是通过文件描述符引用的

文件描述符就是从 0 开始的小的非负整数，内核用以标识一个特定进程正在访问的文件。当打开一个文件或创建一个文件，内核向进程返回一个文件描述符。

Linux 进程默认情况下会有三个缺省打开的文件描述符

- 0（标准输入）`stdin`
- 1（标准输出）`stdout`
- 2（标准错误）`stderr`

所以`2>&1` 的意思就是将标准错误也输出到标准输出当中。

`shell`中可能经常能看到：`echo log > /dev/null 2>&1`,命令的结果可以通过`%>`的形式来定义输出,`/dev/null` ：代表空设备文件

_`1 > /dev/null 2>&1` 语句含义,_

1. `1 > /dev/null` ： 首先表示标准输出重定向到空设备文件，也就是不输出任何信息到终端，说白了就是不显示任何信息。
2. 2>&1 ：接着，标准错误输出重定向（等同于）标准输出，因为之前标准输出已经重定向到了空设备文件，所以标准错误输出也重定向到空设备文件。

_`cmd >a 2>a` 和 `cmd >a 2>&1` 为什么不同？_

1. `cmd >a 2>a` ：`stdout`和`stderr`都直接送往文件 `a` ，`a`文件会被打开两遍，由此导致`stdout`和`stderr`互相覆盖。`cmd >a 2>a` 相当于使用了`FD1`、`FD2`两个互相竞争使用文件 `a` 的管道；
2. `cmd >a 2>&1` ：`stdout`直接送往文件`a`，`stderr`是继承了`FD1`的管道之后，再被送往文件`a` 。`a`文件只被打开一遍，就是`FD1`将其打开。`cmd >a 2>&1` 只使用了一个管道`FD1`，但已经包括了`stdout`和`stderr`。从`IO`效率上来讲，`cmd >a 2>&1`的效率更高。

### 使错误日志重定向到正常输出

sh error.sh > messge.log 2>&1

## 组合命令

可通过`&&`,让多个命令顺序执行，也可以通过`;`,不同的地方为`&&`，当前一个命令的返回码为 0 时，才会执行后一个命令
例如

```shell
cd ~/Downloads/ && rm -rf temp`
```

`||`,与`&&`相反，当前一个命令的返回码大于 0 才执行第二条

## 函数

shell 中函数的定义格式如下：

```shell
[ function ] funname [()]

{

    action;

    [return int;]

}

```

1. 参数返回，可以显示加：return 返回，如果不加，将以最后一条命令运行结果，作为返回值。 return 后跟数值 n(0-255
2. 函数返回值在调用该函数后通过 \$? 来获得。
3. 调用函数时可以向其传递参数。在函数体内部，通过 $n 的形式来获取参数的值，例如，$1 表示第一个参数，\$2 表示第二个参数

示例

```shell
fun(){
   echo $1
   return 1
}

fun 'hello'
echo $?

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

## 脚本参数

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

## 读取用户输入

while read line

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

## 判断文件属性

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
```

## 逻辑判断

在 linux 中 命令执行状态：0 为真，其他为假

| 操作符 | 解释              |
| -----: | :---------------- |
|    -eq | 等于              |
|    -ne | 不等于            |
|    -gt | 大于 （greater ） |
|    -lt | 小于 （less）     |
|    -ge | 大于等于          |
|    -le | 小于等于          |

## switch

```shell
case 值 in
模式1)
    command1
    command2
    command3
    ;;
模式2）
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

在 shell 中设定`set -u`

## 菜单

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
>    Enter an option:

## 错误问题

执行 sh 脚本时报错

> '\r':command not found

这是因为在 win 上的格式有问题，使用 dos2unix 命令转换一下脚本即可
