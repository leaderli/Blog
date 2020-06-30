---
title: oracle练习
date: 2019-07-04 17:16:47
categories: db
tags:
  - sql
  - oracle
---

### 建表语句和数据插入

```sql
create table STUDENT
(
SNO VARCHAR2(20) not null
primary key,
SNAME VARCHAR2(20) not null,
SSEX VARCHAR2(20) not null,
SBIRTHDAY DATE,
CLASS VARCHAR2(20)
);

create table TEACHER
(
TNO VARCHAR2(20) not null
primary key,
TNAME VARCHAR2(20) not null,
TSEX VARCHAR2(20) not null,
TBIRTHDAY DATE,
PROF VARCHAR2(20),
DEPART VARCHAR2(20) not null
);

create table COURSE
(
CNO VARCHAR2(20) not null
primary key,
CNAME VARCHAR2(20) not null,
TNO VARCHAR2(20) not null
references TEACHER
);

create table SCORE
(
SNO VARCHAR2(20) not null
references STUDENT,
CNO VARCHAR2(20) not null
references COURSE,
DEGREE NUMBER
);

--添加学生信息
INSERT INTO student VALUES ('108', '曾华', '男', to_date('1977-09-01','yyyy-mm-dd'), '95033');
INSERT INTO student VALUES ('105', '匡明', '男', to_date('1975-10-02','yyyy-mm-dd'), '95031');
INSERT INTO student VALUES ('107', '王丽', '女', to_date('1976-01-23','yyyy-mm-dd'), '95033');
INSERT INTO student VALUES ('101', '李军', '男', to_date('1976-02-20','yyyy-mm-dd'), '95033');
INSERT INTO student VALUES ('109', '王芳', '女', to_date('1975-02-10','yyyy-mm-dd'), '95031');
INSERT INTO student VALUES ('103', '陆君', '男', to_date('1974-06-03','yyyy-mm-dd'), '95031');

--添加教师表
INSERT INTO teacher VALUES ('804', '李诚', '男', to_date('1958-12-02','yyyy-mm-dd'), '副教授', '计算机系');
INSERT INTO teacher VALUES ('856', '张旭', '男', to_date('1969-03-12','yyyy-mm-dd'), '讲师', '电子工程系');
INSERT INTO teacher VALUES ('825', '王萍', '女', to_date('1972-05-05','yyyy-mm-dd'), '助教', '计算机系');
INSERT INTO teacher VALUES ('831', '刘冰', '女', to_date('1977-08-14','yyyy-mm-dd'), '助教', '电子工程系');

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

## 习题

```sql
--查询教师所有的单位即不重复的Depart列。
--查询Score表中成绩在60到80之间的所有记录。
--查询Score表中成绩为85，86或88的记录。
--查询Student表中“95031”班或性别为“女”的同学记录。
--以Class降序查询Student表的所有记录。
--以Cno升序、Degree降序查询Score表的所有记录
--查询“95031”班的学生人数
--查询Score表中的最高分的学生学号和课程号
--查询每门课的平均成绩
--查询Score表中至少有5名学生选修的并以3开头的课程的平均分数。
--查询所有学生的Sname、Cno和Degree列
--查询“张旭“教师任课的学生成绩。
--查询选修某课程的同学人数多于5人的教师姓名
--查询存在有85分以上成绩的课程Cno.
--查询出“计算机系“教师所教课程的成绩表
--查询“计算 机系”与“电子工程系“不同职称的教师的Tname和Prof
--查询选修编号为“3-105“课程且成绩至少高于选修编号为“3-245”的同学的Cno、Sno和Degree,并按Degree从高到低次序排序。
--查询选修编号为“3-105”且成绩高于选修编号为“3-245”课程的同学的Cno、Sno和Degree.all:代表括号中的所有成绩
--查询所有“女”教师和“女”同学的name、sex和birthday
--查询成绩比该课程平均成绩低的同学的成绩表
--查询所有未讲课的教师的Tname和Depart.
--查询至少有2名男生的班号
--查询Student表中不姓“王”的同学记录
--查询Student表中每个学生的姓名和年龄
```

## 答案

```sql
--查询教师所有的单位即不重复的Depart列。
SELECT DISTINCT depart
FROM teacher;
--查询Score表中成绩在60到80之间的所有记录。
SELECT *
FROM SCORE
WHERE DEGREE >= 60 AND DEGREE <= 80;
SELECT *
FROM SCORE
WHERE DEGREE BETWEEN 60 AND 80;
--查询Score表中成绩为85，86或88的记录。
SELECT *
FROM SCORE
WHERE DEGREE IN (85, 86, 88);
--查询Student表中“95031”班或性别为“女”的同学记录。
SELECT *
FROM STUDENT
WHERE CLASS = '95031' AND SSEX = '女';
--以Class降序查询Student表的所有记录。
SELECT *
FROM STUDENT
ORDER BY CLASS DESC;
--以Cno升序、Degree降序查询Score表的所有记录
SELECT *
FROM SCORE
ORDER BY CNO ASC, DEGREE DESC;
--查询“95031”班的学生人数
SELECT count(1)
FROM STUDENT
WHERE CLASS = '95031';
-- 查询Score表中的最高分的学生学号和课程号
SELECT *
FROM SCORE
WHERE DEGREE = (SELECT max(DEGREE)
                FROM SCORE);
