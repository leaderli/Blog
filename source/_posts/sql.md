---
title: sql
date: 2020-09-02 08:17:46
categories:
tags:
---

## 合并多行表记录

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

## 常用 SQL 1

建表语句

```sql
--建学生信息表student
CREATE TABLE student
(
   sno       VARCHAR(20) NOT NULL PRIMARY KEY,
   sname     VARCHAR(20) NOT NULL,
   ssex      VARCHAR(20) NOT NULL,
   sbirthday DATETIME,
   class     VARCHAR(20)

);
--建立教师表
CREATE TABLE teacher
(
   tno       VARCHAR(20) NOT NULL PRIMARY KEY,
   tname     VARCHAR(20) NOT NULL,
   tsex      VARCHAR(20) NOT NULL,
   tbirthday DATETIME,
   prof      VARCHAR(20),
   depart    VARCHAR(20) NOT NULL

);
--建立课程表course
CREATE TABLE course
(
   cno   VARCHAR(20) NOT NULL PRIMARY KEY,
   cname VARCHAR(20) NOT NULL,
   tno   VARCHAR(20) NOT NULL,
   FOREIGN KEY (tno) REFERENCES teacher (tno)

);
--建立成绩表
CREATE TABLE score
(
   sno    VARCHAR(20) NOT NULL,
   FOREIGN KEY (sno) REFERENCES student (sno),
   cno    VARCHAR(20) NOT NULL,
   FOREIGN KEY (cno) REFERENCES course (cno),
   degree DECIMAL

);

--添加学生信息
INSERT INTO student VALUES ('108', '曾华', '男', '1977-09-01', '95033');
INSERT INTO student VALUES ('105', '匡明', '男', '1975-10-02', '95031');
INSERT INTO student VALUES ('107', '王丽', '女', '1976-01-23', '95033');
INSERT INTO student VALUES ('101', '李军', '男', '1976-02-20', '95033');
INSERT INTO student VALUES ('109', '王芳', '女', '1975-02-10', '95031');
INSERT INTO student VALUES ('103', '陆君', '男', '1974-06-03', '95031');

--添加教师表
INSERT INTO teacher VALUES ('804', '李诚', '男', '1958-12-02', '副教授', '计算机系');
INSERT INTO teacher VALUES ('856', '张旭', '男', '1969-03-12', '讲师', '电子工程系');
INSERT INTO teacher VALUES ('825', '王萍', '女', '1972-05-05', '助教', '计算机系');
INSERT INTO teacher VALUES ('831', '刘冰', '女', '1977-08-14', '助教', '电子工程系');

--添加课程表
INSERT INTO course VALUES ('3-105', '计算机导论', '825');
INSERT INTO course VALUES ('3-245', '操作系统', '804');
INSERT INTO course VALUES ('6-166', '数字电路', '856');
INSERT INTO course VALUES ('9-888', '高等数学', '831');
--添加成绩表

INSERT INTO score VALUES ('103', '3-245', '86');
INSERT INTO score VALUES ('105', '3-245', '75');
INSERT INTO score VALUES ('109', '3-245', '68');
INSERT INTO score VALUES ('103', '3-105', '92');
INSERT INTO score VALUES ('105', '3-105', '88');
INSERT INTO score VALUES ('109', '3-105', '76');
INSERT INTO score VALUES ('103', '3-105', '64');
INSERT INTO score VALUES ('105', '3-105', '91');
INSERT INTO score VALUES ('109', '3-105', '78');
INSERT INTO score VALUES ('103', '6-166', '85');
INSERT INTO score VALUES ('105', '6-166', '79');
INSERT INTO score VALUES ('109', '6-166', '81');

```

示例

