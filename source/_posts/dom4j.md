---
title: dom4j
date: 2020-05-28 09:45:54
categories: java
tags:
  - dom4j
---

## SAXReader

`feature`属性，禁止校验`dtd`文件

使用 dom4j 解析 xml

```java
import com.sun.org.apache.xerces.internal.impl.Constants;

/**
 * 在读取文件时，去掉dtd的验证，可以缩短运行时间
 */
public static SAXReader getSAXReader(){
    SAXReader saxReader = new SAXReader(DOMDocumentFactory.getInstance(),false);
     try {
         saxReader.setFeature(Constants.XERCES_FEATURE_PREFIX + Constants.LOAD_EXTERNAL_DTD_FEATURE, false);  //设置不需要校验头文件
     } catch (Exception e) {
         e.printStackTrace();
     }
     return saxReader;
 }
```

读取`String`为`DOMDocument`

```java
String xml = "...xml...";
DOMDocument document = (DOMDocument) getSAXReader().read(new StringReader(xml));
```

## DOMElement

顺序读取文本内容和子元素

```java
DOMElement root = doc.getRootElement();
for(Object element : root.content()){
    if( o instanceof DOMElement){
        System.out.println(((DOMElement)o).asXML())
    }
    if( o instanceof DOMText){
        System.out.println(((DOMText)o).getText().trim())
    }
}
```

## 格式化输出

```java
//document 
OutputFormat format = OutputFormat.createPrettyPrint();
XMLWriter   writer = new XMLWriter(System.out, format);
writer.write(document);
writer.close();
//输出的为格式化后的文本
System.out.println(document.asXML())
```

## XPATH

`dom4j`直接获取值

```java
doc.selectObject("substring(/root/name/text(),2)");

//选择所有有id属性元素(List<DOMAttribute>)，当属性仅为一个时，其返回值不为List
doc.selectObject("/root/@id")
//获取第一个匹配标签的id属性的值
doc.selectObject("string(/root/@id)")

//搜索当前dom的子节点
dom.selectNodes("child/name/text()")
```

### XPATH 一些语法

- `para` 选择所有名为 para 的子节点
- `*` 选择所有子节点
- `text()`选择所有子节点文本
- `@name` 选择所有名为 name 的节点属性
- `@*` 选择所有节点属性
- `para[1]` 选择名为 para 的第一个节点
- `para[fn:last()]` 选择名为 para 的最后一个节点
- `//` 从根节点查找所有节点
- `..` 选择父节点
- `.` 选择当前节点
- `and`,`or`操作符

一些示例

```shell

chapter[@title="one"]

book/(chapter|appendix)/section

employee[@secretary and @assistant]

chapter[@title="one" or @title="two" and  author="li"]
```

[xpath 语法详细规则](https://www.w3.org/TR/xpath-30/)

### 获取`tomcat`运行端口

```java
//通过classpath定位tomcat配置文件conf/server.xml，使用xpath去解析
File serverXml = new File("/Users/li/java/apache-tomcat-7.0.70/conf/server.xml");
DocumentBuilderFactory domFactory = DocumentBuilderFactory.newInstance();
domFactory.setNamespaceAware(true); // never forget this!
DocumentBuilder builder = domFactory.newDocumentBuilder();
Document doc = builder.parse(serverXml);
XPathFactory factory = XPathFactory.newInstance();
XPath xpath = factory.newXPath();
XPathExpression expr = xpath.compile("/Server/Service[@name='Catalina']/Connector[starts-with(@protocol,'HTTP')]/@port[1]");
String result = (String) expr.evaluate(doc, XPathConstants.STRING);
port = result != null && result.length() > 0 ? Integer.valueOf(result) : null;
```

## 命令空间

当 xml 报文中，含有`xmlns='xxx'`的命名空间时，会造成 xpath 查找不到指定的节点。可以将所有命令空间的属性替换掉。
