---
title: linux-自定义补全
date: 2020-05-24 00:27:18
categories: linux
tags:
---

在 linux 中，通常我们可以使用`<tab><tab>`来进行补全，但是我们自己写的脚本却没有自动补全的功能。我们通过 linux 内置的 complete 命令来设定自定义补全。

一般情况下我们定义一个配置文件专门用于自定义配置文件

```bash
#/usr/bin/env bash
complete -W "now tomorrow never" dothis
```

要使其生效，我们需要`source config.file`,我们可以将这个命令追加到`.bash_profile`中

## 用法

1. `complete -W [wordlist] dothis`

   例如:
   complete -W "now tomorrow never" dothis

   > \$ dothis `<tab><tab>`
   > never now tomorrow

2. `complete -d dothis`
   补全目录
3. `complete -e dothis`
   补全文件
4. `complete -F function dothis`
   根据函数 function 的中定义的值去显示，该值是实时生效的

   例如：

   ```bash
   #/usr/bin/env bash
   list(){
   COMPREPLY=(`cat .list`)
   }
   complete -F list dothis
   ```

   当我们修改`.list`文件的内容时，补全也跟着变动
