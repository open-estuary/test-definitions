---
本用例主要是单板上vga功能验证

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2018-03-12
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1. 服务器1台且能正常启动系统
```

# Test Procedure
```
  1. 用vga线将单板和显示器连接
  2. os下发命令: board_reboot重启单板
  3. 单板重启过程，查看vga能否正常显示
```

# Expected Result
```
  1. vga能正常显示
```
