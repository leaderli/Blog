---
title: markdown和KaTex
date: 2019-07-08 21:25:25
categories: markdown
tags: markdown katex
---

## markdown

- 空白行 `&emsp;`

- 首行缩进，通过两个空白行来实现 `&emsp;&emsp;`

- 有序列表

```markdown
1. ol
2. ol
```

- 文本引用

```markdown
> 这个是区块引用
>
> > 这个也是区块引用
> >
> > > 这个还是是区块引用
```

- 插入图片
  md 文件同级目录会生成一个同名文件夹，图片放入其中，然后通过如下方式引入
  `![详细日志](/images/图片名.jpg)`
  该目录在`hexo`项目目录的`source`目录下，将图片放入其中即可，为了避免冲突
- 链接&emsp;`[title](urls)`

- 表格基本模板，其中`:`表示对齐，表格上方需要空一行，否则无法正常显示

  | Table Header 1 | Table Header 2 | Table Header 3 |
  | :------------- | :------------: | -------------: |
  | Division 1     |   Division 2   |     Division 3 |
  | Division 1     |   Division 2   |     Division 3 |
  | Division 1     |   Division 2   |     Division 3 |

- 文本换行可在上一段文本后追加至少两个空格

## KaTex

[参考文档](https://katex.org/docs/supported.html)

基本 KaTex 首尾需要`$`包含,例如`$X_y$`表示$X_y$

| 表达式 |  示例  |
| :----: | :----: |
| `\{\}` | $\{\}$ |
| `\ge`  | $\ge$  |
| `\le`  | $\le$  |
| `X_y`  | $X_y$  |

## hexo

站内引用，引用自己的博客
{% post_link 文章文件名（不要后缀） %}

使用`F8`快速定位`markdown`语法错误的地方。
