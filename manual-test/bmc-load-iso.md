---
bmc0load-iso.md - bmc-load-iso 是指导用户通过命令方式挂载iso文件，从而实现自动化方式部署的目的
 
Hardware platform: D05 D03  
Software Platform: CentOS Ubuntu Debian 
Author: Chen Shuangsheng <chenshuangsheng@huawei.com>  
Date: 2017-11-13 14:38:05  
Categories: Estuary Documents  
Remark:
---
#依赖
bmc版本必须要b24（2.40），否则挂载不上去
#步骤
```
##强制关闭电源
ipmitool -H 192.168.x.xxx -I lanplus -U root -P Huawei12#$ power off 
##设置上电一次从cd启动有效
sshpass -p 'Huawei12#$' ssh root@192.168.x.xxx ipmcset -d bootdevice -v 5 once
##挂载iso文件到cd
sshpass -p 'Huawei12#$' ssh root@192.168.x.xxx ipmcset -t vmm -d connect -v nfs://192.168.1.107/var/lib/xxx/Estuary.iso
##上电启动
ipmitool -H 192.168.x.xxx -I lanplus -U root -P Huawei12#$ power on
##连接控制台
ipmitool -H 192.168.x.xxx -I lanplus -U root -p Huawei12#$ sol deactive
ipmitool -H 192.168.x.xxx -I lanplus -U root -p Huawei12#$ sol active
##安装完成后退出
~.
##安装完成后卸载虚拟光驱
sshpass -p 'Huawei12#$' ssh root@192.168.x.xxx ipmcset -t vmm -d disconnect
##关闭电源
ipmitool -H 192.168.x.xxx -I lanplus -U root -P Huawei12#$ power off

```
