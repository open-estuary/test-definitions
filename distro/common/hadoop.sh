#! /bin/bash
export JAVA_HOME=/usr/estuary/packages/openjdk-1.8.0/jdk8u-server-release-1609
export HADOOP_HOME=/usr/local/hadoop-2.7.3
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

#config hadoop env & config file
cp -fr ./conf/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh
cp -fr ./conf/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
cp -fr ./conf/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
cp -fr ./conf/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml

mkdir -p /root/tmp

#no password login
sed -i 's/#RSAAuthentication yes/RSAAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
#sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
ssh-keygen -t rsa -P "" -f ~/.ssh/authorized_keys.tmp
cat ~/.ssh/authorized_keys.tmp.pub >> ~/.ssh/authorized_keys
rm -fr ~/.ssh/authorized_keys.tmp
chmod 0600 ~/.ssh/authorized_keys
service sshd restart

/usr/bin/expect << EOF
spawn ssh locahost
expect ""
send "yes"
send "exit\r"
EOF

hadoop namenode -format
start-dfs.sh
jps
hdfs dfs -mkdir /user
hdfs dfs -mkdir /user/root
hdfs dfs -mkdir input
hdfs dfs -put etc/hadoop/*.xml input
hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.3.jar grep input output 'dfs[a-z.]+'
