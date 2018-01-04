---
solr.md - search engine
Hardware platform: D05，D03
Software Platform: CentOS
Author: mahongxin <hongxin_228@163.com>
Date: 2017-12-28 15:31
Categories: Estuary Documents
Remark:
---

-
    1.安装依赖包

      yum install java-1.8.0-openjdk-devel.aarch64 -y
      yum install unzip -y
　　　yum install lsof -y

    2.查看java版本是否为1.8

      java -version
      [root@localhost bin]# java -version
      openjdk version "1.8.0_151"
      OpenJDK Runtime Environment (build 1.8.0_151-b12)
      OpenJDK 64-Bit Server VM (build 25.151-b12, mixed mode)


    3.下载solr-6.6.1压缩包

      wget http://archive.apache.org/dist/lucene/solr/6.6.1/solr-6.6.1.zip



    4.解压solr
      unzip solr-6.6.1.zip


    5.修改的栈大小

      cd solr-6.6.1/bin
      vi solr
      SOLR_JAVA_STACK_SIZE='-Xss512k'###把这里修改为512K
      vi solr.cmd
      IF "%SOLR_JAVA_STACK_SIZE%"=="" set SOLR_JAVA_STACK_SIZE=-Xss512k##把这里修改为512k

    6.查看solr是否可以正常启动

      bin/solr start -force

      [root@localhost bin]# ./solr start -force
      Waiting up to 180 seconds to see Solr running on port 8983 [\]
      Started Solr server on port 8983 (pid=7172). Happy searching!


    7.查看是否有solr进程
      [root@localhost bin]# ps -ef |grep solr

　　　　　　root      7172     1 16 09:11 pts/0    00:00:07 java -server -Xms512m 　-Xmx512m -XX:NewRatio=3 -XX:SurvivorRatio=4 -XX:TargetSurvivorRatio=90 -XX:MaxTenuringThreshold=8 -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:ConcGCThreads=4 -XX:ParallelGCThreads=4 -XX:+CMSScavengeBeforeRemark -XX:PretenureSizeThreshold=64m -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=50 -XX:CMSMaxAbortablePrecleanTime=6000 -XX:+CMSParallelRemarkEnabled -XX:+ParallelRefProcEnabled -XX:-OmitStackTraceInFastThrow -verbose:gc -XX:+PrintHeapAtGC -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps -XX:+PrintTenuringDistribution -XX:+PrintGCApplicationStoppedTime -Xloggc:/root/solr-6.6.1/server/logs/solr_gc.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=9 -XX:GCLogFileSize=20M -Dsolr.log.dir=/root/solr-6.6.1/server/logs -Djetty.port=8983 -DSTOP.PORT=7983 -DSTOP.KEY=solrrocks -Duser.timezone=UTC -Djetty.home=/root/solr-6.6.1/server -Dsolr.solr.home=/root/solr-6.6.1/server/solr -Dsolr.install.dir=/root/solr-6.6.1 -Xss512k -Dsolr.log.muteconsole -XX:OnOutOfMemoryError=/root/solr-6.6.1/bin/oom_solr.sh 8983 /root/solr-6.6.1/server/logs -jar start.jar --module=http

    8.查看单板的ip地址

     ip addr

    9.查看结果

     在浏览器输入ip地址http://192.168.1.xxx:8983/sorl/
     如果看到solr页面表示启动成功
    10.创建自己的core

    [root@localhost bin]# ./solr create -c mycore -force

   Copying configuration to new core instance directory:
   /root/solr-6.6.1/server/solr/mycore

   Creating new core 'mycore' using command:
   http://localhost:8983/solr/admin/cores?                   action=CREATE&name=mycore&instanceDir=mycore

{
  "responseHeader":{
    "status":0,
    "QTime":2816},
  "core":"mycore"}

   看到如上界面代表创建成功

    11.再次刷新界面可以看到自己创建的mycore

    12.增加一条数据

　 　(1):点击Documents
　　 　在Documents(S)空白处添加一条记录比如：
　　　 {"id":"change.me","title":"change.me"}

   　(2)点击最下方的Submit Document

    13.查询

　   (1)点击QUery

     (2)点击最下方的Execute Query，如果成功添加可以看到如下信息：
　　　　　　　
　　　　　　　{
 　　　　 "responseHeader":{
   　 　"status":0,
    　　"QTime":1,
    　"params":{
      "q":"*:*",
      "indent":"on",
      "wt":"json",
      "_":"1514431393319"}},
  　　　"response":{"numFound":1,"start":0,"docs":[
      {
        "id":"change.me",
        "title":["change.me"],
        "_version_":1587997115387215872}]
 　　　　 }}

    14.删除一条记录

　　(1)点击Documents按钮
　　(2)在Document Type下拉选择xml
    (3)在Document(S)空白处添加如下内容
　　 　<delete>
　　 　<id>"change.me"</id>
　　 　</delete>
　　 　<commit/>
　　(4)点击最下方的Submit Document

    15.结束进程

      kill -9 进程

    16.卸载安装包

      yum remove -y java-1.8.0-openjdk-devel.aarch64　unzip　lsof



- **Result:**
-
      测试上述步骤是否全部通过，若是，则pass；若不是，则fail
