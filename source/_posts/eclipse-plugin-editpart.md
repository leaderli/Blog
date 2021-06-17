---
title: eclipse-plugin-editpart
date: 2021-05-24 10:15:36
categories:
tags:
---

图形化编辑器以一个 model 出发，根据其对应的 editPart 的方法`createFigure`，来绘制图形，而根据其 editPart 的定义的方法`getModelChildren`来绘制该图形的内部细节。editPart 的方法`createEditPolicies`则用以定义基于该图形的进行操作的策略，对于每个操作来说，都被抽象为一个`Request`请求，而该请求会被发送到 editPart 中，遍历其`policies`

```java
package org.eclipse.gef;

public class Request {
 private Object type;
 private Map extendedData;
}
```

```java

public Command getCommand(Request request) {
  Command command = null;
  EditPolicyIterator i = getEditPolicyIterator();
  while (i.hasNext()) {
   if (command != null)
    command = command.chain(i.next().getCommand(request));
   else
    command = i.next().getCommand(request);
  }
  return command;
 }
```

对于每个 policy 来说，若该 policy 中对于该请求响应，即返回一个非空的 command，则该 command 会作为命令执行链的一环被依次执行。

一般情况下，gef 内部封装了一些 policy，我们不用去直接去对`Request`去做分析以返回具体的 command，我们只需要重写相关方法，即可对指定的`Request`进行处理。

例如`LayoutEditPolicy`中

```java
public Command getCommand(Request request) {
  if (REQ_DELETE_DEPENDANT.equals(request.getType()))
   return getDeleteDependantCommand(request);

  if (REQ_ADD.equals(request.getType()))
   return getAddCommand(request);

  if (REQ_ORPHAN_CHILDREN.equals(request.getType()))
   return getOrphanChildrenCommand(request);

  if (REQ_MOVE_CHILDREN.equals(request.getType()))
   return getMoveChildrenCommand(request);

  if (REQ_CLONE.equals(request.getType()))
   return getCloneCommand((ChangeBoundsRequest) request);

  if (REQ_CREATE.equals(request.getType()))
   return getCreateCommand((CreateRequest) request);

  return null;
 }
```
