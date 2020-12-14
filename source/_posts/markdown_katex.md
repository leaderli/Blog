---
title: markdown_katex
date: 2019-07-08 21:25:25
categories: hexo
tags:
  - markdown
  - katex
  - latex
  - ascii
---

## markdown 语法

- 标题 `#`,`#`个数表示标题的等级，标题后可使用`{}`添加渲染后的节点的 id，方便使用锚点功能

  ```markdown
  ### My Great Heading {#custom-id}
  ```

- 空白行 `&emsp;`

- 首行缩进，通过两个空白行来实现 `&emsp;&emsp;`
- 换行 两段之间插入一个空白行，或者上一行行尾插入一个空字符串
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
  将图片存入 md 文件同级目录下，然后通过如下方式引入
  `![详细日志](./images/图片名.jpg)`
  该目录在`hexo`项目目录的`source`目录下，将图片放入其中即可
  图片下需要有行文字，否则会显示出图片的默认名
- 链接&emsp;`[title](urls)`
- 锚点&emsp;`[title](#id)`,对于 markdown，标题会被解析成一个 id 为标题名的 dom 节点

- 表格基本模板，其中`:`表示对齐，表格上方需要空一行，否则无法正常显示

  | Table Header 1 | Table Header 2 | Table Header 3 |
  | :------------- | :------------: | -------------: |
  | Division 1     |   Division 2   |     Division 3 |
  | Division 1     |   Division 2   |     Division 3 |
  | Division 1     |   Division 2   |     Division 3 |

- 文本换行可在上一段文本后追加至少两个空格

- 水平线 `---`
- 删除线 `~~删除线~~` ~~删除线~~
- 加粗文本

  ```markdown
  **_加粗的文本_**
  ```

- 代码块
  \`\`\`language
  \`\`\`
  支持的语言有
  `c`, `abnf`, `accesslog`, `actionscript`, `ada`, `apache`, `applescript`, `arduino`, `armasm`, `asciidoc`, `aspectj`, `autohotkey`, `autoit`, `avrasm`, `awk`, `axapta`, `bash`, `basic`, `bnf`, `brainfuck`, `cal`, `capnproto`, `ceylon`, `clean`, `clojure`, `clojure`-`repl`, `cmake`, `coffeescript`, `coq`, `cos`, `cpp`, `crmsh`, `crystal`, `cs`, `csp`, `css`, `d`, `dart`, `delphi`, `diff`, `django`, `dns`, `dockerfile`, `dos`, `dsconfig`, `dts`, `dust`, `ebnf`, `elixir`, `elm`, `erb`, `erlang`, `erlang`-`repl`, `excel`, `fix`, `flix`, `fortran`, `fsharp`, `gams`, `gauss`, `gcode`, `gherkin`, `glsl`, `go`, `golo`, `gradle`, `groovy`, `haml`, `handlebars`, `haskell`, `haxe`, `hsp`, `htmlbars`, `http`, `hy`, `inform7`, `ini`, `irpf90`, `java`, `javascript`, `json`, `julia`, `kotlin`, `lasso`, `ldif`, `leaf`, `less`, `lisp`, `livecodeserver`, `livescript`, `llvm`, `lsl`, `lua`, `makefile`, `markdown`, `mathematica`, `matlab`, `maxima`, `mel`, `mercury`, `mipsasm`, `mizar`, `mojolicious`, `monkey`, `moonscript`, `n1ql`, `nginx`, `nimrod`, `nix`, `nsis`, `objectivec`, `ocaml`, `openscad`, `oxygene`, `parser3`, `perl`, `pf`, `php`, `pony`, `powershell`, `processing`, `profile`, `prolog`, `protobuf`, `puppet`, `purebasic`, `python`, `q`, `qml`, `r`, `rib`, `roboconf`, `rsl`, `ruby`, `ruleslanguage`, `rust`, `scala`, `scheme`, `scilab`, `scss`, `smali`, `smalltalk`, `sml`, `sqf`, `sql`, `stan`, `stata`, `step21`, `stylus`, `subunit`, `swift`, `taggerscript`, `tap`, `tcl`, `tex`, `thrift`, `tp`, `twig`, `typescript`, `vala`, `vbnet`, `vbscript`, `vbscript`-`html`, `verilog`, `vhdl`, `vim`, `x86asm`, `xl`, `xml`, `xquery`, `yaml`, `zephir`

- 转义

  1. 转义字符`\`
  2. 行内代码转移\`,使用两个\`\`包裹，例如`` 测试`a` ``

- 自定义 html

  ```html
  <em class="red">aa</em>
  ```

  自定义样式，在主题`next`下的`main.styl`引入自定义配置文件`@import '_custom/li.styl';`，为了让 vscode 中也可以正常显示，在 vscode 中增加配置项`"markdown.styles": ["main.css"],需要将`main.css`放到 markdown 同级目录

  例如: <em class="red">aa</em>

  现在实现的自定义标签有

  1. code
  2. hi
  3. grey
  4. red

详细语法可参考[markdown 参考](https://www.markdownguide.org/basic-syntax/)

## KaTex

[参考文档](https://katex.org/docs/supported.html)

基本 KaTex 首尾需要`$`包含,例如`$X_y$`表示$X_y$

常用

| 表达式                         | 示例                           |
| :----------------------------- | :----------------------------- |
| `\{\}`                         | $\{\}$                         |
| `\ge`                          | $\ge$                          |
| `\le`                          | $\le$                          |
| `\ne`                          | $\ne$                          |
| `\cdots`                       | $\cdots$                       |
| `X_y`                          | $X_y$                          |
| `X^{y}`                        | $x^{y}$                        |
| `\hat{\delta}`                 | $\hat{\delta}$                 |
| `\theta`                       | $\theta$                       |
| `\varepsilon`                  | $\varepsilon$                  |
| `\Sigma`                       | $\Sigma$                       |
| `\omega`                       | $\omega$                       |
| `\lbrace \rbrace`              | $\lbrace \rbrace$              |
| `\vert`                        | $\vert$                        |
| `\emptyset`                    | $\emptyset$                    |
| `\varrho`                      | $\varrho$                      |
| `\varrho`                      | $\vartheta$                    |
| `\delta`                       | $\delta$                       |
| `\in`                          | $\in$                          |
| `\notin`                       | $\notin$                       |
| `\cap`                         | $\cap$                         |
| `\cup`                         | $\cup$                         |
| `\displaystyle\bigcup_{i=1}^k` | $\displaystyle\bigcup_{i=1}^k$ |
| `\subset`                      | $\subset$                      |
| `\subseteq`                    | $\subseteq$                    |
| `\supset`                      | $\supset$                      |
| `\supseteq`                    | $\supseteq$                    |
| `\varepsilon\text{-}NFA`       | $\varepsilon\text{-}NFA$       |

块状使用`$$`包含

不支持中文

## 其他

`F8`快速定位格式错误处
