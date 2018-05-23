---
本用例主要是单板上串口控制功能验证

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
  1. 用usb转串口线，串口端连接单板，usb端接pc机
  2. 在pc端打开并配置串口
     如ubuntu上输入sudo minicom -s
     a. 选择端口设置，进入设置
     b. 设置端口设备，如dev/ttyUSB0
     c. 设置波特率115200
     d. 其它按默认，按esc退出当前子窗口，选择exit
  3. 在os上下发命令: board_reboot重启单板
  4. 设备重启过程中，查看串口终端输出信息是否正常
```

# Expected Result
```
  1. 串口输出信息正常
```
