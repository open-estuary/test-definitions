---
http://open-estuary.org是estuary项目的门户网站，它提供了产品介绍、注册登陆、信息查询、咨询订阅、搭建ARM64平台所需firmware的下载等服务。本用例是为了验证网页上资讯的订阅。
 
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
  1.用户登陆网页
  2.在网页的下方中间的“Subscribe to our Newsletter”输入框中输入接收订阅信息的邮箱、点击“Subscribe”按钮
  3.登入邮箱、在网页发送的邮件中确认订阅
```

# Expected Result
```bash
  1.网页上信息能正常订阅
  2.邮箱能收到网页发送的邮件
```