```sql
#查询教师所有的单位即不重复的Depart列。
SELECT DISTINCT depart FROM teacher;

#查询Score表中成绩在60到80之间的所有记录。
SELECT * FROM score WHERE degree BETWEEN 60 AND 80;

#查询Score表中成绩为85，86或88的记录。
SELECT * FROM score WHERE degree IN (85,86,88);

#查询Student表中“95031”班或性别为“女”的同学记录。
SELECT * FROM student WHERE ssex = '女' OR student.class = 95031;

#以Class降序查询Student表的所有记录。
SELECT * FROM student ORDER BY class DESC ;

#以Cno升序、Degree降序查询Score表的所有记录
SELECT * from score ORDER BY cno ASC ,degree DESC ;

#查询“95031”班的学生人数
SELECT count(*) FROM student WHERE class =95031;

# 查询Score表中的最高分的学生学号和课程号
SELECT sno,cno from score WHERE degree = (SELECT max(degree) FROM score);

#查询每门课的平均成绩
SELECT c.cname,avg(s.degree) FROM score s,course c WHERE s.cno = c.cno GROUP BY s.cno;

#查询Score表中至少有5名学生选修的并以3开头的课程的平均分数。

SELECT cno,avg(degree) FROM score WHERE cno IN (SELECT cno FROM score GROUP BY cno HAVING count(*) > 5);
#查询所有学生的Sname、Cno和Degree列
SELECT sname,cno,degree FROM student s,score c WHERE  s.sno = c.sno;

#查询“张旭“教师任课的学生成绩。
SELECT * from score where cno in (SELECT cno FROM course WHERE tno = (SELECT tno FROM teacher WHERE  tname = '张旭'));

#查询选修某课程的同学人数多于5人的教师姓名
SELECT  tname from teacher where tno in (SELECT tno from course where cno in (SELECT cno from score GROUP BY cno HAVING count(sno) >5));

#查询存在有85分以上成绩的课程Cno.
SELECT distinct cno FROM score where degree >85;

#查询出“计算机系“教师所教课程的成绩表
SELECT * from score where cno in (SELECT cno from course where tno in (SELECT tno FROM teacher WHERE depart = '计算机系'));
SELECT * FROM teacher;

#查询“计算 机系”与“电子工程系“不同职称的教师的Tname和Prof
SELECT tname,prof FROM teacher WHERE depart = '计算机系' and prof NOT IN (SELECT  prof FROM teacher WHERE depart ='电子工程系')
UNION SELECT tname,prof FROM teacher WHERE depart = '电子工程系' and prof NOT IN (SELECT  prof FROM teacher WHERE depart ='计算机系');

#查询选修编号为“3-105“课程且成绩至少高于选修编号为“3-245”的同学的Cno、Sno和Degree,并按Degree从高到低次序排序。
SELECT * FROM  score WHERE cno='3-105' AND degree > ANY (SELECT degree FROM score WHERE degree ='3-245');

#查询选修编号为“3-105”且成绩高于选修编号为“3-245”课程的同学的Cno、Sno和Degree.all:代表括号中的所有成绩
SELECT * FROM  score WHERE cno='3-105' AND degree > ALL (SELECT degree FROM score WHERE degree ='3-245');

#查询所有“女”教师和“女”同学的name、sex和birthday
SELECT sname,ssex,sbirthday FROM student WHERE ssex ='女' UNION SELECT tname,tsex,tbirthday FROM teacher WHERE tsex ='女';

#查询成绩比该课程平均成绩低的同学的成绩表
SELECT sno,degree FROM score  a  WHERE degree < (SELECT avg(degree) FROM score b WHERE a.cno = b.cno);

# 查询所有未讲课的教师的Tname和Depart.
SELECT tname ,depart FROM teacher WHERE tno NOT IN (SELECT DISTINCT tno FROM course WHERE cno IN  (SELECT cno FROM score));

#查询至少有2名男生的班号
SELECT class,count(*) FROM student where ssex='男' GROUP BY class HAVING count(*)>1;

#查询Student表中不姓“王”的同学记录
SELECT * FROM student WHERE sname NOT LIKE '王%';

#查询Student表中每个学生的姓名和年龄
SELECT sname,year(now())-year(sbirthday) as age FROM student;
SELECT * FROM score GROUP BY sno ,degree;

SELECT sno,degree
from score GROUP BY sno ;

SELECT sno,sname from student where sno NOT  IN (SELECT sno FROM score WHERE degree < 70) AND sno IN (SELECT sno FROM score);


SELECT DISTINCT sno FROM score;

```

## 常用 SQL 2

