---
UEFI.md   

Hardware platform: D05
Software Platform: CentOS
Author: tanliqing2010@163.com
Date: 2017.11.13
Categories: Estuary Documents 
Remark:
---

# Dependency :
    no
# Source code:
    no
# Build:
    no
# Perpare:
    1 登陆boardServer:
        - lab1: ssh user@192.168.1.107
        - lab2: ssh -P 222 user@htsat.vicp.cc
    2 连接单板:
        - board_connect id
    3 重启单板
        - board_reboot id
# Test
  1 把UEFI.fd文件放到107自己用户的家目录下
     note: 请校验md5值（使用md5sum file来校验md5值）
  2 重启单板，进入UEFI菜单主界面
```                             
D05                                                                            
 Hi1616                                              2.40 GHz                   
 Nemo 1.7.5 LTS                                      131072 MB RAM                                                                                          
                                                                                
   Select Language            <Standard English>         This is the option     
                                                         one adjusts to change  
 > Oem Config                                            the language for the   
 > Boot Manager                                          current system         
 > Device Manager                                                               
 > Boot Maintenance Manager                                                     
                                                                                
   Continue                                                                     
   Reset                                                                        
                                                                           
  ^v=Move Highlight       <Enter>=Select Entry
```
 3 进入“Boot Manager”菜单
```
/------------------------------------------------------------------------------\
|                                Boot Manager                                  |
\------------------------------------------------------------------------------/
                                                                                
                                                         Device Path :          
   Boot Manager Menu                                     HD(1,GPT,5EADCDE9-A1F4 
                                                         -436A-B5E9-E80D92F05C3 
   ubuntu                                                F,0x800,0x100000)/\EFI 
   CentOS Linux                                          \ubuntu\grubaa64.efi   
   debian                                                                       
   UEFI Misc Device                                                             
   UEFI                                                                         
   UEFI  2                                                                      
   UEFI PXEv4 (MAC:C0A802D40000)                                                
   UEFI HTTPv4 (MAC:C0A802D40000)                                               
   UEFI PXEv4 (MAC:C0A802D40001)                                                
   UEFI HTTPv4 (MAC:C0A802D40001)                                               
   UEFI PXEv4 (MAC:C0A802D40004)                                                
   UEFI HTTPv4 (MAC:C0A802D40004) 
   UEFI Shell
   EBL                                              
                                                       v                        
/------------------------------------------------------------------------------\
|                                                                              |
| ^v=Move Highlight       <Enter>=Select Entry      Esc=Exit                   |
\------------------------------------------------------------------------------/ 
```
 4 进入“EBL”子菜单

```
Embedded Boot Loader (EBL) prototype. Built at 10:17:28 on Oct 19 2017
THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN 'AS IS' BASIS,
WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.
Please send feedback to edk2-devel@lists.sourceforge.net
D05 >
```

 
 5 执行升级命令
 	D05 > biosupdate 192.168.1.107 -u $user -p $pw -f UEFI_D05.fd master
 $user:代表的是自己登录107的用户名 $pwd 代表自己登录107用户的密码
此命令执行完后会出现选择网口一般是选3,也有例外的情况就看MAC地址结尾是4的
 6  执行重启单板命令
 	D05 > reset

 7  参看UEFI版本信息
 	D05 > version
 
 8  查看“UEFI Shell”菜单用户体验
 	
	a. 用户是否可以使用tab补全
 	b. 验证命令输出格式是否规范
	c. 输入命令回车，验证换行功能是否正常
	d. 输入命令+退格键，验证退格键是否正常
 9 查看“EBL”菜单用户体验
	
	a. 用户是否可以使用tab补全
        b. 验证命令输出格式是否规范
        c. 输入命令回车，验证换行功能是否正常
        d. 输入命令+退格键，验证退格键是否正常	

 10 更改选项(以更改自动启动时间为例)
 	a.主菜单---> Boot Maintenance Manager 

```
/------------------------------------------------------------------------------\
|                          Boot Maintenance Manager                            |
\------------------------------------------------------------------------------/
                                                                                
 > Boot Options                                          Modify system boot     
 > Driver Options                                        options                
 > Console Options                                                              
 > Boot From File                                                               
                                                                                
   Boot Next Value            <NONE>                                            
   Auto Boot Time-out         [6]                                               
                                                                                
                                                                                
/------------------------------------------------------------------------------\
|                         F9=Reset to Defaults      F10=Save                   |
| ^v=Move Highlight       <Enter>=Select Entry      Esc=Exit                   |
\------------------------------------------------------------------------------/

```
 
    b. 选中“Auto Boot Time-out”,修改对应的数值
 		i.按“F10”保存
 		ii. 按“ESC”不保存退出:
 	d. 下次进入的时候，可查看是否已经保存，或者查看重启的时候是否已经生效
 11 直接在UEFI主菜单启动系统
 	
 12 从硬盘去启动系统
 	
```
/------------------------------------------------------------------------------\
|                                File Explorer                                 |
\------------------------------------------------------------------------------/
                                                                                
 > NO VOLUME LABEL,                                                             
   [Sata(0x0,0x0,0xAA02)/HD(1,GPT,E68C53ED-3301-4482-AD                         
   BA-1266299FD6DE,0x800,0x64000)]                                              
 > NO VOLUME LABEL,                                                             
   [Sata(0x0,0x0,0xAA05)/HD(1,GPT,5EADCDE9-A1F4-436A-B5                         
   E9-E80D92F05C3F,0x800,0x100000)]                                             
 > NO VOLUME LABEL,                                                             
   [VenMsg(06ED4DD0-FF78-11D3-BDC4-00A0C94053D1,0000000                         
   020000000)]                                                                  
   Load File                                                                    
   [VenMsg(EE369CC3-A743-5382-7564-53E431193835,010000)                         
   /MAC(C0A802D40000,0x1)]                                                      
   Load File                                                                    
   [VenMsg(EE369CC3-A743-5382-7564-53E431193835,010000)                         
   /MAC(C0A802D40000,0x1)/IPv4(0.0.0.0,0x0,DHCP,0.0.0.0                         
                                                       v                        
/------------------------------------------------------------------------------\
|                                                                              |
| ^v=Move Highlight       <Enter>=Select Entry      Esc=Exit                   |
\------------------------------------------------------------------------------/

```
    a.主菜单---> Boot Maintenance Manager 
 	b.选中“Boot From File”,键入“Entry”
    c.从上述菜单中选择一个有效菜单，进入系统
 
13 更新UEFI后，Boot Manager中旧系统的启动入口是否存在且能正常启动系统，再安装新系统，测试能否正常开机

14 VGA视频显示是否正常
	通过BMC连接到指定单板，开启虚拟控制台，查看是否可以对单板进行完全控制

15 串口打印是否正常
	通过board_connect连接到指定单板

16 USB设备插入，是否在UEFI主菜单可以显示相应的子项

17 STAT设备插入，是否在UEFI主菜单可以显示相应的子项

18 SAS设备插入，是否在UEFI主菜单可以显示相应的子项

19 SSD设备插入，是否在UEFI主菜单可以显示相应的子项

20 CDROM设备插入，是否在UEFI主菜单可以显示相应的子项

