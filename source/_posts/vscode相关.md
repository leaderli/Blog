---
title: vscode相关
date: 2019-08-01 21:48:45
categories: vscode
tags:
  - vscode
  - 插件
---

## vim 自动切换输入法

安装软件

```shell
curl -Ls https://raw.githubusercontent.com/daipeihust/im-select/master/install_mac.sh | sh
```

软件会默认安装到目录`/user/local/bin/`下, 无参数执行时就会输出默认输入法的字符

```log
/usr/local/bin$ im-select
com.apple.keylayout.ABC
```

打开`vscode`的默认配置文件`setting.json`,新增如下配置

```json
    "vim.autoSwitchInputMethod.enable": true,
    "vim.autoSwitchInputMethod.defaultIM": "com.apple.keylayout.ABC",
    "vim.autoSwitchInputMethod.obtainIMCmd": "/usr/local/bin/im-select",
    "vim.autoSwitchInputMethod.switchIMCmd": "/usr/local/bin/im-select {im}"
```

其中默认`defaultIM`的值为你需要自动切换的默认输入法

## 保存后自动运行

1.安装[Code Runner](https://marketplace.visualstudio.com/items?itemName=formulahendry.code-runner)

在`settings.json`中配置

```json
 "code-runner.executorMapByFileExtension": {
     ".scm": "scheme --quiet<",
 }
```

有些情况下可能需要添加如下配置才生效

```json
"code-runner.executorMap": {
    "scheme": "scheme --quiet< \"$dir$fileName\""
}
```

2.安装[Run on Save](https://marketplace.visualstudio.com/items?itemName=pucelle.run-on-save)

在`settings.json`中配置

```json
"runOnSave.commands": [
    {
        "match": "\\.scm$",
        "command": "scheme --quiet < ${file}",
        "runIn": "backend"
    }
]
```

具体详情配置可参考插件的文档

## 最近打开文件

open recent file `⌃ R`

## 括号匹配色

使用 [Bracket Pair Colorizer2](https://marketplace.visualstudio.com/items?itemName=CoenraadS.bracket-pair-colorizer-2)

颜色方案(使用黑色主题)使用如下在`settings.json`中配置

```json
"bracket-pair-colorizer-2.colors": [

        "#289CF4",
        "#FED02F",
        "#2CDD18",
        "#FF5FFF",
        "#D10000",
        "#D05355",
        "#fff",
    ]

```

## 是否显示侧边栏

`Toggle activitiy Bar Visibility` 带图标的侧边工具栏

`Toggle side Bar Visibility`快捷键`⌘b` 具体工具栏的实际内容

## 合并当前行

join line `⌃ R`

## 自定义代码片段

1. `Configure user Snippets`
2. 选择生效的语言
   3 进行配置

scope 不是文件扩展名

```json
"Print to console": {
    "scope": "scheme",
    "prefix": "log",
    "body": [
        "(write-line ($0))",
    ],
    "description": "Log output to console"
}
```

## `markdown`图片插件

使用[Paste Image](https://marketplace.visualstudio.com/items?itemName=mushan.vscode-paste-image)

```json
 "pasteImage.namePrefix": "${currentFileNameWithoutExt}_",
"pasteImage.path": "${projectRoot}/source/images",
"pasteImage.basePath": "${projectRoot}/source",
"pasteImage.forceUnixStyleSeparator": true,
"pasteImage.prefix": "/",
//插入markdown的语法
"pasteImage.insertPattern": "![${imageFileName}](/images/${imageFileName})"
```
