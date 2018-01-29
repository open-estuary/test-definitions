---
board_reboot.md - board_reboot是通过不断重启单板，看是否会挂死，测试系统稳定性
Hardware platform: D05，D03
Software Platform: CentOS，ubuntu
Author: Chen Shuangsheng <chenshuangsheng@huawei.com>  
Date: 2017-10-27 17:12:05  
Categories: Estuary Documents  
Remark:
---
- **Dependency:**
  ```bash
    no

  ```
- **Source code:**
  no

- **Build:**
  ```bash
  no

  ```
- **Test:**
  ```bash
  1.修改rc.local文件内容如下：
    #! /bin/sh
    #
    # chkconfig: 35 99 99
    # description:Init file for reboot OS
    #
    log_file=/var/log/tan_reboot.log
    count_file=/var/log/tan_reboot.count

    r_first() 
    {

        echo 0 > $count_file
        echo "Reboot test starting..." |tee $log_file 2>/dev/null
        #ipmitool chassis power cycle
        reboot
    }

    r_second()
    {
	    count=`cat $count_file 2> /dev/null`
	    if [ $count -lt 500 ]
	    then
	     count=`expr $count + 1`
	    echo "The $count reboot finished at `date`"|tee -a $log_file 2> /dev/null
	    #fdisk -l >/tmp/01NUM/num_"`date`".log
	    #ifconfig -a|grep -i eth >/root/ethx_"`date`".log 
	    #lsusb >/root/lspci_"`date`".log
	    #free >/root/iomem_"`date`".log
	    #dmesg|egrep 'error|fail' >/root/dmesg_"`date`".log
	    echo $count > $count_file 2> /dev/null
	    #ipmitool chassis power cycle
	    reboot
	    else
	    exit
	    fi
    }

	if [ -f $count_file ]
	then
		r_second
	else
		r_first
	fi
  2.重启单板
    /etc/rc.local start
  ```
- **Result:**
  ```bash
    24小时测试后查看运行状态
  ```
