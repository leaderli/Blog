---
title: bitOperation
date: 2019-10-19 19:59:26
categories: java
tags:
  - bit
---

在 Java 中，位运算符有很多，例如与`&`、非`~`、或`|`、异或`^`、移位`<<`和`>>`等。这些运算符在日常编码中很少会用到。

## 位运算解释

### `或非操作 ^`

对于 x ^ y，如果y的位是0，那么取x的原始值，如果y的位是1，那么取x此位的补，例如

```python
0b1111 ^ 0b0101 = 0b1010
0b1111 ^ 0b1 = 0b1110 # 自动填0
```

在下面的一个例子中，会用到位掩码`BitMask`，其中包含大量的位运算。不只是在`Java`中，其他编写语言中也是可以使用的。

例如，在一个系统中，用户一般有查询`Select`、新增`Insert`、修改`Update`、删除`Delete`四种权限，四种权限有多种组合方式，也就是有`16`中不同的权限状态（2 的 4 次方）。

## `Permission`

一般情况下会想到用四个`boolean`类型变量来保存：

```java
public class Permission {
    // 是否允许查询
    private boolean allowSelect;
    // 是否允许新增
    private boolean allowInsert;
    // 是否允许删除
    private boolean allowDelete;
    // 是否允许更新
    private boolean allowUpdate;
}
```

上面用四个 boolean 类型变量来保存每种权限状态。

## `NewPermission`

下面是另外一种方式，使用位掩码的话，用一个二进制数即可，每一位来表示一种权限，`0`表示无权限，`1`表示有权限。

```java
public class NewPermission {
    // 是否允许查询，二进制第1位，0表示否，1表示是
    public static final int ALLOW_SELECT = 1 << 0; // 0001
    // 是否允许新增，二进制第2位，0表示否，1表示是
    public static final int ALLOW_INSERT = 1 << 1; // 0010
    // 是否允许修改，二进制第3位，0表示否，1表示是
    public static final int ALLOW_UPDATE = 1 << 2; // 0100
    // 是否允许删除，二进制第4位，0表示否，1表示是
    public static final int ALLOW_DELETE = 1 << 3; // 1000
    // 存储目前的权限状态
    private int flag；
    /**
        *  重新设置权限
        */
    public void setPermission(int permission) {
        flag = permission;
    }
    /**
        *  添加一项或多项权限
        */
    public void enable(int permission) {
        flag |= permission;
    }
    /**
        *  删除一项或多项权限
        */
    public void disable(int permission) {
        flag &= ~permission;
    }
    /**
        *  是否拥某些权限
        */
    public boolean isAllow(int permission) {
        return (flag & permission) == permission;
    }
    /**
        *  是否禁用了某些权限
        */
    public boolean isNotAllow(int permission) {
        return (flag & permission) == 0;
    }
    /**
        *  是否仅仅拥有某些权限
        */
    public boolean isOnlyAllow(int permission) {
        return flag == permission;
    }
}

```

以上代码中，用四个常量表示了每个二进制位代码的权限项。

例如：

`ALLOW_SELECT = 1 << 0` 转成二进制就是`0001`，二进制第一位表示`Select`权限。
`ALLOW_INSERT = 1 << 1` 转成二进制就是`0010`，二进制第二位表示`Insert`权限。

`private int flag`存储了各种权限的启用和停用状态，相当于代替了`Permission`中的四个`boolean`类型的变量。

用`flag`的四个二进制位来表示四种权限的状态，每一位的 0 和 1 代表一项权限的启用和停用，下面列举了部分状态表示的权限：

| flag     | 删除 | 修改 | 新增 | 查询 |                                   |
| -------- | ---- | ---- | ---- | ---- | --------------------------------- |
| 1(0001)  | 0    | 0    | 0    | 1    | 只允许查询（即等于 ALLOW_SELECT） |
| 2(0010)  | 0    | 0    | 1    | 0    | 只允许新增（即等于 ALLOW_INSERT） |
| 4(0100)  | 0    | 1    | 0    | 0    | 只允许修改（即等于 ALLOW_UPDATE） |
| 8(1000)  | 1    | 0    | 0    | 0    | 只允许删除（即等于 ALLOW_DELETE） |
| 3(0011)  | 0    | 0    | 1    | 1    | 只允许查询和新增                  |
| 0        | 0    | 0    | 0    | 0    | 四项权限都不允许                  |
| 15(1111) | 1    | 1    | 1    | 1    | 四项权限都允许                    |

使用位掩码的方式，只需要用一个大于或等于`0`且小于`16`的整数即可表示所有的 16 种权限的状态。

此外，还有很多设置权限和判断权限的方法，需要用到位运算，例如：

```java
public void enable(int permission) {
    flag |= permission; // 相当于flag = flag | permission;
}
```

调用这个方法可以在现有的权限基础上添加一项或多项权限。

添加一项`Update`权限：

```java
permission.enable(NewPermission.ALLOW_UPDATE);
```

假设现有权限只有`Select`，也就是`flag`是`0001`。执行以上代码，`flag = 0001 | 0100`，也就是`0101`，便拥有了`Select`和`Update`两项权限。

添加`Insert`、`Update`、`Delete`三项权限：

```java
permission.enable(NewPermission.ALLOW_INSERT
    | NewPermission.ALLOW_UPDATE | NewPermission.ALLOW_DELETE);

```

`NewPermission.ALLOW_INSERT | NewPermission.ALLOW_UPDATE | NewPermission.ALLOW_DELETE`运算结果是`1110`。假设现有权限只有`Select`，也就是`flag`是`0001`。`flag = 0001 | 1110，也就是1111`，便拥有了这四项权限，相当于添加了三项权限。

上面的设置如果使用最初的`Permission`类的话，就需要下面三行代码：

```java
permission.setAllowInsert(true);
permission.setAllowUpdate(true);
permission.setAllowDelete(true);
```

## 二者对比

### 设置仅允许 Select 和 Insert 权限

Permission

```java
permission.setAllowSelect(true);
permission.setAllowInsert(true);
permission.setAllowUpdate(false);
permission.setAllowDelete(false);
```

NewPermission

```java
permission.setPermission(NewPermission.ALLOW_SELECT | NewPermission.ALLOW_INSERT);
```

### 判断是否允许 Select 和 Insert、Update 权限

`Permission`

```java
if (permission.isAllowSelect() && permission.isAllowInsert() && permission.isAllowUpdate())
```

`NewPermission`

```java
if (permission. isAllow (NewPermission.ALLOW_SELECT
    | NewPermission.ALLOW_INSERT | NewPermission.ALLOW_UPDATE))
```

### 判断是只否允许 Select 和 Insert 权限

`Permission`

```java
if (permission.isAllowSelect() && permission.isAllowInsert()
    && !permission.isAllowUpdate() && !permission.isAllowDelete())
```

`NewPermission`

```java
if (permission. isOnlyAllow (NewPermission.ALLOW_SELECT | NewPermission.ALLOW_INSERT))
```

二者对比可以感受到`MyPermission`位掩码方式相对于`Permission`的优势，可以节省很多代码量，位运算是底层运算，效率也非常高，而且理解起来也很简单。
