---
title: axios
date: 2020-11-04 17:13:01
categories: front-end
tags:
---

## 安装

```shell
npm install --save axios
```

## 示例

[官方文档](https://github.com/axios/axios)

基础示例

```javascript
const axios = require("axios");
axios({
  url: "http://localhost:5000",
  method: "post",
  data: "{}",
  headers: { "Content-tyle": "application/json" },
}).then((res) => {
  console.log(res);
});
```

其参数值可以为

- data 请求数据
- method 请求访问
- url 请求地址

post 请求

```javascript
const axios = require("axios");

axios
  .post("http://localhost:5000", {
    name: 1,
  })
  .then((res) => {
    console.log(res);
  });
  .catch((err)=>{
    console.log(err)
  })
```

我们可以为请求设定一个具有指定配置项的实例

```javascript
const instance = axios.create({
  url: "http://localhost:5000",
  timeout: 1000,
  headers: { "Content-tyle": "application/json" },
});
```

然后这个 instance 就可以直接调用下述方法

- `axios#request(config)`
- `axios#get(url[, config])`
- `axios#delete(url[, config])`
- `axios#head(url[, config])`
- `axios#options(url[, config])`
- `axios#post(url[, data[, config]])`
- `axios#put(url[, data[, config]])`
- `axios#patch(url[, data[, config]])`
- `axios#getUri([config])`

## vue-cli2 中 axios 全局配置

```javascript
//axios/index.js
import axios from "axios";

axios.defaults.baseURL =
  env === "development"
    ? "/api"
    : window.location.protocol + "//" + window.location.host; // 配置axios请求的地址
axios.defaults.headers.post["Content-Type"] = "application/json; charset=utf-8";
axios.defaults.crossDomain = true;
axios.defaults.withCredentials = true; //设置cross跨域 并设置访问权限 允许跨域携带cookie信息

//配置发送请求前的拦截器 可以设置token信息
axios.interceptors.request.use(
  (config) => {
    // 这里配置全局loading
    if (!/\.json/.test(config.url)) {
      $("#screen").show(); // 这个div控制loading动画，项目中有对json的请求，所以这里区分是否是json文件
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// 配置响应拦截器
axios.interceptors.response.use(
  (res) => {
    $("#screen").hide(); // loading结束
    return Promise.resolve(res.data); // 这里直接返回data, 即接口返回的所有数据
  },
  (error) => {
    $("#screen").hide();
    tooltip("", "连接错误！", "error");
    // 判断是否登录失效，按照实际项目的接口返回状态来判断
    if (error.toString().includes("776")) {
      window.location.href = window.location.origin + "/#/login";
    }
    return Promise.reject(error);
  }
);
export default axios;
```

最后在 main.js 里面引入

```javascript
import VueAxios from "vue-axios"; // 报错的话则npm安装依赖
import axios from "./axios";

Vue.use(VueAxios, axios);
```

## Webpack-dev-server 的 proxy 用法

在开发环境中，可以将 axios 的请求通过 proxy 进行转发

- 最简单的用法示例

  ```javascript
  mmodule.exports = {
    devServer: {
      proxy: {
        "/api": "http://localhost:3000",
      },
    },
  };
  ```

  请求到`/api/xxx`现在会被代理到请求`http://localhost:3000/api/xxx`

- 如果想要代理多个路径到同一个地址，可以使用一个或多个具有 context 属性的对象构成的数组

  ```javascript
  mmodule.exports = {
    devServer: {
      proxy: [
        {
          context: ["/api", "/auth"],
          target: "http://localhost:3000",
        },
      ],
    },
  };
  ```

- 如果你不想传递`/api`，可以重写路径

  ```javascript
  mmodule.exports = {
  devServer: {
      proxy: [
      '/api':{
          target: "http://localhost:3000",
          pathRewrite:{'^/api',''},//原请求路径将被正则替换后加入到target地址后
          secure:false,//默认情况下，不接受https，设置为false即可
      },
      ],
  },
  };
  ```

  请求到`/api/xxx`现在会被代理到请求`http://localhost:3000/xxx`

- 使用 bypass 选项通过函数判断是否需要绕过代理，返回 false 或路径来跳过代理。

  ```javascript
  mmodule.exports = {
  devServer: {
      proxy: [
      '/api':{
          target: "http://localhost:3000",
          bypass:function(req,res,proxyOptions){

            if(req.header.accept.indexOfI('html')!== -1){
                console.log('skipping proxy from browser request.')
                return '/index.html';//return false
            }
          }
      },
      ],
  },
  };
  ```

代理过程可能遇到的一些问题，对于有些 target 地址，可能需要登录，从而将页面重定向（302）到登录页面，那么我们就需要保证请求时带上对应的 token

## 提交 form 表单数据

```javascript
var bodyFormData = new FormData();
bodyFormData.append("userName", "Fred");
axios({
  method: "post",
  url: "myurl",
  data: bodyFormData,
  headers: { "Content-Type": "multipart/form-data" },
})
  .then(function (response) {
    //handle success
    console.log(response);
  })
  .catch(function (response) {
    //handle error
    console.log(response);
  });
```
