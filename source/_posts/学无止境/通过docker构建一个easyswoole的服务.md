---
title: 通过docker构建一个easyswoole的服务
category: [学无止境]
tags: [ docker ]
date: 2021-07-06 10:15:53
---

### 安装docker

```
yum update
```
安装需要的软件包， yum-util 提供yum-config-manager功能，另外两个是devicemapper驱动依赖的
```
yum install -y yum-utils device-mapper-persistent-data lvm2
```
设置yum源
```
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```
可以查看所有仓库中所有docker版本，并选择特定版本安装
```
yum list docker-ce --showduplicates | sort -r
```
安装指定版本或者最新版本
```
yum install docker-ce-17.12.1.ce
```
或者
```
yum install docker-ce
```
启动Docker，命令：systemctl start docker，然后加入开机启动，如下

```
systemctl start docker
systemctl enable docker
```



```
[root@ecs02-4c8g ~]# docker version
Client: Docker Engine - Community
 Version:           20.10.8
 API version:       1.41
 Go version:        go1.16.6
 Git commit:        3967b7d
 Built:             Fri Jul 30 19:55:49 2021
 OS/Arch:           linux/amd64
 Context:           default
 Experimental:      true

Server: Docker Engine - Community
 Engine:
  Version:          20.10.8
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.16.6
  Git commit:       75249d8
  Built:            Fri Jul 30 19:54:13 2021
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.4.9
  GitCommit:        e25210fe30a0a703442421b0f60afac609f950a3
 runc:
  Version:          1.0.1
  GitCommit:        v1.0.1-0-g4144b63
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```


### 开始

    



新建easyswooletest目录，并在里面新建Dockerfile

Dockerfile
```
FROM centos:7

#version defined
ENV SWOOLE_VERSION 4.4.26
ENV EASYSWOOLE_VERSION 3.4.x

#install libs
RUN yum install -y curl zip unzip  wget openssl-devel gcc-c++ make autoconf git epel-release
RUN yum install -y dnf
RUN dnf -y install https://rpms.remirepo.net/enterprise/remi-release-7.rpm
#install php
RUN yum --enablerepo=remi install -y php74-php php74-php-devel php74-php-mbstring php74-php-json php74-php-simplexml php74-php-gd

RUN ln -s /opt/remi/php74/root/usr/bin/php /usr/bin/php \
    && ln -s /opt/remi/php74/root/usr/bin/phpize /usr/bin/phpize \
    && ln -s /opt/remi/php74/root/usr/bin/php-config /usr/bin/php-config

# composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/bin/composer && chmod +x /usr/bin/composer
# use aliyun composer 由于最近阿里云镜像不稳定，废弃使用
# RUN composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

# swoole ext
RUN wget https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz -O swoole.tar.gz \
    && mkdir -p swoole \
    && tar -xf swoole.tar.gz -C swoole --strip-components=1 \
    && rm swoole.tar.gz \
    && ( \
    cd swoole \
    && phpize \
    && ./configure --enable-openssl \
    && make \
    && make install \
    ) \
    && sed -i "2i extension=swoole.so" /etc/opt/remi/php74/php.ini \
    && rm -r swoole

# Dir
WORKDIR /easyswoole
# install easyswoole
RUN cd /easyswoole \
    && composer require easyswoole/easyswoole=${EASYSWOOLE_VERSION} \
    && php vendor/easyswoole/easyswoole/bin/easyswoole install

EXPOSE 9501
```

以上面Dockerfile创建一个myeasyswooletest镜像
```
docker build -t myeasyswooletest .
```


安装完毕后,新建一个容器

```
docker run --name=mytest -ti -p 9501:9501 myeasyswooletest
```
-ti 启动容器后直接进入容器终端
-p 容器端口映射到外部端口


此时发现容器根目录中存在easyswoole项目目录，为了方便开发，需要做目录映射，由于直接映射会覆盖掉容器中对应目录的内容，需要在宿主机安装easyswoole再进行映射，因此这里先将容器中项目目录拷贝出来，再重新创建容器并映射目录

拷贝文件目录到宿主机中
```
docker cp {dockerId}:/easyswoole /www/wwwroot/myeasyswoolestest

```

关闭并删除容器
```
docker stop {dockerId}

docker rm {dockerId}
```

启动容器并映射目录
```
docker run -ti -p 9501:9501 --restart=always  -v /www/wwwroot/myeasyswooletest:/easyswoole myeasyswooletest7
```
-t:在新容器内指定一个伪终端或终端。