```sql
DROP TABLE IF EXISTS emp;

CREATE TABLE emp (
  empno decimal(4,0) NOT NULL,
  ename varchar(10) default NULL,
  job varchar(9) default NULL,
  mgr decimal(4,0) default NULL,
  hiredate date default NULL,
  sal decimal(7,2) default NULL,
  comm decimal(7,2) default NULL,
  deptno decimal(2,0) default NULL
);

DROP TABLE IF EXISTS dept;

CREATE TABLE dept (
  deptno decimal(2,0) default NULL,
  dname varchar(14) default NULL,
  loc varchar(13) default NULL
);

INSERT INTO emp VALUES ('7369','SMITH','CLERK','7902','1980-12-17','800.00',NULL,'20');
INSERT INTO emp VALUES ('7499','ALLEN','SALESMAN','7698','1981-02-20','1600.00','300.00','30');
INSERT INTO emp VALUES ('7521','WARD','SALESMAN','7698','1981-02-22','1250.00','500.00','30');
INSERT INTO emp VALUES ('7566','JONES','MANAGER','7839','1981-04-02','2975.00',NULL,'20');
INSERT INTO emp VALUES ('7654','MARTIN','SALESMAN','7698','1981-09-28','1250.00','1400.00','30');
INSERT INTO emp VALUES ('7698','BLAKE','MANAGER','7839','1981-05-01','2850.00',NULL,'30');
INSERT INTO emp VALUES ('7782','CLARK','MANAGER','7839','1981-06-09','2450.00',NULL,'10');
INSERT INTO emp VALUES ('7788','SCOTT','ANALYST','7566','1982-12-09','3000.00',NULL,'20');
INSERT INTO emp VALUES ('7839','KING','PRESIDENT',NULL,'1981-11-17','5000.00',NULL,'10');
INSERT INTO emp VALUES ('7844','TURNER','SALESMAN','7698','1981-09-08','1500.00','0.00','30');
INSERT INTO emp VALUES ('7876','ADAMS','CLERK','7788','1983-01-12','1100.00',NULL,'20');
INSERT INTO emp VALUES ('7900','JAMES','CLERK','7698','1981-12-03','950.00',NULL,'30');
INSERT INTO emp VALUES ('7902','FORD','ANALYST','7566','1981-12-03','3000.00',NULL,'20');
INSERT INTO emp VALUES ('7934','MILLER','CLERK','7782','1982-01-23','1300.00',NULL,'10');

INSERT INTO dept VALUES ('10','ACCOUNTING','NEW YORK');
INSERT INTO dept VALUES ('20','RESEARCH','DALLAS');
INSERT INTO dept VALUES ('30','SALES','CHICAGO');
INSERT INTO dept VALUES ('40','OPERATIONS','BOSTON');


``
```

```sql
-- where 后使用别名
select *
    from (
    select sal as salary ,comm as  commision
    from emp
    ) x
where salary < 1000;


-- 使用逻辑表达式
select ename,sal, case
    when sal <= 2000 then 'low'
    when sal >= 4000 then 'high'
    else 'normal'
    end as status
from emp;

-- 按工资级别附件奖金
select ename,sal ,sal * case
    when sal <= 2000 then .1
    when sal >= 4000 then .3
    else .2
    end as bouns
from emp;

-- 查询前几行
select * from emp limit 5;
-- db2
select * from emp fetch first 5 rows only
-- oracle
select * from emp where rownum <= 5



-- 随机查询5条
select * from emp order by rand() limit 5;

-- 空值 非空值

select * from emp where comm is null;
select * from emp where comm is not null;

-- 使用默认值替代null
select coalesce(comm,0) as comm from emp;

select case
    when comm is not null then comm
    else 0
    end
from emp

-- 有逻辑的order by, order by 后可以直接跟数字，表示查询的第几列
select ename,sal,job,comm from emp
order by case
    when job = 'SALESMAN' then comm
    else sal
    end;

select ename,sal,job,comm , case
    when job = 'SALESMAN' then comm
    else sal
    end  as ordered
from emp
order by 5;

-- 查询两个表相同的记录
--创建一个视图
create view V  as
    select ename,job,sal from emp
    where job = 'CLERK';

-- 查询与V表记录相同的全部信息
select e.* from emp e
join V v on
(
    e.ename=v.ename
    and e.job=v.job
    and e.sal=v.sal
)

--  将查询到的记录插入到另一张表，dept_east与dept表结构一模一样
--  select查询出的列数以及数据类型要与insert的表相同

insert into dept_east
    select  * from dept
    where loc in ('NEW YORK','BOSTON')

-- 复制一张表空的表
create table dept_2 as select * from dept where 1 =0;
-- db2
create table dept_2 like dept


```
