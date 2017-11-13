---
UEFI.md   -

Hardware platform: D05
Software Platform: CentOS
Author: tanliqing@163.com
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
  1 下载UEFI.fd文件
     note: 请校验md5值
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
 6  执行重启单板命令
 	D05 > reset
 7  参看UEFI版本信息
 	D05 > version
 8  查看“UEFI Shell”菜单用户体验
 	a. 用户是否可以使用tab补全
 	b. 字符打印是否出现乱码
 9 更改选项(以更改自动启动时间为例)
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
 10 直接在UEFI主菜单启动系统
 	
 11 从硬盘去启动系统
 	a.主菜单---> Boot Maintenance Manager 
 	b.选中“Boot From File”,键入“Entry”

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

    c.从上述菜单中选择一个有效菜单，进入系统
 
12 更新UEFI后，安装新系统，测试能否正常开机
