---
title: idea技巧
date: 2019-07-21 19:57:47
categories: tips
tags:
  - idea
  - 快捷键
  - tips
---

## 调试

1. `Evaluate Expression`,在`Debug`模式下使用，可以动态编写代码进行调试

2. 右键`BreakPoint`可设置`condition`，即在指定条件下断点生效

## 输入

多尝试用自定义模板[官方自定义模板内容函数](https://www.jetbrains.com/help/idea/template-variables.html)

## 快捷键

==⇧⌘F12== 最小化工具窗口

## `gradle`

`gradle`编译特别慢，需要在`idea`设置中设置`HTTP Proxy`

## 跳转源码

`jump to source`快捷键为`⎋(esc)`或`⌘+↓`

## 回到`Project`视图源码处

`select in project view`默认没有快捷键

## 自动分屏到右边

`move right`

## 在分屏中切换

`⌥tab`

## 切换 tab

`switcher` 快捷键为`⌃⇥`

`⇧⌘[`上个 tab
`⇧⌘]`下个 tab

## debug 模式下,开启变量提示

`show values inline`

## 当前行行数高亮

`line number on caret row`

## `live templates`

`ifn`快速判断当前行数变量是否为 null

```java
if (var == null) {

}
```

## `Hippie completion`

自动输入前面或后面的单词`⌥/` `⌥⇧/`

## `Smart Type`

智能补全，比如说提示使用何种`lambda` `⇧ space`

## 自动补全根据使用频率

`sort suggestions alphabetically`

## `quick Definitions`

弹出窗口快速查看代码`⌥q`

## `quick documentation`

弹出窗口快速查看文档`⌥F1`

## 为报错文件设置提醒色

`File Color`

## 使用`favorite`

## `custome live template`

可以选中代码后，抽取为`template`

## `keymap abbrevation`

添加快捷方式的缩写，方便使用`find action`查找

## `recent location`

最近访问的路径`⌘⇧e`

## `paster form history`

`idea`记录了最近复制过(`⌘c`)的文本

## `adjust code style setting`

选中代码后，使用可以查卡到选中代码所使用的格式选项，可以去调整它，``⌥⏎`

## `breadcrumbs`

使用面包屑导航显示代码类，方法

## `隐藏目录`

`Editor`|`File Types`|`Ignore files and folders`

## `相关问题`

> objc[1474]: Class JavaLaunchHelper is implemented in both /Library/Java/JavaVirtualMachines/jdk1.8.0_144.jdk/Contents/Home/bin/java (0x10b59a4c0) and /Library/Java/JavaVirtualMachines/jdk1.8.0_144.jdk/Contents/Home/jre/lib/libinstrument.dylib (0x10b6764e0). One of the two will be used. Which one is undefined.

`IDEA`菜单`Help`>>`Edit Custom Properties`
在打开的`idea.properties`里加上

```properties
idea.no.launcher=true
```

## 文件打开方式

idea 若使用某种方式打开文件后，`file type`中的编辑器类型下，会有相关联的文件后缀。

## 标记当前段落不格式化

code style|enable formatter markers in comments

## 为了方便在各个平台使用，统一定义快捷键

mac 上使用 command 键替代 alt

可以自定义一组快捷命令，`Quick List`

| 快捷键    | 解释                   |
| :-------- | :--------------------- |
| F1        | quick list             |
| F2        | next highlight error   |
| F3        | toggle bookmark        |
| F4        | run                    |
| F5        | debug                  |
| ALT 1     | project view           |
| ALT 2     | structure view         |
| ALT 3     | favorite view          |
| ALT 4     | run view               |
| ALT 5     | debug view             |
| ALT F3    | show bookmark          |
| ALT b     | goto to declration     |
| ALT n     | generate ,new file     |
| ALT w     | close active tab       |
| ALT up    | jump to navigation bar |
| ALT down  | jump to source         |
| ALT left  | goto previous splitter |
| ALT right | goto next splitter     |
| SHIFT F6  | rename                 |

其他快捷方式

1. 窗口视图回车键进入代码
