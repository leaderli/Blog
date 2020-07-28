---
title: shell-变量
date: 2020-05-26 14:32:16
categories: linux
tags:
  - shell
  - bash
---

## 1. 变量引用

一般情况下使用 `$variable`来引用变量值，它是`${variable}`的一种缩写

- 引用变量定义默认值

  ```shell
  #当变量为空时，name 就为 hello
  name=${variable:-hello}
  ```

- 引用变量替换

  ```shell
  #将variable中的hello替换为空
  name=${variable/hello/}
  #将variable中的满足正则表达式`^hello`替换为空
  name=${variable//^hello/}
  ```

### 1.1. 基于位置的参数

命令可以作为参数传入 shell 脚本中

```shell
echo $1
echo $2
$1 $2
```

- \$0 表示`shell`脚本本身
- \$[n] 表示`shell`第几个参数，\$10 不能获取第十个参数，获取第十个参数需要`${10}`。当 n>=10 时，需要使用\${n}来获取参数。
- \$@ 表示所有参数
- \${@:n} 表示除 n 前的所有参数，例如`${@:2}`表示除了第一个参数之外的所有参数
- \$? 显示最后命令的退出状态。0 表示没有错误，其他任何值表明有错误
- \$\$ 脚本运行的当前进程 ID 号
- \$! 后台运行的最后一个进程的 ID 号
- `*` 表示当前目录所有文件，相当于 ls
- \${{ '{#' }}name} 变量的长度

### 1.2. 字符串截取

`${varible#*string}`从左往右，删除最短的一个以 string 结尾的子串，即截取第一个 string 子串之后的字符串  
`${varible##*string}`从左往右，删除最长的一个以 string 结尾的子串，即截取最后一个 string 子串之后的字符串  
`${varible%string*}`从右往左，删除最短的一个以 string 开头的子串，即截取最后一个 string 子串之前的字符串  
`${varible%%string*}`从右往左，删除最长的一个以 string 开头的子串，即截取第一个 string 子串之前的字符串

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

## 2. 引号

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

3. 反引号``, 反引号括起来的字串被 Shell 解释为命令，在执行时，Shell 首先执行该命令，并以它的标准输出结果取代整个反引号（包括两个反引号）部分

## 3. 容错断言

如果一个或多个必要的环境变量没被设置的话, 就打印错误信息.下面是两种方式

```shell
: ${HOSTNAME?} ${USER?} ${MAIL?}
```

## 4. 设置静态变量

```shell
readonly MY_PATH=/usr/bin
```

## 5. 字符串切割为数组

### 5.1. 利用 shell 中 变量 的字符串替换

用 string 来替换 parameter 变量中所有匹配的 pattern

示例：

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

### 5.2. 设置分隔符，通过 IFS 变量

Shell 脚本中有个变量叫 IFS(Internal Field Seprator) ，内部域分隔符，shell 根据 IFS 的值，默认是 space, tab, newline 来拆解读入的变量，然后对特殊字符进行处理，最后重新组合赋值给该变量。

```shell
#!/bin/bash

string="hello,shell,split,test"

#对IFS变量 进行替换处理
OLD_IFS="$IFS"
IFS=","
array=($string)
IFS="$OLD_IFS"

for var in ${array[@]}
do
   echo $var
done
```

## 6. 变量使用`*`

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
