---
title: js
date: 2020-08-28 16:01:36
categories:
tags:
---

## 名字空间

全局变量会绑定到`window`上，不同的 JavaScript 文件如果使用了相同的全局变量，或者定义了相同名字的顶层函数，都会造成命名冲突，并且很难被发现。

减少冲突的一个方法是把自己的所有变量和函数全部绑定到一个全局变量中。例如：

```javascript
// 唯一的全局变量MYAPP:
var MYAPP = {};

// 其他变量:
MYAPP.name = "myapp";
MYAPP.version = 1.0;

// 其他函数:
MYAPP.foo = function () {
  return "foo";
};
```

把自己的代码全部放入唯一的名字空间`MYAPP`中，会大大减少全局变量冲突的可能。

许多著名的 JavaScript 库都是这么干的：jQuery，YUI，underscore 等等。

## 标准对象

总结一下，有这么几条规则需要遵守：

- 不要使用`new Number()`、`new Boolean()`、`new String()`创建包装对象；
- 用`parseInt()`或`parseFloat()`来转换任意类型到`number`；
- 用`String()`来转换任意类型到`string`，或者直接调用某个对象的`toString()`方法；
- 通常不必把任意类型转换为`boolean`再判断，因为可以直接写`if (myVar) {...}`；
- `typeof`操作符可以判断出`number`、`boolean`、`string`、`function`和`undefined`；
- 判断`Array`要使用`Array.isArray(arr)`；
- 判断`null`请使用`myVar === null`；
- 判断某个全局变量是否存在用`typeof window.myVar === 'undefined'`；
- 函数内部判断某个变量是否存在用`typeof myVar === 'undefined'`。

最后有细心的同学指出，任何对象都有`toString()`方法吗？`null`和`undefined`就没有！确实如此，这两个特殊值要除外，虽然`null`还伪装成了`object`类型。

更细心的同学指出，`number`对象调用`toString()`报 SyntaxError：

```javascript
123.toString(); // SyntaxError
```

遇到这种情况，要特殊处理一下：

```javascript
(123).toString(); // '123', 注意是两个点！
(123).toString(); // '123'
```

不要问为什么，这就是 JavaScript 代码的乐趣！

## JSON

在 JSON 中，一共就这么几种数据类型,并且，JSON 还定死了字符集必须是 UTF-8，表示多语言就没有问题了。为了统一解析，JSON 的字符串规定必须用双引号`""`，Object 的键也必须用双引号`""`。

- `number`：和 JavaScript 的 number 完全一致；

- `boolean`：就是 JavaScript 的 true 或 false；

- `string`：就是 JavaScript 的 string；

- `null`：就是 JavaScript 的 null；

- `array`：就是 JavaScript 的 Array 表示方式——[]；

- `object`：就是 JavaScript 的{ ... }表示方式。

## COOKIE

服务器在设置 Cookie 时可以使用 httpOnly，设定了 httpOnly 的 Cookie 将不能被 JavaScript 读取。这个行为由浏览器实现，主流浏览器均支持 httpOnly 选项，IE 从 IE6 SP1 开始支持。

为了确保安全，服务器端在设置 Cookie 时，应该始终坚持使用 httpOnly。

## 作用域

1. 在 object 内的 function this 指向 object，而属于 function 内部的闭包函数 this 指向 window 对象,纯 function this 也指向 window 对象。

2. “自由变量”。在 A 作用域中使用的变量 x，却没有在 A 作用域中声明（即在其他作用域中声明的），对于 A 作用域来说，x 就是一个自由变量。如下

   ```javascript
   var x = 10;
   function fn() {
     var b = 20;
     console.log(x + b); //这里的x在这里就是一个自由变量
   }
   ```

3. 为 Object.prototype 赋值，相当于在 window 对象上赋值

如上程序中，在调用 fn()函数时，函数体中第 6 行。取 b 的值就直接可以在 fn 作用域中取，因为 b 就是在这里定义的。而取 x 的值时，就需要到另一个作用域中取。到哪个作用域中取呢？

有人说过要到父作用域中取，其实有时候这种解释会产生歧义。例如：

```javascript
var x = 10;
function fn() {
  console.log(x);
}
function show(f) {
  var x = 20;
  (function () {
    f(); //10 而不是20
  })();
}
show(fn);
```

要到创建这个函数的那个作用域中取值——是“创建”，而不是“调用”，切记切记——其实这就是所谓的“静态作用域”。

