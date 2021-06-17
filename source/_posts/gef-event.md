---
title: gef-event
date: 2021-01-21 14:12:33
categories: eclipse
tags:
  - gef
---

model 类，仅展示原理，省略部分代码

```java

import java.util.List;

public class FlowNode {

    private List<GotoNode> gotoNodes;

    public List<GotoNode> getGotoNodes() {
    return gotoNodes;
    }
    public void setGotoNodes(List<GotoNode> gotoNodes) {
    this.gotoNodes = gotoNodes;
    }

}



public class GotoNode {

}

```

各自对应的 editpart,节选部分代码，仅展示原理

```java

class FlowNodeEditPart extends AbstractGraphicalEditPart implements NodeEditPart {


    private IFigure contentPane = new Figure();

    @Override
    protected IFigure createFigure() {
        Figure flowNodeFigure = new Figure();
        flowNodeFigure.add(this.contentPane);
        return flowNodeFigure;
    }

    @Override
    protected List<GotoNode> getModelChildren() {
    return getModel().getGotoNodes();

    }
    /**
    * 子model所在容器的figure
    */
    @Override
    public IFigure getContentPane() {
        return getContentFigure();
    }
}


class GotoNodeEditPart extends AbstractGraphicalEditPart implements NodeEditPart {



    @Override
    protected IFigure createFigure() {
        return new Figure();
    }
}
```

当 FlowNode 绘制自己时，会在其 getContentPane 的图形上，绘制自己的子 model，通过调用`org.eclipse.gef.editparts.AbstractEditPart.refreshChildren()`方法来绘制。

```java
protected void refreshChildren() {
    int i;
    EditPart editPart;
    Object model;

    List children = getChildren();
    int size = children.size();
    Map modelToEditPart = Collections.EMPTY_MAP;
    if (size > 0) {
    modelToEditPart = new HashMap(size);
    for (i = 0; i < size; i++) {
        editPart = (EditPart) children.get(i);
        modelToEditPart.put(editPart.getModel(), editPart);
    }
    }

    List modelObjects = getModelChildren();
    for (i = 0; i < modelObjects.size(); i++) {
    model = modelObjects.get(i);

    if (i < children.size()
        && ((EditPart) children.get(i)).getModel() == model)
        continue;
    editPart = (EditPart) modelToEditPart.get(model);

    if (editPart != null)
        reorderChild(editPart, i);
    else {
        //找到model对应的editpart
        editPart = createChild(model);
        //将其与figure进行绑定
        addChild(editPart, i);
    }
    }

    size = children.size();
    if (i < size) {
    List trash = new ArrayList(size - i);
    for (; i < size; i++)
        trash.add(children.get(i));
    for (i = 0; i < trash.size(); i++) {
        EditPart ep = (EditPart) trash.get(i);
        //移除figure对应的editPart缓存
        removeChild(ep);
    }
    }
 }


 protected void addChild(EditPart child, int index) {
    Assert.isNotNull(child);
    if (index == -1)
    index = getChildren().size();
    if (children == null)
    children = new ArrayList(2);

    children.add(index, child);
    child.setParent(this);
    addChildVisual(child, index);
    child.addNotify();

    if (isActive())
    child.activate();
    fireChildAdded(child, index);
 }


public void addNotify() {
    register();
    createEditPolicies();
    List children = getChildren();
    for (int i = 0; i < children.size(); i++)
    ((EditPart) children.get(i)).addNotify();
    refresh();
}

protected void register() {
    registerModel();
    registerVisuals();
    registerAccessibility();
 }


 protected void registerVisuals() {
    getViewer().getVisualPartMap().put(getFigure(), this);
 }
```

当我们触发一个鼠标移动事件时，它会查询当前位置的 figure 对应的 editPart，然后使用对应 editPart 的 policy 来处理相关事件。

```java
protected boolean updateTargetUnderMouse() {
  if (!isTargetLocked()) {
   EditPart editPart = null;
   if (getCurrentViewer() != null)
    editPart = getCurrentViewer().findObjectAtExcluding(
      getLocation(), getExclusionSet(),
      getTargetingConditional());
   if (editPart != null)
    editPart = editPart.getTargetEditPart(getTargetRequest());
   boolean changed = getTargetEditPart() != editPart;
   setTargetEditPart(editPart);
   return changed;
  } else
   return false;
 }


 public EditPart findObjectAtExcluding(Point pt, Collection exclude,
   final Conditional condition) {
  class ConditionalTreeSearch extends ExclusionSearch {
   ConditionalTreeSearch(Collection coll) {
    super(coll);
   }

   public boolean accept(IFigure figure) {
    EditPart editpart = null;
    while (editpart == null && figure != null) {
    //这里我们就可以取出前面对应figure，缓存的editPart了，如果找不到会一直向上层figure去查找。
     editpart = (EditPart) getVisualPartMap().get(figure);
     figure = figure.getParent();
    }
    return editpart != null
      && (condition == null || condition.evaluate(editpart));
   }
  }
  IFigure figure = getLightweightSystem().getRootFigure().findFigureAt(
    pt.x, pt.y, new ConditionalTreeSearch(exclude));
  EditPart part = null;
  while (part == null && figure != null) {
   part = (EditPart) getVisualPartMap().get(figure);
   figure = figure.getParent();
  }
  if (part == null)
   return getContents();
  return part;
 }

```

## 多页编辑器触发图元的删除命令

对于多页编辑器`MultiPageEditorPart`中的某一页，其编辑器（FlowEditor 继承自 `GraphicalEditorWithFlyoutPalette`，一个图形化编辑器）。当我们在使用`FlowEditor`时，我们在其图形编辑器上使用鼠标选择图元时，默认会触发`GraphicalEditorWithFlyoutPalette`的方法`selectionChanged`

其下是部分源码

```java
//SelectionService
private void notifyListeners(IWorkbenchPart workbenchPart, ISelection selection,
   ListenerList<ISelectionListener> listenerList) {
  for (ISelectionListener listener : listenerList) {
   if (selection != null || listener instanceof INullSelectionListener) {
    listener.selectionChanged(workbenchPart, selection);
   }
  }
 }
//GraphicalEditorWithFlyoutPalette
public void selectionChanged(IWorkbenchPart part, ISelection selection) {
  if (this.equals(getSite().getPage().getActiveEditor()))
   updateActions(selectionActions);
 }
```

对于 MultiPageEditorPart 来说，getSite().getPage().getActiveEditor()返回的是 MultiPageEditorPart，所以 FlowEditor 需要重写这个方法

```java
 @Override
 public void selectionChanged(IWorkbenchPart part, ISelection selection) {
  IWorkbenchPartSite site = this.getSite();
  if (site != null) {
   IWorkbenchWindow window = site.getWorkbenchWindow();
   if (window != null) {
    IWorkbenchPage page = window.getActivePage();
    if (page != null) {
     IEditorPart editorPart = page.getActiveEditor();
     if (editorPart != null) {
      this.updateActions(this.getSelectionActions());
     }
    }
   }
  }
 }
```
