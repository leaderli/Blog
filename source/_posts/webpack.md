---
title: webpack
date: 2020-10-29 15:17:47
categories:
tags:
---

## 快速入门

[官方入门文档](https://webpack.js.org/guides/getting-started/)

```shell
mkdir webpack-demo
cd webpack-demo
npm init -y
npm install webpack webpack-cli --save-dev
npm install --save lodash
```

新增两个文件

```diff
webpack-demo
  |- package.json
  |- /dist
   |- index.html
  |- /src
    |- index.js
```

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Getting Started</title>
  </head>

  <body>
    <script src="main.js"></script>
  </body>
</html>
```

```javascript
import _ from "lodash";

function component() {
  const element = document.createElement("div");

  // Lodash, now imported by this script
  element.innerHTML = _.join(["Hello", "webpack"], " ");

  return element;
}
document.body.appendChild(component());
```

执行打包命令

```shell
# npx 类似package.json中的scripts，可直接运行
npx webpack
```

也可以在 package.json 中新增 script，

```json
{
  "name": "webpack-demo",
  "version": "1.0.0",
  "description": "",
  "private": true,
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "build": "webpack"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "devDependencies": {
    "webpack": "^5.3.0",
    "webpack-cli": "^4.1.0"
  },
  "dependencies": {
    "lodash": "^4.17.20"
  }
}
```

那么我们可以直接使用如下命令进行打包

```shell
npm run build
```

当不指定配置文件时，就使用了默认的配置(`npx webpack --config webpack.config.js`)

```javascript
const path = require("path");

module.exports = {
  entry: "./src/index.js",
  output: {
    filename: "main.js",
    path: path.resolve(__dirname, "dist"),
  },
};
```

如需要指定配置文件，可在 package.json 中指定相关配置文件

命令成功执行后，就会将所有文件打包到 dist 目录，我们打开 index.html，如果一切正常的话，我们可以在浏览器上看到`Hello webpack`字样

我们可以使用`npx webpack serve`启动 web 服务，默认会在 8080 端口上启动

```shell
npm i webpack-dev-server -S -D
npx webpack serve
```

## 加载其他资源文件

webpack.config.js 中的配置，在 module 对象的 rules 属性中可以指定一系列的 loaders，每一个 loader 都必须包含 test 和 use 两个选项，这段配置的意思是说，当 webpack 编译过程中遇到 require()或 import 语句导入一个后缀名为.css 的文件是，先将它通过 css-loader 转换，在通过 style-loader 转换，然后继续打包。use 选项的值可以是数组或字符串，如果是数组，它的编译顺序是从后往前

修改一下项目结构

修改`dist/index.html`

```diff
<!doctype html>
  <html>
    <head>
    <title>Asset Management</title>
    </head>
    <body>
-    <script src="main.js"></script>
+    <script src="bundle.js"></script>
    </body>
  </html>

```

修改`webpack.config.js`

```diff
 const path = require('path');

  module.exports = {
    entry: './src/index.js',
    output: {
-     filename: 'main.js',
+     filename: 'bundle.js',
      path: path.resolve(__dirname, 'dist'),
    },
  };
```

### 导入 css 文件

```shell
npm install --save-dev style-loader css-loader

```

修改`webpack.config.js`

```diff
 const path = require('path');

  module.exports = {
    entry: './src/index.js',
    output: {
      filename: 'bundle.js',
      path: path.resolve(__dirname, 'dist'),
    },
+  module: {
+    rules: [
+      {
+        test: /\.css$/,
+        use: [
+          'style-loader',
+          'css-loader',
+        ],
+      },
+    ],
+  },
  };
```

新增`src/style`文件

```css
.hello {
  color: red;
}
```

修改`src/index.js`

```diff
  import _ from 'lodash';
+ import './style.css';

  function component() {
    const element = document.createElement('div');

    // Lodash, now imported by this script
    element.innerHTML = _.join(['Hello', 'webpack'], ' ');
+   element.classList.add('hello');

    return element;
  }

  document.body.appendChild(component());

```

```shell
npx webpack serve --config webpack.config.js
```

### 导入图片

```shell
npm install --save-dev file-loader
```

```diff
const path = require('path')

module.exports = {
    entry: './src/index.js',
    output: {
        filename: 'main.js',
        path: path.resolve(__dirname, 'dist'),
    },
    module: {
        rules: [
            {
                test: /\.css$/,
                use: [
                    'style-loader',
                    'css-loader',
                ]
            },
+           {
+               test: /\.(png|svg|jpg|gif)$/,
+               use: [
+                   'file-loader',
+               ],
+           },
        ]
    }
}

```

新增图片`src/icon.png`
修改`src/index.js`

```diff
  import _ from "lodash";
  import "./style.css";
+ import Icon from "./icon.png";

  function component() {
    const element = document.createElement("div");

    // Lodash, now imported by this script
    element.innerHTML = _.join(["Hello", "webpack"], " ");
    element.classList.add("hello");

+   // Add the image to our existing div.
+   const myIcon = new Image();
+   myIcon.src = Icon;

+   element.appendChild(myIcon);

    return element;
  }

  document.body.appendChild(component());
```

修改`src/style.css`

```diff
  .hello {
    color: red;
+   background: url('./icon.png');
  }
```

### 导入数据

```shell
npm install --save-dev csv-loader xml-loader
```

`webpack.config.js`

```diff
 const path = require('path');

  module.exports = {
    entry: './src/index.js',
    output: {
      filename: 'bundle.js',
      path: path.resolve(__dirname, 'dist'),
    },
    module: {
      rules: [
        {
          test: /\.css$/,
          use: [
            'style-loader',
            'css-loader'
          ],
        },
        {
          test: /\.(png|svg|jpg|gif)$/,
          use: [
            'file-loader',
          ],
        },
+      {
+        test: /\.(csv|tsv)$/,
+        use: [
+          'csv-loader',
+        ],
+      },
+      {
+        test: /\.xml$/,
+        use: [
+          'xml-loader',
+        ],
+      },
+     ],
     },
  };
```

增加一些数据

`src/data.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<note>
  <to>Mary</to>
  <from>John</from>
  <heading>Reminder</heading>
  <body>Call Cindy on Tuesday</body>
</note>
```

`src/data.csv`

```csv
to,from,heading,body
Mary,John,Reminder,Call Cindy on Tuesday
Zoe,Bill,Reminder,Buy orange juice
Autumn,Lindsey,Letter,I miss you
```

`src/index.js`

```diff
  import _ from 'lodash';
  import './style.css';
  import Icon from './icon.png';
+ import Data from './data.xml';
+ import Notes from './data.csv';

  function component() {
    const element = document.createElement('div');

    // Lodash, now imported by this script
    element.innerHTML = _.join(['Hello', 'webpack'], ' ');
    element.classList.add('hello');

    // Add the image to our existing div.
    const myIcon = new Image();
    myIcon.src = Icon;

    element.appendChild(myIcon);

+   console.log(Data);
+   console.log(Notes);

    return element;
  }

  document.body.appendChild(component());
```

类似的数据文件还可以使用

`src/data.toml`

```toml
title = "TOML Example"

[owner]
name = "Tom Preston-Werner"
organization = "GitHub"
bio = "GitHub Cofounder & CEO\nLikes tater tots and beer."
dob = 1979-05-27T07:32:00Z
```

`src/data.yaml`

```yaml
title: YAML Example
owner:
  name: Tom Preston-Werner
  organization: GitHub
  bio: |-
    GitHub Cofounder & CEO
    Likes tater tots and beer.
  dob: 1979-05-27T07:32:00.000Z
```

`src/data.json5`

```json
{
  // comment
  "title": "JSON5 Example",
  "owner": {
    "name": "Tom Preston-Werner",
    "organization": "GitHub",
    "bio": "GitHub Cofounder & CEO\n\
Likes tater tots and beer.",
    "dob": "1979-05-27T07:32:00.000Z"
  }
}
```

需要安装相关插件

```shell
npm install toml yamljs json5 --save-dev
```

## 输出管理

通过 `html-webpack-plugin`自动生成 index.html，并引入相关资源
通过 `clean-webpack-plugin` 自动清理 dist 目录

```shell
npm install --save-dev html-webpack-plugin
npm install --save-dev clean-webpack-plugin
```

示例

`src/print.js`

```javascript
export default function printMe() {
  console.log("I get called from print.js!");
}
```

`src/index.js`

```diff
  import _ from 'lodash';
+ import printMe from './print.js';

  function component() {
    const element = document.createElement('div');
+   const btn = document.createElement('button');

    element.innerHTML = _.join(['Hello', 'webpack'], ' ');

+   btn.innerHTML = 'Click me and check the console!';
+   btn.onclick = printMe;
+
+   element.appendChild(btn);

    return element;
  }

  document.body.appendChild(component());
```

`webpack.config.js`

```diff
  const path = require('path');
+ const HtmlWebpackPlugin = require('html-webpack-plugin');
+ const { CleanWebpackPlugin } = require('clean-webpack-plugin');



  module.exports = {
-  entry: './src/index.js',
+  entry: {
+    app: './src/index.js',
+    print: './src/print.js',
+  },
+  plugins: [
+    new CleanWebpackPlugin(),
+    new HtmlWebpackPlugin({
+      title: 'Output Management',
+    }),
+  ],
    output: {
-    filename: 'bundle.js',
+    filename: '[name].bundle.js',
      path: path.resolve(__dirname, 'dist'),
    },
  };

```

### 统一输出 css 文件

使用插件[mini-css-extract-plugin](https://github.com/webpack-contrib/mini-css-extract-plugin)

```shell
npm install --save-dev mini-css-extract-plugin
```

`webpack.config.js`

```diff
  const { CleanWebpackPlugin } = require('clean-webpack-plugin')
  const HtmlWebpackPlugin = require('html-webpack-plugin')
+ const MiniCssExtractPlugin = require('mini-css-extract-plugin')
  const path = require('path')

  module.exports = {
      entry: {
          app: './src/index.js',
          print: './src/print.js',
      },
      output: {
          filename: '[name].bundle.js',
          path: path.resolve(__dirname, 'dist'),
      },
      plugins: [
          new CleanWebpackPlugin(),
+         new MiniCssExtractPlugin({
+             filename: 'main.css'
+         }),
          new HtmlWebpackPlugin({
              title: 'the output management'
          }
          )
      ],
      module: {
          rules: [
              {
                  test: /\.css$/,
+                 use: [MiniCssExtractPlugin.loader, 'css-loader']

              }
          ]
      }
  }

```

重新编译后在 dist 目录下生成了 main.css，且 index.html 中引入了 main.css

```shell
npm run build
```
