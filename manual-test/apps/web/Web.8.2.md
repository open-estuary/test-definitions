---
http://open-estuary.org是estuary项目的门户网站，它提供了产品介绍、注册登陆、信息查询、咨询订阅、搭建ARM64平台所需firmware的下载等服务。本用例是为了验证网页上firmware的下载功能。
 
Hardware platform: PC  
Software Platform: linux or windows 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-06
Categories: Estuary Documents  
Remark:
---

# Dependency
```
N/A
```

# Test Procedure
```bash
  1.登陆网页、点击“Downloads”的“Binary Download”项
  2.根据所打开网页上的说明下载所需Firmware
    a.中国境内用户登陆ftp://117.78.41.188服务器下载所需的firmware
    b.国外用户登陆http://download.open-estuary.org/服务器下载所需的firmware
```

# Expected Result
```bash
  根据网页提示找到并下载所需Firmware
```
