---
title: mockjs
date: 2020-11-05 10:03:58
categories: front-end
tags:
---

使用 mockjs 来模拟 api 接口返回报文

```shell
#安装
npm install -S -D mockjs
```

在项目目录下新建`mock/index.js`,并在`main.js`中引入

```javascript
// main.js

require("./mock");

//mock/index.js

import Mock from "mockjs";

Mock.mock("/api", {
  name: "li",
  age: 12,
});
```

mockjs 代理地址支持正则表达式

```javascript
Mock.mock(/\/api\/.*/, { foo: "bar" });
```

mockjs 支持使用一个函数来返回模拟数据

```javascript
//options中包含请求url,type,请求body等信息
Mock.mock(/\/api\/.*/, function (options) {
 return {
    foo: "bar";
  }
});
```
