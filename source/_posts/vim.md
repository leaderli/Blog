---
title: vim
date: 2019-08-11 01:09:50
categories: linux
tags:
  - vim
---

c 与 d 命令功能类似，c 会进入插入模式

`%`  
匹配对应的括号  
`(`  
光标移至句首,)反向  
`:%s/vivian/sky/g`  
替换每一行中所有 vivian 为 sky  
`:1,$ s/$/WORLD/g`  
替换行尾  
`:1,$ s/^/HELLO/g`  
替换行首  
`:1,10d`  
命令解释：删除第一行到第 10 行  
`:f`  
在命令模式下，用于显示当前的文件名、光标所在行的行号以及显示比例；  
`:g/^s*$/d`  
删除所有空格  
`:s/vivian/sky/g`  
替换当前行所有 vivian 为 sky  
`b`  
光标左移一个字至字首,跳过空格  
`caw ciw`  
更改当前光标所在字符的单词并进入插入模式  
`ct`  
删除到某个单词并进入插入模式,T 反向  
`c`  
和其它命令组合,和 d 模式基本相同，进入插入模式  
`C`  
删除直到行尾并进入插入模式  
`Ctrl+b`  
向文件首翻一屏；  
`Ctrl+d`  
向文件尾翻半屏；  
`Ctrl+f`  
向文件尾翻一屏；  
`Ctrl+u`  
向文件首翻半屏；  
`f`  
跳转到指定字符  
`t`  
跳转到指定字符前  
`D`  
删除直到行尾  
`diw`  
删除当前单词,和其它组合，如 di{,di(,di"  
`daw`  
删除当前单词,和其它组合，如 di{,di(,di",同时删除组合  
`dt`  
删除知道某个单词 仅限当前行,T 反向  
`e`  
光标右移一个字至字尾,跳过空格  
`gd`  
高亮显示光标所属单词，"n" 查找！  
`ge`  
光标左移一个字至字尾,跳过空格  
`gU`  
转换大写到 需配合 w,b 等移动命令，类似 t  
`gu`  
转换小写到 需配合 w,b 等移动命令，类似 t  
`H`  
光标移至屏幕顶行  
`L`  
光标移至屏幕最后行  
`M`  
光标移至屏幕中间行  
`R`  
进入替换模式，直到按下 esc  
`s`  
删除当前字符并进入插入模式  
`S`  
删除当前行，并进入插入模式  
`vi{`  
选中大括号内,小括号等同理  
`w`  
光标右移一个字至字首,跳过空格  
`ZZ`  
命令模式下保存当前文件所做的修改后退出 vi；  
`{`  
转到上一个空行 }反向  
`＃`  
普通模式下输入＃寻找游标所在处的单词,＊是反向  
`ma`  
mark currrent position  
`da`  
delete everything from the marked position to here  
\`a
go back to the marked position  
`''`  
跳转到光标上次停靠的地方, 是两个', 而不是一个"  
`gD`  
跳转到局部变量的定义处  
`:E`  
浏览当前目录

## 配置文件

vim 的配置在`~/.vimrc`中。

- set paste 进入 paste 模式以后，可以在插入模式下粘贴内容，不会有任何变形,解决粘贴乱行问题

## 宏模式

在命令模式下按下`qa`开始记录，指导在命令模式下再次按下`q`结束记录。
可通过`@a`，重复执行命令，`n@a`重复执行`n`次。

## 替换空格为换行

```shell
:%s/ /\r/g
```

## 查看颜色代码

```shell
:hi
```

例如
![vim_2020-06-03-11-36-27.png](./images/vim_2020-06-03-11-36-27.png)

其中关于搜索高亮的颜色是配置项 `Search`,我们可以临时修改

```shell
:hi Search term=reverse ctermfg=0 ctermbg=3 guifg=#000000 guibg=#FFE792
```

也可在`.vimrc`中配置,使其永久生效

```properties
hi Search term=reverse ctermfg=0 ctermbg=3 guifg=#000000 guibg=#FFE792
```
