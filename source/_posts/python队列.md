---
title: python队列
date: 2019-12-24 01:15:32
categories: python
tags:
  - queue
  - thread
---

我们直接以代码示例来分析

```python
import queue
import threading
import time


def do_work(item, result):
    time.sleep(1)
    result.append(item)


def worker(_queue, _result):
    while True:
        item = _queue.get()
        if item is None:
            break
        do_work(item, _result)
        _queue.task_done()


def join(_queue, num):
    _queue.join()
    for x in range(num):
        _queue.put(None)


q = queue.Queue()
results = []
threads = []
num_worker_threads = 10
for i in range(num_worker_threads):
    t = threading.Thread(target=worker, args=(q, results))
    t.start()
    threads.append(t)

for x in range(50):
    q.put(x)
print('size:', q.qsize())
join(q, num_worker_threads)
print('result:', len(results))
```

我们查看`queue.join()`的源码

```python
def join(self):
    with self.all_tasks_done:
        #当unfinished_tasks不为0时一直等待
        while self.unfinished_tasks:
            self.all_tasks_done.wait()
```

```python
    def put(self, item, block=True, timeout=None):
        with self.not_full:
            if self.maxsize > 0:
                if not block:
                    if self._qsize() >= self.maxsize:
                        raise Full
                elif timeout is None:
                    while self._qsize() >= self.maxsize:
                        self.not_full.wait()
                elif timeout < 0:
                    raise ValueError("'timeout' must be a non-negative number")
                else:
                    endtime = time() + timeout
                    while self._qsize() >= self.maxsize:
                        remaining = endtime - time()
                        if remaining <= 0.0:
                            raise Full
                        self.not_full.wait(remaining)
            self._put(item)
            #put时unfinished_tasks+1
            self.unfinished_tasks += 1
            self.not_empty.notify()
```

```python
 def task_done(self):
        with self.all_tasks_done:
            #task_done时unfinished_tasks-1
            unfinished = self.unfinished_tasks - 1
            if unfinished <= 0:
                if unfinished < 0:
                    raise ValueError('task_done() called too many times')
                self.all_tasks_done.notify_all()
            self.unfinished_tasks = unfinished
```

根据上述源码我们可以知道，当调用了指定次数的`task_done`时，`join`方法或重新获取到锁，从而离开阻塞状态，对于我们定义的方法`join(_queue, num)`,中先`_queue.joins`,再`put(None)`的原因，是因为我们消费时，当`item`为`None`时直接结束线程执行，而没有再调用一次`task_done`。
我们可以用上述示例，来实现一个简单的线程池
