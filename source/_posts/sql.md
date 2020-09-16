---
title: sql
date: 2020-09-02 08:17:46
categories:
tags:
---

合并多行表记录

```sql
select code,sum(nums) as counts from table group by code
```

将几种 group 合并为一个

```sql
select
    thecode,
    sum(counts)
from
    (
        select
            case
                when code = '01' then '00'
                else code
            end as thecode,
            counts
        from
            (
                select
                    code,
                    sum(nums) as counts
                from
                    table
                group by
                    code
            )
    )
group by
    thecode
```
