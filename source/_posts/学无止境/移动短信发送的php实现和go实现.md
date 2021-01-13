---
title: 移动短信发送的php和go实现demo
category: [学无止境]
tags: [go]
date: 2021-01-08 09:59:53
---

### 说明
对接移动短信发送的sdk，官方是java版本的。
现在用自己熟悉的php和新学的go来实现一遍，看看go的实现有和不同

### 官方java版本的demo
![demoforjava](http://image.jk-kj.com/mweb/2021/01/08/16100730123915demoforjava.png)

### php实现
```php
public function sendsms(){

        $url = 'http://112.35.1.155:1992/sms/norsubmit';
        $client = new HttpClient($url);

        $ecName = "管理中心";
        $apId = "xxx";
        $secretKey = "L00001";
        $mobiles = "136****00";
        $content = "移动改变生活";
        $sign = "xcxxcxcxc";
        $addSerial = "";
        $mac_origin = $ecName.$apId.$secretKey.$mobiles.$content.$sign.$addSerial;

        $mac = strtolower(md5($mac_origin));

        $object = new \stdClass();
        $object->ecName = $ecName;
        $object->apId = $apId;
        $object->secretKey = $secretKey;
        $object->mobiles = $mobiles;
        $object->content = $content;
        $object->sign = $sign;
        $object->addSerial = $addSerial;
        $object->mac = $mac;

        $json = json_encode($object,JSON_FORCE_OBJECT);

        $message = base64_encode($json);

        $client->setContentType("application/json; charset=UTF-8");
        $response = $client->post($message);

        var_dump($response);
    }

```

### go的实现

```go
package main

import (
    "fmt"
    "strings"
    "net/http"
    "io/ioutil"
    "crypto/md5"
    "encoding/hex"
    "encoding/json"
    "encoding/base64"
    // "reflect"
)

type Object struct{
    EcName string `json:"ecName"`
    ApId string `json:"apId"`
    SecretKey string `json:"secretKey"`
    Mobiles string `json:"mobiles"`
    Content string `json:"content"`
    Sign string `json:"sign"`
    AddSerial string `json:"addserial"`
    Mac string `json:"mac"`
}

func mkmd5(s string) string  {
    md5Ctx := md5.New()
    md5Ctx.Write([]byte(s))
    cipherStr := md5Ctx.Sum(nil)
    return hex.EncodeToString(cipherStr)
}

func main() {
    client := &http.Client{}
    posturl := "http://112.35.1.155:1992/sms/norsubmit"

    ecName := "管理中心";
    apId := "xxx";
    secretKey := "L00001";
    mobiles := "136****00";
    content := "移动改变生活";
    sign := "xcxxcxcxc";
    addSerial := "";
    mac_origin := ecName + apId + secretKey + mobiles + content + sign + addSerial;

    mac := mkmd5(mac_origin)

    object := Object{
        EcName: ecName,
        ApId:apId,
        SecretKey:secretKey,
        Mobiles:mobiles,
        Content:content,
        Sign:sign,
        AddSerial:addSerial,
        Mac:mac,
    }

	sdata, err := json.Marshal(object)
    fmt.Println(sdata)
    // fmt.Println("sdata 的数据类型是:",reflect.TypeOf(sdata))
    
	if err != nil {
		fmt.Println("json.marshal failed, err:", err)
		return
	}

    // json_string := string(sdata)
    // fmt.Println(json_string)

    message := base64.StdEncoding.EncodeToString(sdata)

    req, err := http.NewRequest("POST", posturl, strings.NewReader(message))
    if err != nil {
        // handle error
    }

    req.Header.Set("Content-Type", "application/json")

    resp, err := client.Do(req)
    defer resp.Body.Close()
 
    body, err := ioutil.ReadAll(resp.Body)
    if err != nil {
        // handle error
    }
    fmt.Println(string(body))
}

```


### 主要的不同

- md5的方法需要自己去封装下使用
- json.Marshal返回的是 []uint8，需要自己再转格式
- go语音在使用类似php中的函数时，必须自己清楚需要用到哪些包


### 存在的坑
- golang中struct变量JSON转码变量名必须大写

### 参考

[Golang计算MD5](https://blog.csdn.net/weixin_34015336/article/details/92576229?utm_medium=distribute.pc_relevant_t0.none-task-blog-BlogCommendFromBaidu-1.control&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-BlogCommendFromBaidu-1.control)

[golang中struct变量JSON转码变量名必须大写](https://blog.csdn.net/l_ricardo/article/details/80467674)

[golang实现base64编解码](https://www.cnblogs.com/unqiang/p/6677208.html)