--查询每门课的平均成绩
SELECT *
FROM SCORE;
SELECT
  CNO,
  round(avg(DEGREE), 2)
FROM SCORE
GROUP BY CNO;
--查询Score表中至少有5名学生选修的并以3开头的课程的平均分数。
SELECT
  CNO,
  round(avg(DEGREE), 2)
FROM SCORE
WHERE CNO IN (SELECT CNO
              FROM (SELECT
                      CNO,
                      count(1) AS ccno
                    FROM SCORE
                    GROUP BY CNO) a
              WHERE a.ccno > 5)
GROUP BY CNO;
--查询所有学生的Sname、Cno和Degree列
SELECT
  SNAME,
  CNO,
  DEGREE
FROM STUDENT st, SCORE sc
WHERE st.SNO = sc.SNO;
--查询“张旭“教师任课的学生成绩。
SELECT *
FROM TEACHER;
SELECT *
FROM COURSE c, TEACHER t
WHERE c.TNO = t.TNO;
SELECT *
FROM SCORE
WHERE CNO IN (SELECT CNO
              FROM COURSE
              WHERE TNO IN (SELECT TNO
                            FROM TEACHER
                            WHERE TNAME = '张旭'));

--查询选修某课程的同学人数多于5人的教师姓名
SELECT *
FROM TEACHER
WHERE TNO IN (SELECT TNO
              FROM COURSE
              WHERE CNO IN (SELECT CNO
                            FROM (SELECT
                                    CNO,
                                    count(1) AS CCNO
                                  FROM SCORE
                                  GROUP BY CNO) t
                            WHERE t.CCNO > 5));
--查询存在有85分以上成绩的课程Cno.
SELECT DISTINCT CNO
FROM SCORE
WHERE DEGREE > 85;
--查询出“计算机系“教师所教课程的成绩表
SELECT *
FROM SCORE
WHERE CNO IN (SELECT CNO
              FROM COURSE
              WHERE TNO IN (SELECT TNO
                            FROM TEACHER
                            WHERE DEPART = '计算机系'));
--查询“计算 机系”与“电子工程系“不同职称的教师的Tname和Prof
SELECT
  TNAME,
  PROF
FROM TEACHER
WHERE PROF NOT IN (

  SELECT PROF
  FROM TEACHER
  WHERE DEPART = '计算机系' INTERSECT
  SELECT PROF
  FROM TEACHER
  WHERE DEPART = '电子工程系');
--查询选修编号为“3-105“课程且成绩至少高于选修编号为“3-245”的同学的Cno、Sno和Degree,并按Degree从高到低次序排序。
SELECT *
FROM SCORE
WHERE CNO = '3-105' AND DEGREE > (SELECT max(DEGREE)
                                  FROM SCORE
                                  WHERE CNO = '3-245')
ORDER BY DEGREE DESC;
--查询选修编号为“3-105”且成绩高于选修编号为“3-245”课程的同学的Cno、Sno和Degree.all:代表括号中的所有成绩
SELECT sum(DEGREE)
FROM SCORE
WHERE CNO = '3-105' AND DEGREE > (SELECT max(DEGREE)
                                  FROM SCORE
                                  WHERE CNO = '3-245')
ORDER BY DEGREE DESC;
--查询所有“女”教师和“女”同学的name、sex和birthday
SELECT
  TNAME,
  TSEX,
  TBIRTHDAY