-i:允许你对容器内的标准输入 (STDIN) 进行交互。

-d:让容器在后台运行。

-P:将容器内部使用的网络端口映射到我们使用的主机上。

-p : 是容器内部端口绑定到指定的主机端口

-v：参数用于数据卷映射，/home/vpaas 是宿主机卷标，/usr/local/vpaas_file 是容器卷标

--name:  容器名称

vpaas:latest： 创建的镜像名

 

### 数据卷的作用：

docker 镜像启动的容器和宿主机可以看成两个不同的Linux系统，这两个文件系统之间传输文件就是用数据卷进行传输的。

宿主机将文件放入到 /home/vpaas 中，通过容器卷标  /usr/local/vpaas_file  就可以看到放入的文件，类似于文件夹共享。


### 进入容器
```
docker exec -it {dockerId} /bin/bash
```

在容器内安装---为了word转pdf
```
yum install -y libreoffice 
yum install -y unoconv
yum install -y ImageMagick
```

### 通过容器生成镜像
```
docker commit -m "安装word转pdf的依赖" {dockerId} newserver
```
-m:提交的描述信息

-a: 指定镜像作者

e218edb10161：容器ID 

newserver:  指定要创建的目标镜像名


### 重新新建容器

```
docker run -ti -p 9501:9501 --restart=always  -v /www/wwwroot/myeasyswooletest:/easyswoole newserver
```

### 拷贝一个docx文件到容器内试试
```
docker cp /www/kkjj.docx {dockerId}:/www/
```

### 转换一下
```
soffice --headless --invisible --convert-to pdf kkjj.docx --outdir ./
```
发现有乱码（不支持中文）

### 将本地的中文字体放到一起，一起拷贝过去
```
docker cp /usr/share/fonts/chinese ae4c6f7a8b6d:/usr/share/fonts
```
中文可以显示了

### 将pdf转图片

```
convert  kkjj.pdf -resize 500% -quality 100 -sharpen 0x1.0 kkjj.png
```

### 将镜像发布出去
```
docker login
```

```
docker images
```

### 重命名镜像tag

```
docker tag 94998885c9d4 hottredpen/newserver
```
### 推送到自己的仓库
```
docker push hottredpen/newserver
```

### 推送太慢，就打包到本地
```
docker save -o pdf.tar pdfserver1.4
```

### 另一台机器上安装本地包
```
docker load < pdf.tar
```



##其他
### pfdi添加中文字体
```
https://github.com/DCgithub21/cd_FPDF/blob/master/chinese.php
```

新增一个PDFChinese.php 
```
<?php
namespace setasign\Fpdi;

$Big5_widths = array(' '=>250,'!'=>250,'"'=>408,'#'=>668,'$'=>490,'%'=>875,'&'=>698,'\''=>250,
	'('=>240,')'=>240,'*'=>417,'+'=>667,','=>250,'-'=>313,'.'=>250,'/'=>520,'0'=>500,'1'=>500,
	'2'=>500,'3'=>500,'4'=>500,'5'=>500,'6'=>500,'7'=>500,'8'=>500,'9'=>500,':'=>250,';'=>250,
	'<'=>667,'='=>667,'>'=>667,'?'=>396,'@'=>921,'A'=>677,'B'=>615,'C'=>719,'D'=>760,'E'=>625,
	'F'=>552,'G'=>771,'H'=>802,'I'=>354,'J'=>354,'K'=>781,'L'=>604,'M'=>927,'N'=>750,'O'=>823,
	'P'=>563,'Q'=>823,'R'=>729,'S'=>542,'T'=>698,'U'=>771,'V'=>729,'W'=>948,'X'=>771,'Y'=>677,
	'Z'=>635,'['=>344,'\\'=>520,']'=>344,'^'=>469,'_'=>500,'`'=>250,'a'=>469,'b'=>521,'c'=>427,
	'd'=>521,'e'=>438,'f'=>271,'g'=>469,'h'=>531,'i'=>250,'j'=>250,'k'=>458,'l'=>240,'m'=>802,
	'n'=>531,'o'=>500,'p'=>521,'q'=>521,'r'=>365,'s'=>333,'t'=>292,'u'=>521,'v'=>458,'w'=>677,
	'x'=>479,'y'=>458,'z'=>427,'{'=>480,'|'=>496,'}'=>480,'~'=>667);

