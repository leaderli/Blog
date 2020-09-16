---
title: postgres
date: 2020-09-09 11:09:01
categories: db
tags:
---

省略 linux 安装过程，安装后一般会创建一个 postgres 用户，该用户具有数据库超级用户权限。

```shell
~$ psql
psql(9.5.17)
Type "help" for help.

postgres=#
```

也可以使用命令行登录

```shell
psql -h localhost -p 5432 -U postgress myBd
```

在 postgres cli 操作界面

```shell
# 退出postgres
\q

# 查看所有数据库
\l

# c + 数据库  进入数据库
\c myDB


# 显示所有表
\d

# 显示表信息
\d tableName
```

sql 语句，在 postgres cli 操作界面写 sql 语句，需要以`;`分割，可以用回车将 sql 分多行来写
