---
title: python线程
date: 2019-12-24 02:15:49
categories: python
tags:
  - thread
---

## 获取线程执行结果

通过继承自`threading.Thread`，重写其`run`方法来实现

```python
import threading


class MyThread(threading.Thread):
    def __init__(self, *args, **kwargs):
        """
         使用父类构造器，尽量保持语法一致，仅将线程执行结果缓存
        """

        #设定回调
        if 'callable' in kwargs:
            self._callable = kwargs['callable']
            del kwargs['callable']
        super(MyThread, self).__init__(*args, **kwargs)
        self._result = None
        pass

    def run(self):
        if self._target:
            self._result = self._target(*self._args, **self._kwargs)

    def result(self, _callable=None):
        """
        join()确保任务已经执行完成
        :return:
        """
        self.join()
        # 回调
        if _callable is None:
            _callable = self._callable
        if _callable:
            _callable(self._result)
        return self._result

```

测试程序

```python
import threading
import time

def foo():
    time.sleep(1)
    return time.time()


tasks = []
for i in range(10):
    tasks.append(MyThread(target=foo))
for t in tasks:
    t.start()

for t in tasks:
    t.result()

```