$GB_widths = array(' '=>207,'!'=>270,'"'=>342,'#'=>467,'$'=>462,'%'=>797,'&'=>710,'\''=>239,
	'('=>374,')'=>374,'*'=>423,'+'=>605,','=>238,'-'=>375,'.'=>238,'/'=>334,'0'=>462,'1'=>462,
	'2'=>462,'3'=>462,'4'=>462,'5'=>462,'6'=>462,'7'=>462,'8'=>462,'9'=>462,':'=>238,';'=>238,
	'<'=>605,'='=>605,'>'=>605,'?'=>344,'@'=>748,'A'=>684,'B'=>560,'C'=>695,'D'=>739,'E'=>563,
	'F'=>511,'G'=>729,'H'=>793,'I'=>318,'J'=>312,'K'=>666,'L'=>526,'M'=>896,'N'=>758,'O'=>772,
	'P'=>544,'Q'=>772,'R'=>628,'S'=>465,'T'=>607,'U'=>753,'V'=>711,'W'=>972,'X'=>647,'Y'=>620,
	'Z'=>607,'['=>374,'\\'=>333,']'=>374,'^'=>606,'_'=>500,'`'=>239,'a'=>417,'b'=>503,'c'=>427,
	'd'=>529,'e'=>415,'f'=>264,'g'=>444,'h'=>518,'i'=>241,'j'=>230,'k'=>495,'l'=>228,'m'=>793,
	'n'=>527,'o'=>524,'p'=>524,'q'=>504,'r'=>338,'s'=>336,'t'=>277,'u'=>517,'v'=>450,'w'=>652,
	'x'=>466,'y'=>452,'z'=>407,'{'=>370,'|'=>258,'}'=>370,'~'=>605);

