---
title: elasticsearch
date: 2020-09-10 13:53:56
categories: db
tags:
---

查询语法，

- [query parameter](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-search.html#search-search-api-query-params)
- [request body](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-search.html#search-search-api-request-body)
- [response body](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-search.html#search-api-response-body)

使用 query parameter 实现模糊搜索

```shell
# 可以模糊搜索text标签中带hello的字符
# q 搜索
# size 默认搜索10条
# order 排序  desc 反向排序
GET /_search?q=text:*hello*&size=100&order=nanotime:desc

```

### wildcard

wildcard 通配符基于分词器分词后的短语进行匹配的，[详细说明文档](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-wildcard-query.html)

### 分词器

测试分词效果

```shell
POST _analyze
{
  "analyzer": "pattern",
  "text": "The 2 QUICK Brown-Foxes jumped over the lazy dog's bone."
}
```

[内置分词器](https://www.elastic.co/guide/en/elasticsearch/reference/7.9/analysis-analyzers.html)
