---
http://open-estuary.org是estuary项目的门户网站，它提供了产品介绍、注册登陆、信息查询、咨询订阅、搭建ARM64平台所需firmware的下载等服务。本用例是为了验证通过用户名来找回密码这一功能。
 
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
  1.在注册页面点击“Lost your password?“按钮
  2.在下方弹出的对话框中输入注册时的用户名、并输入验证码、点击”Get New Password“
  3.登陆注册时的邮箱、通过网页发送的邮件获取登陆密码
```

# Expected Result
```bash
  能正常找回密码
```
