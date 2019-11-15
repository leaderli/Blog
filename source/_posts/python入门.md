---
title: python入门
date: 2019-10-10 23:19:22
categories: python
tags: python 
---
## class实例的方法，第一个参数自动转换为实例的索引

第一个参数不一定非要是`self`

## 类方法

直接使用`Class.method(instance)`，参数需要显式的传递实例对象

## python对重载运算符

## 父类构造器

`python`不会自动调用父类构造器,需要显式的调用

```python
class SongBird(Bird):

    def __init__(self):

        Bird.__init__(self)

        self.sound = 'Squawk'

    def sing(self):

        print self.sound

```

## class属性

定义在`class`方法外的属性,`method`本身也属于`class`属性

## 断言

断言自定义提示信息

```python
assert x >= 0, 'x is less than zero'
```

## 更新`PIP`

`python -m pip install -U pip`

## `XML`解析

```python
import xml.etree.ElementTree as ET

tree = ET.parse("country.xml")
root = tree.getroot()
root.tag
root.attrlib

find(match)    # 查找第一个匹配的子元素， match可以时tag或是xpaht路径
findall(match  # 返回所有匹配的子元素列表
findtext(match, default=None)
iter(tag=None) # 以当前元素为根节点 创建树迭代器,如果tag不为None,则以tag进行过滤
iterfind(match)

```

## 调用其他py文件方法

```python
import other

other.m()

```

## 动态调用方法

在`py`文件中，可以使用

```python
def func(arg1,arg2):
    pass

globals()['func'](1,2)
```

调用`class`方法，可以使用

```python
class Data:
    def func(self,arg1,arg2):
        pass

data = Data()
func = getattr(data,'func')
func(1,2)

```

## 字符串格式化

`python`可以使用`''' str '''`,来进行纯字符串赋值，而不需要考虑转译字符。
`python`字符串可定义占位符，通过`format`函数进行格式化

```python
print('{}1{}'.format(0,3))
print('{a}1{b}'.format(** {"a":1,"b":3,}))

```

`json`格式化输出

```python
import json
str = '{"foo":"bar","name":"he"}'
parsed = json.loads(str)
print(json.dumps(parsed,indent=4,sort_keys=True))
```

## 常用函数

### `zip`将多个数组打包成元组

```python
a = [1,2,3]
b = [4,5,6,7,8]
zipped =zip(a,b)       # 元素个数与最短的列表一致
zip(*zipped)           # 与 zip 相反，*zipped 可理解为解压，返回二维矩阵式
```

### `enumerate`函数用于将一个可遍历的数据对象(如列表、元组或字符串)组合为一个索引序列，同时列出数据和数据下标

```python
enumerate(sequence, [start=0])

seasons = ['Spring', 'Summer', 'Fall', 'Winter']
list(enumerate(seasons))
#[(0, 'Spring'), (1, 'Summer'), (2, 'Fall'), (3, 'Winter')]
```

## 返回多个值

```python
def multi():
    return 1,2

x,y = multi()

```

实际上python返回的是一个`tulpe`，在语法上，返回一个tuple可以省略括号，而多个变量可以同时接收一个tuple，按位置赋给对应的值，所以，Python的函数返回多值其实就是返回一个tuple，但写起来更方便.
