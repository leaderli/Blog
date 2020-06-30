---
title: mysql
date: 2020-04-23 11:02:55
categories: db
tags:
  - mysql
  - tips
---

设定字段为一个枚举

```mysql
create table test (
  sex enum ("男","女")
)
```

表字段可以设置默认值，当未插入数据时用默认值

```mysql
CREATE TABLE tb_emp1(
  id int(11) AUTO_INCREMENT,
  name VARCHAR(25),
  deptId INT(11) DEFAULT 1234,
  salary FLOAT,
  PRIMARY KEY (id)
);
```

mysql 如何得到一条记录在所有记录的第几行

```mysql
#mysql本身是没有行号的。要想得到查询语句返回的列中包含一列表示该行记录在整个结果集中的行号可以通过自定义set一个变量，然后每条记录+1的方式，返回这个变量的值。

SET @t = 0;
SELECT * FROM (SELECT (@t:=@t+1) as id,s FROM t1) AS A WHERE a.id=2 OR a.id=5;

```

从 dump 文件恢复数据

```mysql
mysqldump -uroot -pPassword [database name] > [dump file]
```

更改编码

```mysql
status;#查看编码
alter database db_name CHARACTER SET utf8;
```

==数据库直接操作时养成习惯不管干啥都先敲个 begin; 确认没问题了再 commit;==

查看数据库信息

```mysql
show variables;
show variables like 'character%';
```
