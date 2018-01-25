---
LLDP是一种邻近发现协议，它为以太网网络设备，如交换机、路由器和无线局域网接入点定义了一种标准的方法，使其可以向网络中其他节点公告自身的存在，并保存各个邻近设备的发现信息

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2018-01-25
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
  1. install lldptool: yum install -y lldpad
  2. Run the LLDP Daemon: lldpad -d
  3. Run the following script:
     for i in `ls /sys/class/net/ | grep 'eth\|ens\|eno'` ;
       do echo ""enabling lldp for interface: $i"" ;
       lldptool set-lldp -i $i adminStatus=rxtx  ;
       lldptool -T -i $i -V  sysName enableTx=yes;
       lldptool -T -i $i -V  portDesc enableTx=yes ;
       lldptool -T -i $i -V  sysDesc enableTx=yes;
       lldptool -T -i $i -V sysCap enableTx=yes;
       lldptool -T -i $i -V mngAddr enableTx=yes;
     done
  4. 查看端口连接的详细信息：lldptool -t -i eth0
  5. remove lldptool: yum remove -y lldpad
```

# Expected Result
```
  1. 设备可以正常安装与卸载lldp
  2. 安装后可以正常查看端口连接的详细信息
```
