#! /bin/bash
set -x

basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../utils/sh-test-lib
. ../../utils/sys_info.sh 


### install jdk
function install_jdk() {

    yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
    export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
    export PATH=$PATH:$JAVA_HOME/bin
}

function install_hibench {
    ### install git maver wget
    yum install -y git maven wget
	mvn -v
	print_info $? "hibench-install maven" 

    ## install hibench
    if [ ! -d HiBench  ];then
        git clone https://github.com/intel-hadoop/HiBench.git
		if [ -d HiBench ];then
			lava-test-case "hibench git clone" --result pass
		else
			lava-test-case "hibench git clone" --result fail
		fi    	
	fi
    cd HiBench
		git checkout HiBench-6.0
		#	bin/build-all.sh
		
		##hear should use for loop
		mvn -Phadoopbench clean package
		print_info $? "hibench build"
		
		# edit language.lst
		cp conf/languages.lst{,.bak}
		sedi -i  "/spark\/java/d" conf/languages.lst
		sed  -i  "/spark\/scala/d" conf/languages.lst
		sed  -i  "/spark\/python/d" conf/languages.lst
		if [ `grep "spark" -c conf/languages.lst` == 0 ] ;then
			lava-test-case "hibench edit config" --result pass
		else 
			lava-test-case "hibench edit config" --result fail
		fi
		
		# edit hibench config file
		cp conf/hadoop.conf.template conf/hadoop.conf
		sed -i "s/hibench\.hadoop\.home.*/ hibench\.hadoop\.home  $HADOOP_HOME/"
		
	
		bin/run-all.sh
		
				
    cd ..
}



function install_hadoop() {
    ### install hadoop
    if [ ! -d hadoop-2.7.4 ];then
		if [ ! -f hadoop-2.7.4.tar.gz ];then
			wget http://mirror.bit.edu.cn/apache/hadoop/common/hadoop-2.7.4/hadoop-2.7.4.tar.gz
		fi	
		tar -zxf hadoop-2.7.4.tar.gz
		
	fi
 	cd hadoop-2.7.4
	sed -i "s/export JAVA_HOME=.*/export JAVA_HOME=\/usr\/lib\/jvm\/java-1.8.0-openjdk/g" etc/hadoop/hadoop-env.sh
	print_info $? "hadoop edit config add JAVA_HOME env"
	export HADOOP_HOME=`pwd`
	
}

function hadoop_standalone() {
	cd $HADOOP_HOME
	rm -rf input output
	mkdir input
  	cp etc/hadoop/*.xml input
  	bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.4.jar grep input output 'dfs[a-z.]+'
  	if [ -f output/_SUCCESS ];then
		lava-test-case "hadoop standalone test" pass
	else
		lava-test-case "hadoop standalone test" fail
	fi
}

function hadoop_single_node() {
	#1\ edit config file 
	cd $HADOOP_HOME
	cp etc/hadoop/core-site.xml{,.bak}
	cat <<EOF >etc/hadoop/core-site.xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>
EOF
	print_info $? "hadoop single node edit defaultFS argment"
	cp etc/hadoop/hdfs-site.xml{,.bak}
	cat <<EOF > etc/hadoop/hdfs-site.xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
</configuration>
EOF
	print_info $? "hadoop single node edit replication argment"
	
	#2\ ssh without password 
	ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
  	cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
   	chmod 0600 ~/.ssh/authorized_keys
	
	print_info $? "hadoop single node ssh without password"

	# 3 format namenode 
	bin/hdfs namenode -format	
	
	print_info $? "hadoop single node format namenode"

	# 4 start namenode 
	bin/start-dfs.sh
	print_info $? "hadoop single node start dfs"
	
	# 5 
	jps | grep NameNode | grep -v Jps
	res1=`$?`
	jps | grep DataNode | grep -v Jps
	res2=`$?`
	jps | grep SecondaryNameNode | grep -v  Jps
	res3=`$?`
	if [ $res1 && $res2 && $res3 ];then
		lava-test-case "hadoop single node dfs process" pass
	else
		lava-test-case "hadoop single node dfs process" fail
	fi

	bin/hdfs dfs -mkdir /aa &&\
	bin/hdfs dfs -mkdir /bb
	print_info $? "hadoop mkdir command"

	bin/hdfs dfs -put etc/hadoop /input
	print_info $? "hadoop put command"
	
	bin/hdfs dfs -ls /aa
	print_info $? "hadoop ls command"

	bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.4.jar grep /input /output 'dfs[a-z.]+'
	
	bin/hdfs dfs -ls /output/_SUCCESS
	print_info $? "hadoop jar command"


	sbin/stop-dfs.sh
	res1=`jps | grep NameNode | grep -vi jps`
	res2=`jps | grep DataNode | grep -vi jps`
	res3=`jps | grep SecondaryNameNode | grep -vi jps`
	print_info  $res1 && $res2 && $res3 "hadoop stop hdfs"
}
function hadoop_single_with_yarn() {
	cd $HADOOP_HOME
	if [ !  -f  etc/hadoop/mapred-site.xml ];then
		cp  etc/hadoop/mapred-site.xml.template etc/hadoop/mapred-site.xml
	fi
	cat >> etc/hadoop/mapred-site.xml <<EOF
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
EOF
	print_info $? "hadoop edit mapreduce.frameword.name"
	
	cat >> etc/hadoop/yarn-site.xml <<EOF
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
</configuration>
EOF

	sbin/start-dfs.sh
	sbin/start-yarn.sh
	res1=`jps | grep NodeManager | grep -vc Jps`
	res2=`jps | grep ResourceManager | grep -vc Jps`
	if [ $res1 ==1 ] && [ $res2 == 1 ];then
		lava-test-case "hadoop start yarn" pass
	else
		lava-test-case "hadoop start yarn" fail
	fi
	
	bin/hadoop fs -test -e /input
	res=`$?`
	print_info $res "hadoop command dir test"
	if [ ! $res ];then
		bin/hdfs dfs -put etc/hadoop /input
	fi
	
	if [ `bin/hadoop fs -test -e /output` ];then
		bin/hadoop fs -rm -R /output
		print_info $? "hadoop command rm dir"
	fi
	bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.4.jar grep /input /output 'dfs[a-z.]+'
	
	res1=`bin/hadoop fs -test -e /output/_SUCCESS`
	print_info $res1 "hadoop single node exec mapred"
	
	sbin/stop-yarn.sh
	print_info $? "hadoop single node  stop yarn"

	sbin/stop-dfs.sh
	print_info $? "hadoop single node stop dfs"
	
}



install_jdk
install_hadoop
hadoop_standalone
hadoop_sigle_node


