---
title: vue入门
date: 2019-09-08 22:49:02
categories: 前端
tags:
  - vue
  - node
  - npm
---

## 安装`vue-cli`

`npm i -gD vue-cli`

## 创建项目

`vue init webpack projectname`,`webpack`表示模板，项目名必须全部小写,安装过程中注意`vue-router`选择`Y`
项目安装失败，尝试重新安装`vue-cli`

## 启动项目

`npm run dev`

## `package.json`

模块描述文件，类似`maven`的`pom.xml`文件

`name` - 包名.
`version` - 包的版本号。
`description` - 包的描述。
`homepage` - 包的官网 URL。
`author` - 包的作者。
`contributors` - 包的其他贡献者。
`dependencies` / devDependencies - 生产/开发环境依赖包列表。它们将会被安装在 node_module 目录下。
`repository` - 包代码的 Repo 信息，包括 type 和 URL，type 可以是 git 或 svn，URL 则是包的 Repo 地址。
`main - main` 字段指定了程序的主入口文件，require('moduleName') 就会加载这个文件。这个字段的默认值是模块根目录下面的 index.js。
`keywords` - 关键字

## 路由

`<router-view>`挂载路由，默认挂载`/`  
`<router-link on='/xxx'>`路由跳转，渲染后既是`<a>`  
`mode: 'history'`使用历史模式，即`url`不以`#`跳转页面

### 配置路由

模块`A.vue`

```html
<router-link to="/b">xxx</router-link> <router-view></router-view>
```

路由配置

```javascript
import Vue from "vue";
import Router from "vue-router";
import A from "./components/A.vue";
import B from "./components/B.vue";

Vue.use(Router);

export default new Router({
  mode: "history",
  base: process.env.BASE_URL,
  routes: [
    {
      path: "/",
      component: A,
      children: [
        {
          path: "/b",
          component: B,
        },
      ],
    },
  ],
});
```

在模块中使用`<router-view>`,同时在关于模块中的路由配置需要配置`children`实现挂载页面，效果既是在跳转`b`时，`A`模块会作为公共模块依然存在

## 手动创建`vue`项目

1. `npm install`会生成`package-lock.json`文件
2. `npm init -f`会生成`package.json`文件
3. 安装`vue`需要的依赖，`npm i vue-router -D`

## `vue3`

安装 `npm i -g @vue/cli`
图像界面`vue ui`
创建项目 `vue create projectname`  
启动项目 `npm run serve`

> safari 浏览器缓存的问题，页面刷新不及时，使用 chrome 去调试

## 引入`css`

在需要加入的模块引入

```css
<style>
@import url(../../public/vue.css);
</style>
```

在`index.html`首页添加，全局有效

## 语法规则

### \$mount 的用法

\$mount 方法是用来挂载我们的扩展的。做一个扩展，然后用\$mount 的方法把扩展挂载到 dom 上

```javascript
var judy = Vue.extend({
  template: "<p>{{message}}</p>",
  data: function () {
    return {
      message: "I am Judy",
    };
  },
});
var vm = new judy().$mount("#app");
```

```html
<div id="app">
  {{message}}
</div>
```