FROM TEACHER
WHERE TSEX = '女'
UNION SELECT
        SNAME,
        SSEX,
        SBIRTHDAY
      FROM STUDENT
      WHERE SSEX = '女';
--查询成绩比该课程平均成绩低的同学的成绩表
SELECT *
FROM SCORE
WHERE DEGREE < (SELECT avg(DEGREE)
                FROM SCORE);
-- 查询所有未讲课的教师的Tname和Depart.
SELECT
  TNAME,
  DEPART
FROM TEACHER
WHERE TNO IN (SELECT TNO
              FROM COURSE
              WHERE CNO NOT IN (SELECT CNO
                                FROM SCORE));
--查询至少有2名男生的班号
SELECT CLASS
FROM (SELECT
        CLASS,
        count(1) c
      FROM STUDENT
      GROUP BY CLASS) t
WHERE t.c >= 2;
--查询Student表中不姓“王”的同学记录
SELECT *
FROM STUDENT
WHERE SNAME NOT LIKE '王%';

--查询Student表中每个学生的姓名和年龄
SELECT
  SNAME,
  TRUNC(months_between(sysdate, SBIRTHDAY) / 12)
FROM STUDENT;

SELECT
  SNAME,
  trunc((to_char(sysdate, 'yyyymmdd') - to_char(SBIRTHDAY, 'yyyymmdd')) / 10000)
FROM STUDENT;


```

## 行列转换

```sql
CREATE TABLE kecheng
(
  id     NUMBER,
  name   VARCHAR2(20),
  course VARCHAR2(20),
  score  NUMBER
);
INSERT INTO kecheng (id, name, course, score)
VALUES (1, '张三', '语文', 67);
INSERT INTO kecheng (id, name, course, score)
VALUES (1, '张三', '数学', 76);
INSERT INTO kecheng (id, name, course, score)
VALUES (1, '张三', '英语', 43);
INSERT INTO kecheng (id, name, course, score)
VALUES (1, '张三', '历史', 56);
INSERT INTO kecheng (id, name, course, score)
VALUES (1, '张三', '化学', 11);
INSERT INTO kecheng (id, name, course, score)
VALUES (2, '李四', '语文', 54);
INSERT INTO kecheng (id, name, course, score)
VALUES (2, '李四', '数学', 81);
INSERT INTO kecheng (id, name, course, score)
VALUES (2, '李四', '英语', 64);
INSERT INTO kecheng (id, name, course, score)
VALUES (2, '李四', '历史', 93);
INSERT INTO kecheng (id, name, course, score)
VALUES (2, '李四', '化学', 27);
INSERT INTO kecheng (id, name, course, score)
VALUES (3, '王五', '语文', 24);
INSERT INTO kecheng (id, name, course, score)
VALUES (3, '王五', '数学', 25);
INSERT INTO kecheng (id, name, course, score)
VALUES (3, '王五', '英语', 8);
INSERT INTO kecheng (id, name, course, score)
VALUES (3, '王五', '历史', 45);
INSERT INTO kecheng (id, name, course, score)
VALUES (3, '王五', '化学', 1);
COMMIT;
```

## 行列转换答案

```sql
SELECT
  ID,
  NAME,
  SUM(DECODE(course, '语文', score, 0)) 语文,
  --这里使用max,min都可以
  SUM(DECODE(course, '数学', score, 0)) 数学,
  SUM(DECODE(course, '英语', score, 0)) 英语,
  SUM(DECODE(course, '历史', score, 0)) 历史,
  SUM(DECODE(course, '化学', score, 0)) 化学
FROM kecheng
GROUP BY ID, NAME;


SELECT
  ID,
  NAME ,
  SUM(CASE WHEN course  = '语文' THEN score ELSE 0 END ) 语文,
  SUM(CASE WHEN course  = '数学' THEN score ELSE 0 END ) 数学,
  SUM(CASE WHEN course  = '英语' THEN score ELSE 0 END ) 英语,
  SUM(CASE WHEN course  = '历史' THEN score ELSE 0 END ) 历史,
  SUM(CASE WHEN course  = '化学' THEN score ELSE 0 END ) 化学
FROM kecheng
GROUP BY ID,NAME;
```

## `decode`

将查询结果转换为另一个值，可以设定默认值

```sql
SELECT DECODE(course,'语文‘,'yuwen','数学','shuxue','qitar') pingying FROM kecheng
```
