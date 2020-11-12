---
title: 记一次服务器mysql占用过大的排查
date: 2019-06-05 16:58:15
tags: mysql 
---


### 背景

公司测试服务器上，跑了N多的应用，某天mysql的CPU占用超高，http的请求部分也有超20%以上的。

### 参考
mysql/mariadb知识点总结（24）：慢查询日志
http://www.zsythink.net/archives/1260
关于MySQL 通用查询日志和慢查询日志分析
https://www.jianshu.com/p/ac4f291b806a
mysql中slow query log慢日志查询分析
https://www.cnblogs.com/musings/p/5913186.html


### 过程

#### 记录全部的log

开启全部的sql记录，先看看全局的
```
show variables like '%general%';

+------------------+--------------+
| Variable_name    | Value        |
+------------------+--------------+
| general_log      | OFF          |
| general_log_file | ecs-248d.log |
+------------------+--------------+
2 rows in set (0.00 sec)
```
发现没有开，
```
set global general_log=on;
```
我们打算用文件的形式记录下来
```
show variables like '%log_output%';
set global log_output='FILE';
```
这个时候就可以去查看
```
/var/lib/mysql/ecs-248d.log
```
（注意：上述命令只对当前生效，当MySQL重启失效，如果要永久生效，需要配置 my.cnf）

### 记录慢查询log

先查看下
```
show variables like ‘%quer%’;
```
```
+-------------------------------+-------------------+
| Variable_name                 | Value             |
+-------------------------------+-------------------+
| expensive_subquery_limit      | 100               |
| ft_query_expansion_limit      | 20                |
| have_query_cache              | YES               |
| log_queries_not_using_indexes | OFF               |
| log_slow_queries              | ON                |
| long_query_time               | 10.000000          |
| query_alloc_block_size        | 8192              |
| query_cache_limit             | 262144            |
| query_cache_min_res_unit      | 2048              |
| query_cache_size              | 1073741824        |
| query_cache_strip_comments    | OFF               |
| query_cache_type              | ON                |
| query_cache_wlock_invalidate  | OFF               |
| query_prealloc_size           | 8192              |
| slow_query_log                | OFF                |
| slow_query_log_file           | ecs-248d-slow.log |
+-------------------------------+-------------------+
16 rows in set (0.00 sec)
```

开启慢查询的条件，设置`long_query_time`为1秒
```
set long_query_time=1;
```

试一试有没有生效
```
select sleep(2);
```
到`/var/lib/mysql/ecs-248d-slow.log`查看下有没有

```
 # Time: 190605 17:32:20
 # User@Host: root[root] @ localhost []
 # Thread_id: 2223  Schema:   QC_hit: No
 # Query_time: 2.000163  Lock_time: 0.000000  Rows_sent: 1  Rows_examined: 0
 SET timestamp=1559727140;
 select sleep(2);
```

如果太多了，用
```
mysqldumpslow -s t /var/lib/mysql/ecs-248d-slow.log
```
帮我们统一下

