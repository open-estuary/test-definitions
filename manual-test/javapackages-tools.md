---
java.md - distro是测试发行版启动后一些基本功能，确保单板网络通讯正常，可以正常添加用户，以及开关机等操作

Hardware platform: D05　D03
Software Platform: CentOS
Author: Chen Shuangsheng <hongxin_228@163.com>
Date: 2017-12-19 13:50:05
Categories: Estuary Documents
Remark:
---

# 安装软件包
```
  yum install javapackage-tools.noarch -y
```

# 测试abs2rel命令(将绝对路径转换为相对路径)
```
(1)新建文件夹1,并带有多级目录,例如:
   mkdir -p 1/2/3/a/b
(2)运行abs2rel命令
　abs2rel 1/2/3/a/b/ 1/2/3
(3)返回结果:a/b
　
```
#测试find-jar（查找/usr/share/java/目录下的.jar文件）
```
find-jar xxx.jar
返回结果:/usr/share/java/xxx.jar
```
#测试diff-jars(查找2个jar文件中的不同之处）
```
diff-jars 1.jar 2.jar
返回结果:2个jar文件的不同之处的信息
```
#测试check-binary-files(检查二进制文件）
```
check-binary-files -f binaryfile
返回结果:二进制文件如果正常不返回任何信息
```
#测试clean-binary-files（删除二进制文件）
```
clean-binary-files -f xxx
返回结果:删除二进制文件
```
#测试build-jar-repository (建立链接文件）
```
build-jar-repository . jndi
返回结果:[jndi].jar->/usr/lib/jvm-export/java/jndi.jar
```
#测试rebuild-jar-repository(更新链接）
```
rebuild-jar-repository .
返回结果:更新的是build-jar-repository命令的结果
```
#测试build-classpath jndi(建立jar路径）
```
build-classpath jndi
返回结果:/usr/lib/jvm-exports/java/jndi.jar
```
#测试build-classpath-directory (建立jar目录）
```
build-classpath-directory /usr/share/java
返回结果:/usr/share/java/xxx.jar
```
#测试create-jar-links
```

```
#测试jvmjar
```
```
#测试xmvn-builddep
```
```
#卸载安装包
```
yum remove javapackage-tool.noarch -y
```
