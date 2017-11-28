---
specjvm.md - specjvm 是一个观测JRE（java runtime enviroument）运行性能的基准测试套件。它的测试用例涵盖了大部分java基础应用场景，是架构选型和VM性能评测不可多得的利器
 
Hardware platform: D05 D03  
Software Platform: CentOS 
Author: Chen Shuangsheng <chenshuangsheng@huawei.com>  
Date: 2017-11-09 14:38:05  
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  yum install -y java-1.8.0-openjdk
  yum install libfreehand-devel
  yum install libfontenc-devel

```
# Source code
> Openlab2:192.168.1.107:/home/chenshuangsheng/SPECjvm2008_1_01_setup.jar

# Test
# Build
```bash
1.安装specjvm，默认配置就可以
  java -jar SPECjvm2008_1_01_setup.jar -i console
2.设置$JAVA_HOME等环境变量
  export JAVA_HOME=/usr/local/openjdk/jvm/openjdk-1.8.0-internal
  export PATH=$JAVA_HOME/bin:$PATH
  export CLASSPATH=$JAVA_HOME/lib
```
# Test
1.单条测试
```bash
  cd /SPECjvm2008
  ./run-specjvm.sh startup.helloworld -ikv
2.测试base
  mkdir -p /root/specjvm
  java -jar SPECjvm2008.jar -Dspecjvm.result.dir=/root/specjvm/ --base
```
