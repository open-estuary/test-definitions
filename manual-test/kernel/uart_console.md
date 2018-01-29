---
uart_console.md - uart_console 测试串口控制
 
Hardware platform: D05 D03  
Software Platform: CentOS Ubuntu Debian 
Author: Chen Shuangsheng <chenshuangsheng@huawei.com>  
Date: 2017-15-02 12:38:05  
Categories: Estuary-kernel  
Remark:
---
#测试步骤
```
1.用串口线连接单板的串口，usb接口一端接pc机
2.在pc端打开并配置串口,如ubuntu上输入sudo minicom -s
    1.选择端口设置，进入设置
    2.设置端口设备，如dev/ttyUSB0
    3.设置波特率115200
    4.其它按默认，按esc退出当前子窗口，选择exit．
3.在服务器使用board_reboot重启单板，也可以用其它方式重启
4.查看串口终端输出信息是否正常

```
