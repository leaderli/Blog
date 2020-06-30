---
title: voicexml解析器实现相关
date: 2020-06-10 21:40:41
categories: ivr
tags:
  - voicexml
  - xml
---

## 概述

IVR 系统的测试一般需要电话或软电话，拨号经由呼叫中心平台进入 IVR 系统进行测试，这种测试方式比较慢，且无法进行自动化测试。呼叫中心平台与 IVR 系统的交互使用[VoiceXML](https://www.w3.org/TR/voicexml21/)标准协议，通过编写一个简易的 VoiceXML 解析器，实现对 IVR 系统的模拟请求与根据返回报文自动执行。

## 指令集

通过模仿计算机组成原理的相关知识，我们将每个标签转化为一个由操作码，操作数（一个或多个）的基本操作指令。

精简的 VoiceXML 报文示例

```xml
<vxml version="2.1">
    <var name="_avayaExitReason" expr="''"/>
    <var name="_avayaExitInfo1" expr="''"/>
    <var name="_avayaExitInfo2" expr="''"/>
    <var name="_avayaExitCustomerId" expr="''"/>
    <var name="_avayaExitPreferredPath" expr="'1'"/>
    <var name="_avayaExitTopic" expr="''"/>
    <var name="_avayaExitParentId" expr="''"/>
    <catch event="error.runtime">
        <goto  next="example"/>
    </catch>
    <form>
        <block>
            <throw event="error.runtime.Exception"/>
        </block>
    </form>
    <block>
    </block>
</vxml>
```

上述报文，我们可以定义出以下操作指令

- [ "var" , "_avayaExitReason" , "''" ]
- [ "catch" , "error.runtime" , 0 ]
- [ "goto" , "example" ]
- [ "form" , 0 ]
- [ "block" ]
- [ "throw" , "error.runtimeException" ]

vxml 中标签从上向下顺序执行，若子标签内有其他标签，会先进入子标签内执行，即以深度优先遍历的方式生成指令集。有些标签执行需要满足条件，若`catch`，需要当前有对应的事件抛起时，才会进入标签内执行，所以我们还需要在`catch`处，计算当条件不满足时，下一条指令的位置。按照上文的 demo 报文，我们可以生成如下报文；

0. `var _avayaExitReason ''`
1. `var _avayaExitInfo1 ''`
2. `var _avayaExitInfo2 ''`
3. `var _avayaExitCustomerId ''`
4. `var _avayaExitPreferredPath '1'`
5. `var _avayaExitTopic ''`
6. `var _avayaExitParentId ''`
7. `catch error.runtime 9`
8. `goto example`
9. `form 12`
10. `block 12`
11. `throw error.runtime.Exception`
12. `end`

当报文比较复杂时，我们很难从生成的指令集中很好的观察流程走向，且难以观察程序的层级结构，一些特殊标签，例如 catch（捕获当前标签内抛出的事件，若没有合适的 catch 去处理，则转交父标签处理） 标签的功能难以实现。

## 广度遍历优先

所以我们使用广度优先遍历的方式去生成指令集，在遇到有子标签的情况，我们插入一条`Call`指令，以调用子程序的方式去解释执行子标签，同时在子标签指令集尾部，插入 `Return`指令，使其返回调用子程序处。通过这种方式产生的报文如下：

0. `var _avayaExitReason ''`
1. `var _avayaExitInfo1 ''`
2. `var _avayaExitInfo2 ''`
3. `var _avayaExitCustomerId ''`
4. `var _avayaExitPreferredPath '1'`
5. `var _avayaExitTopic ''`
6. `var _avayaExitParentId ''`
7. `catch error.runtime`
8. `call 12`
9. `form`
10. `call 14`
11. `end`
12. `goto example`
13. `return 9`
14. `block 12`
15. `call 17`
16. `return 11`
17. `throw error.runtime.Exception`
18. `return 16`

这样的报文结构清晰，容易理解，且可以使用栈来实现子程序的调用。例如：我们可以在执行 call 指令时，向下扫描所有 catch，直到 return，这样我们就可以得到当前作用域的所有 catch 事件

下面是示例代码

```java
private void scan(List<Object[]> cmd, DOMElement tag, int callPC) {
    List<Runnable> delayScans = new ArrayList<>();
    List<DOMElement> elements = tag.elements();
    for (DOMElement element : elements) {

        Object[] current = new Object[]{element.getTagName()};
        cmd.add(current);
        List<DOMElement> child = element.elements();
        if (child.size() > 0) {
            Object[] call = new Object[]{"call", 0};
            cmd.add(call);
            //记录子程序入口指针位置
            int after = cmd.size();
            //子程序先不扫描，先遍历当前层级的标签
            delayScans.add(() -> {
                call[1] = cmd.size();
                scan(cmd, element, after);

            });
        }

    }
    //当前标签遍历解释，插入一条返回call的指令
    cmd.add(new Object[]{"return", callPC});
    //继续子程序的扫描
    delayScans.forEach(Runnable::run);
}

List<Object[]> operators = new ArrayList<>();
operators.add(new Object[]{"call", 2});
operators.add(new Object[]{"end",});
scan(operators, root, 1);
```

## 中断系统

为了及时处理事件或 I/O 工作，我们需要在解析器在出现抛出事件，需要打印或者输入参数时，暂时中断现行程序，转而去执行中断服务程序，那么就要求我们设定的指令执行周期尽可能小，在一条原子性指令执行结束后去判断是否需要响应中断事件。
