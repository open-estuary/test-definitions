---
http://open-estuary.org是estuary项目的门户网站，它提供了产品介绍、注册登陆、信息查询、咨询订阅、搭建ARM64平台所需firmware的下载等服务。本用例是为了验证网页上的信息搜索功能。
 
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
  1.登陆网站
  2.在网站左下方的“Estuary Search”输入框中输入查询信息的关键字、点击“Search”键
  3.用户可以在跳转的网页中查看自己所搜索的信息
```

# Expected Result
```bash
  1.网页能正常跳转
  2.跳转的网页内容符合关键字
```
