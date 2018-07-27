---
title: '记一次使用leftjoin,group及子查询的配合使用'
date: 2018-07-27 15:47:12
tags:
    - mysql 
---

### 背景
库存数据统计

库存的数量动态的，列出产品的同时，将批次表里的同product_id的cur_num相加，作为该产品的库存

### 以前的做法
先将产品列表取出（一条sql）
foreach 每个产品，并查询总数（当前页数*1条sql）

### 改进后的做法
先用子查询获取查询的总数,然后一下group，group后的字段作为leftjoin的关联字段

```
 $storeProductBatchQuery = M('store_product_batch as spb')->field('SUM(cur_num) as spb_cur_num_count,product_id')->group('product_id')->buildSql(); // group的使用
$list = M("product as p")
        ->join('left join '.$storeProductBatchQuery.' as spb on spb.product_id = p.id')
        ->field('p.*,spb.spb_cur_num_count')
        ->where($newmap)
        ->order($order)
        ->limit($offset.','.$page_size)
        ->select(false);

        dump($list);
        exit();
```


