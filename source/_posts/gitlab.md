---
title: gitlab
date: 2020-01-14 01:27:59
categories: tips
tags:
  - git
  - gitlab
---

初始密码
qwer1234

## api

gitlab 提供了一系列 [API](https://docs.gitlab.com/ee/api/) 用于访问或操作 gitlab

例如，查询所有项目

```shell
curl "https://gitlab.example.com/api/v4/projects"
```

一般情况下，有些 API 可能涉及到权限问题，我们可以在 gitlab 上个人设置界面，新增一个用于 WEP API 的 token，然后我们在进行 api 请求时，可将 token 带上

```shell

# 通过请求参数
curl "https://gitlab.example.com/api/v4/projects?private_token=<your_access_token>"


# 通过请求头
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects"
```

有些请求 API 包含一个 path 参数，它们以`:`开头，例如

```shell
DELETE /projects/:id/share/:group_id
```

`:id`就是项目创建时的唯一 id
`:gourp_id`就是组创建时的唯一 id

默认情况下，最多返回前 20 条数据

可通过参数`per_page`（默认 20，最大 100）和`page`(默认为 1)，访问指定位置的数据，我们可以通过指定参数`pagination=keyset`，这样返回报文的报文头的 link 字段，将会包含一个`ref='next'`的指向下一页的链接

```shell
curl --request GET --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects?pagination=keyset&per_page=50&order_by=id&sort=asc"

HTTP/1.1 200 OK
...
Links: <https://gitlab.example.com/api/v4/projects?pagination=keyset&per_page=50&order_by=id&sort=asc&id_after=42>; rel="next"
Link: <https://gitlab.example.com/api/v4/projects?pagination=keyset&per_page=50&order_by=id&sort=asc&id_after=42>; rel="next"
Status: 200 OK
...
```

我们可以通过正则表达式，取出 next 代表的链接地址，递归请求直到没有 next

常用的 API 示例

1. 查看所有项目 `GET /projects`

   - owned 是否仅展示属于当前用户的项目，默认为 false

2. 查看一个项目的所有 tag `GET /projects/:id/repository/tags`