class PDFChinese extends \FPDF
{
function AddCIDFont($family, $style, $name, $cw, $CMap, $registry)
{
	$fontkey = strtolower($family).strtoupper($style);
	if(isset($this->fonts[$fontkey]))
		$this->Error("Font already added: $family $style");
	$i = count($this->fonts)+1;
	$name = str_replace(' ','',$name);
	$this->fonts[$fontkey] = array('i'=>$i, 'type'=>'Type0', 'name'=>$name, 'up'=>-130, 'ut'=>40, 'cw'=>$cw, 'CMap'=>$CMap, 'registry'=>$registry);
}

function AddCIDFonts($family, $name, $cw, $CMap, $registry)
{
	$this->AddCIDFont($family,'',$name,$cw,$CMap,$registry);
	$this->AddCIDFont($family,'B',$name.',Bold',$cw,$CMap,$registry);
	$this->AddCIDFont($family,'I',$name.',Italic',$cw,$CMap,$registry);
	$this->AddCIDFont($family,'BI',$name.',BoldItalic',$cw,$CMap,$registry);
}

function AddBig5Font($family='Big5', $name='MSungStd-Light-Acro')
{
	// Add Big5 font with proportional Latin
	$cw = $GLOBALS['Big5_widths'];
	$CMap = 'ETenms-B5-H';
	$registry = array('ordering'=>'CNS1', 'supplement'=>0);
	$this->AddCIDFonts($family,$name,$cw,$CMap,$registry);
}

function AddBig5hwFont($family='Big5-hw', $name='MSungStd-Light-Acro')
{
	// Add Big5 font with half-witdh Latin
	for($i=32;$i<=126;$i++)
		$cw[chr($i)] = 500;
	$CMap = 'ETen-B5-H';
	$registry = array('ordering'=>'CNS1', 'supplement'=>0);
	$this->AddCIDFonts($family,$name,$cw,$CMap,$registry);
}

function AddGBFont($family='GB', $name='STSongStd-Light-Acro')
{
	// Add GB font with proportional Latin
	$cw = $GLOBALS['GB_widths'];
	$CMap = 'GBKp-EUC-H';
	$registry = array('ordering'=>'GB1', 'supplement'=>2);
	$this->AddCIDFonts($family,$name,$cw,$CMap,$registry);
}

function AddGBhwFont($family='GB-hw', $name='STSongStd-Light-Acro')
{
	// Add GB font with half-width Latin
	for($i=32;$i<=126;$i++)
		$cw[chr($i)] = 500;
	$CMap = 'GBK-EUC-H';
	$registry = array('ordering'=>'GB1', 'supplement'=>2);
	$this->AddCIDFonts($family,$name,$cw,$CMap,$registry);
}

function GetStringWidth($s)
{
	if($this->CurrentFont['type']=='Type0')
		return $this->GetMBStringWidth($s);
	else
		return parent::GetStringWidth($s);
}

function GetMBStringWidth($s)
{
	// Multi-byte version of GetStringWidth()
	$l = 0;
	$cw = &$this->CurrentFont['cw'];
	$nb = strlen($s);
	$i = 0;
	while($i<$nb)
	{
		$c = $s[$i];
		if(ord($c)<128)
		{
			$l += $cw[$c];
			$i++;
		}
		else
		{
			$l += 1000;
			$i += 2;
		}
	}
	return $l*$this->FontSize/1000;
}

function MultiCell($w, $h, $txt, $border=0, $align='L', $fill=0)
{
	if($this->CurrentFont['type']=='Type0')
		$this->MBMultiCell($w,$h,$txt,$border,$align,$fill);
	else
		parent::MultiCell($w,$h,$txt,$border,$align,$fill);
}

function MBMultiCell($w, $h, $txt, $border=0, $align='L', $fill=0)
{
	// Multi-byte version of MultiCell()
	$cw = &$this->CurrentFont['cw'];
	if($w==0)
		$w = $this->w-$this->rMargin-$this->x;
	$wmax = ($w-2*$this->cMargin)*1000/$this->FontSize;
	$s = str_replace("\r",'',$txt);
	$nb = strlen($s);
	if($nb>0 && $s[$nb-1]=="\n")
		$nb--;
	$b = 0;
	if($border)
	{
		if($border==1)
		{
			$border = 'LTRB';
			$b = 'LRT';
			$b2 = 'LR';
		}
		else
		{
			$b2 = '';
			if(is_int(strpos($border,'L')))
				$b2 .= 'L';
			if(is_int(strpos($border,'R')))
				$b2 .= 'R';
			$b = is_int(strpos($border,'T')) ? $b2.'T' : $b2;
		}
	}
	$sep = -1;
	$i = 0;
	$j = 0;
	$l = 0;
	$nl = 1;
	while($i<$nb)
	{
		// Get next character
		$c = $s[$i];
		// Check if ASCII or MB
		$ascii = (ord($c)<128);
		if($c=="\n")
		{
			// Explicit line break
			$this->Cell($w,$h,substr($s,$j,$i-$j),$b,2,$align,$fill);
			$i++;
			$sep = -1;
			$j = $i;
			$l = 0;
			$nl++;
			if($border && $nl==2)
				$b = $b2;
			continue;
		}
		if(!$ascii)
		{
			$sep = $i;
			$ls = $l;
		}
		elseif($c==' ')
		{
			$sep = $i;
			$ls = $l;
		}
		$l += $ascii ? $cw[$c] : 1000;
		if($l>$wmax)
		{
			// Automatic line break
			if($sep==-1 || $i==$j)
			{
				if($i==$j)
					$i += $ascii ? 1 : 2;
				$this->Cell($w,$h,substr($s,$j,$i-$j),$b,2,$align,$fill);
			}
			else
			{
				$this->Cell($w,$h,substr($s,$j,$sep-$j),$b,2,$align,$fill);
				$i = ($s[$sep]==' ') ? $sep+1 : $sep;
			}
			$sep = -1;
			$j = $i;
			$l = 0;
			$nl++;
			if($border && $nl==2)
				$b = $b2;
		}
		else
			$i += $ascii ? 1 : 2;
	}
	// Last chunk
	if($border && is_int(strpos($border,'B')))
		$b .= 'B';
	$this->Cell($w,$h,substr($s,$j,$i-$j),$b,2,$align,$fill);
	$this->x = $this->lMargin;
}

function Write($h, $txt, $link='')
{
	if($this->CurrentFont['type']=='Type0')
		$this->MBWrite($h,$txt,$link);
	else
		parent::Write($h,$txt,$link);
}

function MBWrite($h, $txt, $link)
{
	// Multi-byte version of Write()
	$cw = &$this->CurrentFont['cw'];
	$w = $this->w-$this->rMargin-$this->x;
	$wmax = ($w-2*$this->cMargin)*1000/$this->FontSize;
	$s = str_replace("\r",'',$txt);
	$nb = strlen($s);
	$sep = -1;
	$i = 0;
	$j = 0;
	$l = 0;
	$nl = 1;
	while($i<$nb)
	{
		// Get next character
		$c = $s[$i];
		// Check if ASCII or MB
		$ascii = (ord($c)<128);
		if($c=="\n")
		{
			// Explicit line break
			$this->Cell($w,$h,substr($s,$j,$i-$j),0,2,'',0,$link);
			$i++;
			$sep = -1;
			$j = $i;
			$l = 0;
			if($nl==1)
			{
				$this->x = $this->lMargin;
				$w = $this->w-$this->rMargin-$this->x;
				$wmax = ($w-2*$this->cMargin)*1000/$this->FontSize;
			}
			$nl++;
			continue;
		}
		if(!$ascii || $c==' ')
			$sep = $i;
		$l += $ascii ? $cw[$c] : 1000;
		if($l>$wmax)
		{
			// Automatic line break
			if($sep==-1 || $i==$j)
			{
				if($this->x>$this->lMargin)
				{
					// Move to next line
					$this->x = $this->lMargin;
					$this->y += $h;
					$w = $this->w-$this->rMargin-$this->x;
					$wmax = ($w-2*$this->cMargin)*1000/$this->FontSize;
					$i++;
					$nl++;
					continue;
				}
				if($i==$j)
					$i += $ascii ? 1 : 2;
				$this->Cell($w,$h,substr($s,$j,$i-$j),0,2,'',0,$link);
			}
			else
			{
				$this->Cell($w,$h,substr($s,$j,$sep-$j),0,2,'',0,$link);
				$i = ($s[$sep]==' ') ? $sep+1 : $sep;
			}
			$sep = -1;
			$j = $i;
			$l = 0;
			if($nl==1)
			{
				$this->x = $this->lMargin;
				$w = $this->w-$this->rMargin-$this->x;
				$wmax = ($w-2*$this->cMargin)*1000/$this->FontSize;
			}
			$nl++;
		}
		else
			$i += $ascii ? 1 : 2;
	}
	// Last chunk
	if($i!=$j)
		$this->Cell($l/1000*$this->FontSize,$h,substr($s,$j,$i-$j),0,0,'',0,$link);
}

function _putType0($font)
{
	// Type0
	$this->_newobj();
	$this->_out('<</Type /Font');
	$this->_out('/Subtype /Type0');
	$this->_out('/BaseFont /'.$font['name'].'-'.$font['CMap']);
	$this->_out('/Encoding /'.$font['CMap']);
	$this->_out('/DescendantFonts ['.($this->n+1).' 0 R]');
	$this->_out('>>');
	$this->_out('endobj');
	// CIDFont
	$this->_newobj();
	$this->_out('<</Type /Font');
	$this->_out('/Subtype /CIDFontType0');
	$this->_out('/BaseFont /'.$font['name']);
	$this->_out('/CIDSystemInfo <</Registry '.$this->_textstring('Adobe').' /Ordering '.$this->_textstring($font['registry']['ordering']).' /Supplement '.$font['registry']['supplement'].'>>');
	$this->_out('/FontDescriptor '.($this->n+1).' 0 R');
	if($font['CMap']=='ETen-B5-H')
		$W = '13648 13742 500';
	elseif($font['CMap']=='GBK-EUC-H')
		$W = '814 907 500 7716 [500]';
	else
		$W = '1 ['.implode(' ',$font['cw']).']';
	$this->_out('/W ['.$W.']>>');
	$this->_out('endobj');
	// Font descriptor
	$this->_newobj();
	$this->_out('<</Type /FontDescriptor');
	$this->_out('/FontName /'.$font['name']);
	$this->_out('/Flags 6');
	$this->_out('/FontBBox [0 -200 1000 900]');
	$this->_out('/ItalicAngle 0');
	$this->_out('/Ascent 800');
	$this->_out('/Descent -200');
	$this->_out('/CapHeight 800');
	$this->_out('/StemV 50');
	$this->_out('>>');
	$this->_out('endobj');
}
}
```

> 改造fpdi下的fpdfTpl.php，改造后如下

```
<?php
use setasign\Fpdi\PDFChinese;
/**
 * This file is part of FPDI
 *
 * @package   setasign\Fpdi
 * @copyright Copyright (c) 2020 Setasign GmbH & Co. KG (https://www.setasign.com)
 * @license   http://opensource.org/licenses/mit-license The MIT License
 */

namespace setasign\Fpdi;

/**
 * Class FpdfTpl
 *
 * This class adds a templating feature to FPDF.
 */
// class FpdfTpl extends \FPDF
class FpdfTpl extends PDFChinese
{
    use FpdfTplTrait;
}
```

```
//使用字体
//$pdf->SetFont('Times');
$pdf->AddGBFont('simhei');  //宋体songti， 黑体simhei
$pdf->SetFont('simhei','',6); 


//注意此处一定要用iconv改一下编码
$pdf->Write(0,iconv("utf-8","gbk","联系方式:"));
$pdf->SetXY(120, 275);
$pdf->Write(0,iconv("utf-8","gbk","电话:"));
```

