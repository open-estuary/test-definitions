---
optee.md - optee test md
Hardware platform: D05，D03
Software Platform: debian
Author: mahongxin <hongxin_228@163.com>
Date: 2017-12-12 15:31
Categories: Estuary Documents
Remark:
---
- **Test:**
-
    1.安装依赖包

      apt-get install android-tools-fastboot autoconf bison cscope curl
              flex gdisk libc6:i386 libfdt-dev libglib2.0-dev
              libpixman-1-dev libstdc++:i386 libz1:i386 netcat
              python-crypto python-serial uuid-dev xz-utils zlib1g-dev

    2.准备repo工具

      mkdir ~/bin
      PATH=~/bin:$PATH
      curl http://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
      chmod a+x ~/bin/repo


    3.下载代码

      mkdir -p $HOME/devel/optee
      cd $HOME/devel/optee
      repo init -u https://github.com/OP-TEE/manifest.git -m default.xml --repo-url=git://codeaurora.org/tools/repo.git
      repo sync

    4.获取toolchain

      cd build/

      make -f toolchain.mk toolchains


    5.编译optee工程

      cd build
      make -f qemu.mk all

    6.启动qemu

      cd build
      make -f qemu.mk run-only

    7.运行命令tee-supplicant
　　　tee-supplicant $

    8.运行xtest

      xtest -l 0 -t regression

    9.卸载安装包


   10.结束进程

　　　kill xtest
      kill tee-supplicant


- **Result:**
-
      测试上述步骤是否全部通过，若是，则pass；若不是，则fail
