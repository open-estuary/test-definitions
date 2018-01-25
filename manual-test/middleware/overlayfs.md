---
overlayfs，是目前使用比较广泛的层次文件系统，实现简单，性能较好

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
  1. 加载overlayfs内核模块: $ modprobe overlay
  2. 验证是否加载成功：lsmod |grep overlay
  3. 挂载overlay文件系统,将low和upper合并成一个merged 名称的overlayfs文件系统
     $ mount -t overlay overlay -olowerdir=./low,upperdir=./upper,workdir=./work ./merged
  4. 卸载overlay：umount overlay
```

# Expected Result
```
  1. 能正常加载模块
  2. 能正常挂载和卸载
```
