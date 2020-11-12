---
title: mysql中的视图（转）
date: 2017-10-24 09:22:05
tags: 
     - mysql
---
#### 背景
上一个项目接手后，在转移数据庫的时候，数据庫的转移失败，那是我第一次接触mysql视图。但是那时没去研究啥是视图。

今天查看另一个项目时，又发现了mysql视图的存在，需要充电一下了！

#### 文章来源
作者：风一样的码农
原文地址：http://www.cnblogs.com/chenpi/p/5133648.html

#### 什么是视图

通俗的讲，视图就是一条SELECT语句执行后返回的结果集。所以我们在创建视图的时候，主要的工作就落在创建这条SQL查询语句上。

#### 视图的特性
视图是对若干张基本表的引用，一张虚表，查询语句执行的结果，不存储具体的数据（基本表数据发生了改变，视图也会跟着改变）；

可以跟基本表一样，进行增删改查操作(ps:增删改操作有条件限制)；

#### 视图的作用
方便操作，特别是查询操作，减少复杂的SQL语句，增强可读性；

更加安全，数据库授权命令不能限定到特定行和特定列，但是通过合理创建视图，可以把权限限定到行列级别；

#### 使用场合
权限控制的时候，不希望用户访问表中某些含敏感信息的列，比如salary...

关键信息来源于多个复杂关联表，可以创建视图提取我们需要的信息，简化操作；

#### 视图实例1-创建视图及查询数据操作
现有三张表：用户(user)、课程(course)、用户课程中间表(user_course)，表结构及数据如下：

表定义：
```sql
-- ----------------------------
-- Table structure for `course`
-- ----------------------------
DROP TABLE IF EXISTS `course`;
CREATE TABLE `course` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `description` varchar(500) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of course
-- ----------------------------
INSERT INTO `course` VALUES ('1', 'JAVA', 'JAVA课程');
INSERT INTO `course` VALUES ('2', 'C++', 'C++课程');
INSERT INTO `course` VALUES ('3', 'C语言', 'C语言课程');

-- ----------------------------
-- Table structure for `user`
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `account` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `others` varchar(200) DEFAULT NULL,
  `others2` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES ('1', 'user1', '小陈', '美国', '1', '1');
INSERT INTO `user` VALUES ('2', 'user2', '小张', '日本', '2', '2');
INSERT INTO `user` VALUES ('3', 'user3', '小王', '中国', '3', '3');

-- ----------------------------
-- Table structure for `user_course`
-- ----------------------------
DROP TABLE IF EXISTS `user_course`;
CREATE TABLE `user_course` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `userid` bigint(20) NOT NULL,
  `courseid` bigint(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of user_course
-- ----------------------------
INSERT INTO `user_course` VALUES ('1', '1', '2');
INSERT INTO `user_course` VALUES ('2', '1', '3');
INSERT INTO `user_course` VALUES ('3', '2', '1');
INSERT INTO `user_course` VALUES ('4', '2', '2');
INSERT INTO `user_course` VALUES ('5', '2', '3');
INSERT INTO `user_course` VALUES ('6', '3', '2');
```


这时，当我们想要查询小张上的所以课程相关信息的时候，需要这样写一条长长的SQL语句，如下：
```sql
SELECT
    `uc`.`id` AS `id`,
    `u`.`name` AS `username`,
    `c`.`name` AS `coursename`
FROM
    `user` `u`
LEFT JOIN `user_course` `uc` ON ((`u`.`id` = `uc`.`userid`))
LEFT JOIN `course` `c` ON ((`uc`.`courseid` = `c`.`id`))
WHERE
    u.`name` = '小张'
```

但是我们可以通过视图简化操作，例如我们创建视图view_user_course如下：
```sql
-- ----------------------------
-- View structure for `view_user_course`
-- ----------------------------
DROP VIEW
IF EXISTS `view_user_course`;

CREATE ALGORITHM = UNDEFINED 
DEFINER = `root`@`localhost` 
SQL SECURITY DEFINER 
VIEW `view_user_course` AS (
    SELECT
        `uc`.`id` AS `id`,
        `u`.`name` AS `username`,
        `c`.`name` AS `coursename`
    FROM
        (
            (
                `user` `u`
                LEFT JOIN `user_course` `uc` ON ((`u`.`id` = `uc`.`userid`))
            )
            LEFT JOIN `course` `c` ON ((`uc`.`courseid` = `c`.`id`))
        )
);
```
几点说明（MySQL中的视图在标准SQL的基础之上做了扩展）：

ALGORITHM=UNDEFINED：指定视图的处理算法；

DEFINER=`root`@`localhost`：指定视图创建者；

SQL SECURITY DEFINER：指定视图查询数据时的安全验证方式；

创建好视图之后，我们可以直接用以下SQL语句在视图上查询小张上的所以课程相关信息，同样可以得到所需结果：
```sql
SELECT
    vuc.username,
    vuc.coursename
FROM
    view_user_course vuc
WHERE
     vuc.username = '小张'
```

#### 视图实例2-增删改数据操作
继续，我们可以尝试在视图view_user_course上做增删改数据操作，如下：

```sql
update view_user_course set username='test',coursename='JAVASCRIPT' where id=3
```
遗憾的是操作失败，提示错误信息如下：

[SQL] update view_user_course set username='test',coursename='JAVASCRIPT' where id=3

[Err] 1393 - Can not modify more than one base table through a join view 'demo.view_user_course'

因为不能在一张由多张关联表连接而成的视图上做同时修改两张表的操作；

那么哪些操作可以在视图上进行呢？

视图与表是一对一关系情况：如果没有其它约束（如视图中没有的字段，在基本表中是必填字段情况），是可以进行增删改数据操作；

如我们创建用户关键信息视图view_user_keyinfo，如下：

```sql
-- ----------------------------
-- View structure for `view_user_keyinfo`
-- ----------------------------
DROP VIEW
IF EXISTS `view_user_keyinfo`;

CREATE ALGORITHM = UNDEFINED DEFINER = `root`@`localhost` SQL SECURITY DEFINER VIEW `view_user_keyinfo` AS SELECT
    `u`.`id` AS `id`,
    `u`.`account` AS `account`,
    `u`.`name` AS `username`
FROM
    `user` `u`;
```

进行增删改操作如下，操作成功（注意user表中的其它字段要允许为空，否则操作失败）：

```sql
INSERT INTO view_user_keyinfo (account, username)
VALUES
    ('test1', 'test1');
```
```sql
DELETE
FROM
    view_user_keyinfo
WHERE
    username = 'test1';
```
```sql
UPDATE view_user_keyinfo
SET username = 'updateuser'
WHERE
    id = 1
```

视图与表是一对多关系情况：如果只修改一张表的数据，且没有其它约束（如视图中没有的字段，在基本表中是必填字段情况），是可以进行改数据操作，如以下语句，操作成功；

```sql
update view_user_course set coursename='JAVA' where id=1;
update view_user_course set username='test2' where id=3;
```

以下操作失败：
```sql
delete from view_user_course where id=3;
insert into view_user_course(username, coursename) VALUES('2','3');
```

#### 其它
视图中的查询语句性能要调到最优；
修改操作时要小心，不经意间你已经修改了基本表里的多条数据；