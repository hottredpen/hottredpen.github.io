# 

1、下载本程序并解压到某个目录


2、在screw plus目录中执行php bin中的phpize自动生成扩展所需文件（我用的是宝塔）
```
/www/server/php/56/bin/phpize
```
3、执行./configure --with-php-config=[php config path] 进行配置，[php config path]是你的php-config的绝对路径
```
./configure --with-php-config=/www/server/php/56/bin/php-config
```

4、修改php_screw_plus.h中的CAKEY，改为一个你认为安全的字符串
```
#define CAKEY  "aabbcc_zhe_li"
//如果只允许执行加过密的php文件 设置STRICT_MODE为1
//set STRICT_MODE to 1 if you only want the crypted php files to be executed
#define STRICT_MODE 0
#define STRICT_MODE_ERROR_MESSAGE "ACCESS DENIED"
const int maxBytes = 1024*1024*2;
```
5、执行make生成扩展 modules/php_screw_plus.so
6、把扩展路径加入php.ini中 重启php,可以在phpinfo中看到
```
php_screw_plus version	0.11
```
7、进入tools文件夹 执行make
8、执行./screw [目录或文件] ，后面带上你要加密的目录或文件即可自动开始加密
```
./screw ../test_pro/
```
发现test_pro内的文件已经被加密
9、解密
执行./screw [path] 是加密 后面加-d参数则是解密 例如
```
./screw ../test_j_pro/ -d
```