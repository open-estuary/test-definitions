---
seliunx.md - selinux 目的在于明确的指明某个进程可以访问哪些资源
Hardware platform: D05，D03
Software Platform: CentOS
Author: mahongxin <hongxin_228@163.com>  
Date: 2018-2-28 15:31
Categories: Estuary Documents  
Remark:
---  
   
- **Test:**
    1.获取当前SELinux运行状态
       getenforce
       可能返回三种结果：Enforcing代表记录警告且阻止可疑行为
　　　　　　　　　　　　　　　　　　　　　　　　Disabled 代表SELinux被禁用
　　　　　　　　　　　　　　　　　　　　　　　　Permissive 代表仅仅记录安全警告单不阻止可疑行为
    2.改变SElinux运行状态
　　　　　　setenforce [Enforcing|Permissive|1|0]

    3.SELinux 运行策略
    配置文件 /etc/selinux/config 还包含了 SELinux 运行策略的信息，通过改变变量 SELINUXTYPE 的值实现，该值有两种可能： targeted 代表仅针对预制的几种网络服务和访问请求使用 SELinux 保护，strict 代表所有网络服务和访问请求都要经过 SELinux
    4. coreutils 工具的 SELinux 模式
常见的属于 coreutils 的工具如 ps、ls 等等，可以通过增加 Z 选项的方式获知 SELinux 方面的信息。
  
- **Result:**
      测试上述步骤是否全部通过，若是，则pass；若不是，则fail
