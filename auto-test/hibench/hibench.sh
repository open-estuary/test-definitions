#! /bin/bash




yum install -y git maven wget

git clone https://github.com/intel-hadoop/HiBench.git
cd HiBench
wget https://downloads.lightbend.com/scala/2.12.4/scala-2.12.4.rpm

rpm  -ivh scala-2.12.4.rpm 

 scalac -version

wget http://mirror.bit.edu.cn/apache/hadoop/common/hadoop-2.7.4/hadoop-2.7.4.tar.gz

