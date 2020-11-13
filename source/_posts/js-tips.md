---
title: js-tips
date: 2019-12-05 01:10:00
categories: js
tags:
  - js
  - tips
---

## 格式化输出 json

```javascript
var json = JSON.stringify(jsonObj, null, 4);
consol.log(json);
```

## js 可变参数

```javascript
var a = 100;
var b = 100;

function test() {
  var obj = {};

  for (var i = 0; i < arguments.length; i++) {
    var name = arguments[i];
    obj[name] = eval(name);
  }

  return obj;
}
console.log(test("a", "b"));
```

可以直接使用`for of`语法遍历元素

```javascript
var a = 100;
var b = 100;

function test() {
  var obj = {};

  for (let value of arguments) {
    console.log(value);
  }

  return obj;
}
test("a", "b");
```

es6 标准还提供了`...`表示可变参数，该参数只能为最后一个参数

```javascript
function test(name, ...args) {
  console.log(name);
  for (let arg of args) {
    console.log(arg);
  }
}

test("li", 100, 200, 300);
```

## 根据空行分割字符串

```javascript
console.log(str.trim().split(/\s+/));
```

## js 进制

```javascript
//二进制0b开头
//八进制0开头
//十六进制0x开头
var a = 0b10;
var b = 070;
var c = 0x36;
```

## 属性依赖赋值

js 对象的属性值延迟加载

```javascript
app = {};
Object.defineProperty(app, "config", {
  get: (function () {
    var inner = {};
    inner.get = function () {
      return inner.config || (inner.config = 1234);
    };
    return inner.get;
  })(),
});
```

## console

```javascript
var obj = [
  {
    name: 1,
    age: 1,
  },
  {
    name: 2,
    age: 2,
  },
];

console.table(obj);
```

![js-tips_table.png](./images/js-tips_table.png)

## object

查看 obj 的所有 key 以及 values

```javascript
Object.keys(obj);
Object.values(obj);
```

## 递归 dom

```javascript
var els = document.getElementsByClassName("myclass");

Array.prototype.forEach.call(els, function(el) {
    // Do stuff here
    console.log(el.tagName);
});

// Or
[].forEach.call(els, function (el) {...});
```

## 递归检测属性是否存在

查看 obj 内的 obj 的属性的值，避免 undefined 异常

```javascript
var object = {
  innerObject: {
    deepObject: {
      value: "Here am I",
    },
  },
};

if (
  object &&
  object.innerObject &&
  object.innerObject.deepObject &&
  object.innerObject.deepObject.value
) {
  console.log("We found it!");
}

//根据这个特性，我们可以写出如下的用法

var msg = (object && object.innerObject) || "hello";
```

## replaceALl

js 原生没有 replaceAll 方法，可以通过

```js
str = "Test abc test test abc test...".split("abc").join("");
str.split(search).join(replacement);
```

## 事件冒泡

阻止事件冒泡

1. 给子级加 event.stopPropagation( )

   ```javascript
   $("#div1").mousedown(function (e) {
     var e = event || window.event;
     event.stopPropagation();
   });
   ```

2. 在事件处理函数中返回 false

   ```javascript
   $("#div1").mousedown(function (event) {
     var e = e || window.event;
     return false;
   });
   ```

3. event.target==event.currentTarget，让触发事件的元素等于绑定事件的元素，也可以阻止事件冒泡；

   ```javascript
   $("#div1").mousedown(function (event) {
     if (event.target == event.currentTarget) {
       console.log(event);
     }
   });
   ```

## 触发事件与自定义事件

```javascript
const event = new Event("build");

// Listen for the event.
elem.addEventListener(
  "build",
  function (e) {
    /* ... */
  },
  false
);

// Dispatch the event.
elem.dispatchEvent(event);
```

## 数组相关

返回指定长度的数组，类似 java 流的 limit

```javascript
//从0角标最多截取5位
arr.slice(0, 5);
//截取到角标5
arr.slice(5);

//可实现clone
arr.slice();

//从0角标移除1位，返回被删除的元素
arr.splice(0, 1);
```

## URL 参数

对于有`#`锚点的 URL 处理，下述方法是无法使用的

```js
var url_string = "http://www.example.com/t.html?a=1&b=3&c=m2-m3-m4-m5"; //window.location.href
var url = new URL(url_string);
var c = url.searchParams.get("c");
console.log(c);
```

## 判断元素是否包含

```html
<div id="parent">
  <div id="children"></div>
</div>
<script>
  var A = document.getElementById("parent");
  var B = document.getElementById("children");
  console.log(A.contains(B)); //true
</script>
```

## js 方法参数指定默认值

```javascript
function func(n = 100) {
  console.log(n);
}

func(); //100
func(5); //5
```

## console 格式

`%c`标记 css 样式的位置

```javascript
console.log("%c Oh my heavens! ", "background: #222; color: #bada55");
console.log(
  "%c Oh my %c heavens!  ",
  "background: #222; color: #bada55",
  "color: #bada55"
);
```

## cookik

```javascript
//cookie只会新增或覆盖指定key
document.cookie = "a=1"; //a=1
document.cookie = "b=1"; //a=1;b=1
document.cookie = "a=2"; //a=2;b=1
```

## 下载文件

```javascript
var link = document.createElement("a");
link.download = "filename";
link.href = "http://example.com/files";
link.click();
```

## 统计执行时间

```javascript
console.time();
console.timeEnd();
```

## 获取零点时间

```javascript
var d = new Date();
//当天零点的时间戳 00:00:00
d.setHours(0, 0, 0, 0);
//当天午夜的时间戳 23:59:59
d.setHours(24, 0, 0, 0);
```