## 原型

```javascript
function Fn() {}
Fn.prototype.name = "xiaoming";
Fn.prototype.getYear = function () {
  return 1988;
};

var fn = new Fn();
console.log(fn.name);
console.log(fn.getYear());
```

1. 函数 Fn 也是对象，每个函数都有一个属性`prototype`，`prototype`的值为原型对象
2. fn 为 Fn 函数的一个实例对象，每个对象都有一个隐藏属性 `__proto__`,fn 的`__proto__`指向 Fn 的`prototype`，即原型对象。
3. Object.prototype 是一个特例——它的`__proto__`指向的是 null
4. 访问一个对象的属性时，先在基本属性中查找，如果没有，再沿着`__proto__`这条链向上找，这就是原型链。

   ![js-tips_2020-04-25-13-18-14.png](./images/js-tips_2020-04-25-13-18-14.png)

我们以一个例子来说明

```javascript
var ob = {
  f: function () {
    console.log(this.a);
    console.log(a);
  },
};
// 变量ob的声明为语法糖，等同于 ob = Object()
// ob的__proto__指向 Object.prototype，即所有实例对象的最顶层的原型对象
// ob.f 方法中 this.a，
ob.__proto__.a = 1;
ob.__proto__ = { a: 2 };
ob.f();
```

输出结果

> 2
> 1

## this

this 到底取何值，是在函数真正被调用执行的时候确定的，函数定义的时候确定不了

1. 在全局环境下，this 永远是 window
2. 函数作为构造函数用，那么其中的 this 就代表它即将 new 出来的对象
3. 如果函数作为对象的一个属性时，并且作为对象的一个属性被调用时，函数中的 this 指向该对象
4. 一个函数被 call 和 apply 调用时，this 的值就取传入的对象的值
5. 箭头函数体内的 this 对象就是定义时所在的对象，而不是使用时的对象

## 执行上下文

函数表达式”和“函数声明”。虽然两者都很常用，但是这两者在“准备工作”时，却是两种待遇。

```javascript
console.log(f1); // function f1(){};
console.log(f2); //undefined
function f1() {}
var f2 = function () {};
```

在初始化时，对待函数表达式就像对待“ var a = 10 ”这样的变量一样，只是声明。而对待函数声明时，却把函数整个赋值了。

全局代码的上下文环境数据内容为：

好了，总结完了函数的附加内容，我们就此要全面总结一下上下文环境的数据内容。

全局代码的上下文环境数据内容为：

- 普通变量（包括函数表达式），如： var a = 10; `声明（默认赋值为undefined）`
  - 函数声明，如： function fn() { } `赋值`
    - this `赋值`

如果代码段是函数体，那么在此基础上需要附加：

- 参数 `赋值`
  - arguments `赋值`
  - 自由变量的取值作用域 `赋值`

给执行上下文环境下一个通俗的定义——在执行代码之前，把将要用到的所有的变量都事先拿出来，有的直接赋值了，有的先用`undefined`占个空。

## 匿名函数

js 函数前加分号和感叹号是什么意思？有什么用？

```javascript
// 这么写会报错，因为这是一个函数定义：
function() {}()

// 常见的（多了一对括号），调用匿名函数：
(function() {})()

// 但在前面加上一个布尔运算符（只多了一个感叹号），就是表达式了，将执行后面的代码，也就合法实现调用
!function() {}()
```

在前面加上~+-等一元操作符也可以。。其实还有好几种符合都可以保证匿名函数声明完就立即执行

var hi = function(){ alert("hi") };
hi();
等于...
(function(){ alert("hi") })();
!、+和()一样的效果可以把换成
!function(){ alert("hi") }();
!比()节省一个字符，或者说比()好看些
我们都知道分号是为了和前面的代码隔开，js 可以用换行分隔代码，但是合并压缩多个 js 文件之后，换行符一般会被删掉，所以连在一起可能会出错，加上分号就保险了。
一元操作符会对 func 的返回值进行实际运算

### 语法糖

1. 一般对象格式如下

   ```javascript
   obj = {
     a: "a",
     b: "b",
   };
   ```

   当值为一个对象的时候，我们可以使用简写方式

   ```javascript
   c = {};
   obj = {
     c,
   };
   ```

2. 变量声明

   ```javascript
   obj = {
     a: "a",
     b: "b",
   };

   var { a, b } = obj;
   console.log(a);
   console.log(b);
   ```
