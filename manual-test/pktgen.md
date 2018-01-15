---
pktgen，是一个位于linux内核层的高性能网络测试工具

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2018-01-12
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1. 单板启动正常
  2. 系统启动正常
```

# Test Procedure
```
  1. 加载pktgen模块：modprobe pktgen
  2. 查看是否加载成功：lsmod |grep pktgen
  3. 查看pktgen的版本等信息：cat /proc/net/pktgen/pgctrl
  4. cpu的亲和绑定
     #cat /proc/interrupts | grep eth     //查看所有借口对应的中断，你也可以只查看某个接口
     #echo 1 > /proc/irq/56/smp_iffinity   //查看中断时eth对应9个中断，即56-64，因此都要执行绑定，这表示eth0的中断绑定到CPU1上。
     #cat /proc/irq/56/smp_iffinity     //查看是否绑定成功，返回01则表示绑定到CPU1成功，同理把eth1的中断绑定到CPU上步骤同上，你可以分开绑定，将eth1的中断绑定到CPU2上。
  5. 添加设备：echo "add_device eth3" > /proc/net/pktgen/kpktgend_0
  6. 配置报文：$ echo ""pkt_size 64"" > /proc/net/pktgen/eth3
               $ echo ""count 1000000"" > /proc/net/pktgen/eth3
               $ echo ""dst_mac aa:bb:cc:dd:ee:ff"" > /proc/net/pktgen/eth3
  7. 查看配置结果：cat /proc/net/pktgen/eth3
  8. 发送报文：echo "start" > /proc/net/pktgen/pgctrl
  9. 查看发送结果：cat /proc/net/pktgen/eth3
```

# Expected Result
```
  1. 能正常加载
  2. 报文跟配置的一致
```
