---
title: MySql按周，按月，按日分组统计数据
date: 2018-03-19 14:25:08
tags:
     - mysql
     - 统计
---

### 背景
之前开发微信时，做过类似的简单统计。那时对于mysql的理解比较浅，有些数据都是预先存入数据去实现的。这时就会出现多个时间，比如create_time  create_date。
现在开发开单宝的统计，特意搜索了一下关于统计时mysql处理的文章

### 参考
MySql按周，按月，按日分组统计数据
https://blog.csdn.net/lqclh502/article/details/50157483
MySQL中distinct和count(*)的使用方法比较
http://www.jb51.net/article/74559.htm

### 几个关键词

#### 网上的资料
关键词：`DATE_FORMAT`
对时间进行格式化
例子：
```
select DATE_FORMAT(create_time,'%Y%u') weeks,count(caseid) count from tc_case group by weeks;

select DATE_FORMAT(create_time,'%Y%m%d') days,count(caseid) count from tc_case group by days;

select DATE_FORMAT(create_time,'%Y%m') months,count(caseid) count from tc_case group by months;
```

DATE_FORMAT(date,format)

根据format字符串格式化date值。下列修饰符可以被用在format字符串中：

%M 月名字(January……December)
%W 星期名字(Sunday……Saturday)
%D 有英语前缀的月份的日期(1st, 2nd, 3rd, 等等。）
%Y 年, 数字, 4 位
%y 年, 数字, 2 位
%a 缩写的星期名字(Sun……Sat)
%d 月份中的天数, 数字(00……31)
%e 月份中的天数, 数字(0……31)
%m 月, 数字(01……12)
%c 月, 数字(1……12)
%b 缩写的月份名字(Jan……Dec)
%j 一年中的天数(001……366)
%H 小时(00……23)
%k 小时(0……23)
%h 小时(01……12)
%I 小时(01……12)
%l 小时(1……12)
%i 分钟, 数字(00……59)
%r 时间,12 小时(hh:mm:ss [AP]M)
%T 时间,24 小时(hh:mm:ss)
%S 秒(00……59)
%s 秒(00……59)
%p AM或PM
%w 一个星期中的天数(0=Sunday ……6=Saturday ）
%U 星期(0……52), 这里星期天是星期的第一天
%u 星期(0……52), 这里星期一是星期的第一天
%% 一个文字“%”

#### 动手实战
网上写的是DATE类型的字段的处理，可是我习惯用int类型的时间戳保存时间
需要改进一下
```
   DATE_FORMAT( FROM_UNIXTIME(create_time),'%Y-%m-%d' ) AS  days
   DATE_FORMAT( FROM_UNIXTIME(create_time),'%Y-%m' ) AS  months
   DATE_FORMAT( FROM_UNIXTIME(create_time),'%u' ) AS  weeks
```

接下来只要对 days months weeks进group就OK
thinkphp下的代码
```
    $list = M("Order")
            ->field(" DATE_FORMAT( FROM_UNIXTIME(create_time),'%Y-%m-%d' ) AS  days, SUM(total_money) total_money_count , COUNT( DISTINCT customer_id ) AS customer_id_count , COUNT( id ) AS order_count")
            ->where($newmap)
            ->group(' days ')
            ->select();
```

关键词：`DISTINCT`
在count不重复的记录的时候就能用到它，
上面的代码里就用到了`COUNT( DISTINCT customer_id ) AS customer_id_count`,有了这个关键词，就不用以前的笨方法了





