---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡ipV6支持测试

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-07
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1.服务器1台且能正常启动系统
  2.82599网卡一块
```

# Test Procedure
```bash
  1.单板上电启动，进入OS
  2.配置网卡IPV6,如:ifconfig HiNIC0 inet6 add 2001:da8:2004:1000:202:116:160:41/64 up，有结果A)
  3.测试IPV6是否能正常通信，有结果B)
  4.遍历所有网口
```

# Expected Result
```bash
  A) 能正常配置IPV6
  B) 能正常通信
```
