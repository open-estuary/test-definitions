#! /bin/bash
set -x
export PS4='+{$LINENO:${FUNCNAME[0]}} '

basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../utils/sh-test-lib
. ../../utils/sys_info.sh 


### install jdk
function install_jdk() {

    yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
    export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
    export PATH=$PATH:$JAVA_HOME/bin
	
	jps > /dev/null
	print_info $? "hadoop java install" 
	
}

function install_hadoop() {
    ### install hadoop
    if [  -d hadoop-2.7.4 ];then
		rm -rf hadoop-2.7.4
	fi

	if [ ! -f hadoop-2.7.4.tar.gz ];then
        wget http://mirror.bit.edu.cn/apache/hadoop/common/hadoop-2.7.4/hadoop-2.7.4.tar.gz
    fi
    tar -zxf hadoop-2.7.4.tar.gz
 
	cd hadoop-2.7.4
	sed -i "s/export JAVA_HOME=.*/export JAVA_HOME=\/usr\/lib\/jvm\/java-1.8.0-openjdk/g" etc/hadoop/hadoop-env.sh
	print_info $? "hadoop edit config add JAVA_HOME env"
	export HADOOP_HOME=`pwd`
	if [ -n `echo $HADOOP_HOME` ];then
		lava-test-case "hadoop set HADOOP_HOME" pass
	else
		lava-test-case "hadoop set HADOOP_HOME" fail
	fi
	
}

function hadoop_standalone() {
	cd $HADOOP_HOME
	rm -rf input output
	mkdir input
  	cp etc/hadoop/*.xml input
  	bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.4.jar grep input output 'dfs[a-z.]+' > /dev/null 2>&1
  	if [ -f output/_SUCCESS ];then
		lava-test-case "hadoop standalone test" pass
	else
		lava-test-case "hadoop standalone test" fail
	fi
}

function hadoop_config_base() {

 #1\ edit config file
    cd $HADOOP_HOME
    cp etc/hadoop/core-site.xml{,.bak}
    cat <<EOF >etc/hadoop/core-site.xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/tmp/hadoop-root</value>
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


}
function hadoop_namenode_format() {
	cd $HADOOP_HOME
	rm -rf /tmp/*
    bin/hdfs namenode -format
    print_info $? "hadoop single node format namenode"
}
function hadoop_ssh_nopasswd() {
	#2\ ssh without password
    if [ -d ~/.ssh ];then
        rm -rf ~/.ssh
    fi
    ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    chmod 0600 ~/.ssh/authorized_keys
    echo  "StrictHostKeyChecking=no" >> ~/.ssh/ssh_conf
    print_info $? "hadoop single node ssh without password"
}

function hadoop_single_node() {
	#1\ edit config file 

	cd $HADOOP_HOME

	# 4 start namenode 
	sbin/start-dfs.sh
	print_info $? "hadoop single node start dfs"
	
	# 5 
	jps | grep NameNode | grep -v Jps
	res1=$?
	jps | grep DataNode | grep -v Jps
	res2=$?
	jps | grep SecondaryNameNode | grep -v  Jps
	res3=$?
	if [ -n $res1 ] && [  -n $res2 ] && [ -n  $res3 ];then
		lava-test-case "hadoop single node dfs process" pass
	else
		lava-test-case "hadoop single node dfs process" fail
		echo "-------------------------------------------------"
		echo "---------------------hadoop hdfs can not start normal----------------------------"
		echo "-------------------------------------------------"
		exit 1
	fi
	
	bin/hdfs dfsadmin -safemode leave	
	print_info $? "hadoop close safe node mode"
	bin/hdfs dfs -test -e /aa
	if [ $? ];then
		bin/hdfs dfs -rm  -r /aa
	fi
	bin/hdfs dfs -mkdir /aa
	print_info $? "hadoop mkdir command"

	bin/hdfs dfs -test -e /input
	if [ $? -eq 0 ];then
		bin/hdfs dfs -rm -r /input
	fi	
	bin/hdfs dfs -put etc/hadoop /input
	print_info $? "hadoop put command"
	
	bin/hdfs dfs -ls /aa
	print_info $? "hadoop ls command"
	bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.4.jar grep /input /output 'dfs[a-z.]+' > /dev/null 2>&1
	
	bin/hdfs dfs -ls /output/_SUCCESS
	print_info $? "hadoop jar command"


	sbin/stop-dfs.sh
	res1=`jps | grep NameNode | grep -vci jps`
	res2=`jps | grep DataNode | grep -vic jps`
	res3=`jps | grep SecondaryNameNode | grep -vci jps`
	if [ $res1 -eq 0 ] && [ $res2 -eq 0 ] && [ $res3 -eq 0 ];then
		true
	else
		false
	fi
	print_info $?  "hadoop stop hdfs"
}

function hadoop_config_yarn() {
	cd $HADOOP_HOME
    if [ !  -f  etc/hadoop/mapred-site.xml ];then
        cp  etc/hadoop/mapred-site.xml.template etc/hadoop/mapred-site.xml
    fi
    cat > etc/hadoop/mapred-site.xml <<EOF
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
EOF
    print_info $? "hadoop edit mapreduce.frameword.name"
    
    cat > etc/hadoop/yarn-site.xml <<EOF
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
</configuration>
EOF
    print_info $? "hadoop edit enable shuffle para"	
}

function hadoop_single_with_yarn() {
	cd $HADOOP_HOME
	print_info $? "hadoop edit enable shuffle para"
	sbin/start-dfs.sh
	sbin/start-yarn.sh
	res1=`jps | grep NodeManager | grep -vc Jps`
	res2=`jps | grep ResourceManager | grep -vc Jps`
	if [ $res1 -eq 1 ] && [ $res2 -eq 1 ];then
		lava-test-case "hadoop start yarn" pass
	else
		lava-test-case "hadoop start yarn" fail
		echo "hadoop start yarn error ---------------"
		echo 'for try ,use "ps -ef |grep java | grep -v grep | awk {'print $2'} | xargs kill -9"'
		exit 1
	fi
	
	
	bin/hdfs dfs -test -e /input
	res=$?
	if [  $res -ne 0 ];then
		bin/hdfs dfs -put etc/hadoop /input
	fi
	
	bin/hadoop fs -test -e /input
	res=$?
	print_info $res "hadoop command dir test"
	
	bin/hdfs dfs -test -e /output2	
	if [ $? -eq 0 ] ;then
		bin/hdfs dfs -rm -R /output2
		print_info $? "hadoop command rm dir"
	fi
	sleep 3
	bin/hdfs dfsadmin -safemode leave 
	bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.4.jar grep /input /output2 'dfs[a-z.]+'>/dev/null 2>&1
	
	bin/hadoop fs -test -e /output2/_SUCCESS
	print_info  $?  "hadoop single node exec mapred"

	bin/hdfs dfs -cat /input/core-site.xml | grep defaultFS
	print_info $? "hadoop commadn cat file"
	
	bin/hdfs getconf -confkey dfs.replication
	print_info $? "hadoop get config from key"

	bin/hdfs dfsadmin -report
	print_info $? "hadoop report status"
	
	bin/hdfs dfs -cp /input/core-site.xml /output2/core-site.xml
    print_info $? "hadoop command cp operator"
	
	bin/hdfs dfs -mv /input/core-site.xml /output/core-site.xml
	print_info $? "hadoop command mv operator"
	sleep 3
jps
	sbin/hadoop-daemon.sh stop namenode
	if [ $? -eq 0 ];then
		res1=`jps | grep -i namenode | grep -vi secondarynamenode | grep -vic jps`
		if [ $res1 -eq 0 ];then
			true
		else
			false
		fi
		print_info $? "hadoop stop namenode daemon "
	else
		lava-test-case "hadoop stop namenode daemon" --result fail
	fi
jps	
	sleep 3
	sbin/hadoop-daemon.sh start namenode
	if [ $? -eq 0 ];then
		res1=`jps | grep -i namenode | grep -vi secondarynamenode | grep -ivc jps`
		if [ $res1 -eq 1 ];then
			lava-test-case "hadoop start namenode" --result pass
		else
			lava-test-case "hadoop start namenode" --result fail
		fi
	else
		lava-test-case "hadoop start namenode" --result fail
	fi
jps
	sleep 3
	sbin/hadoop-daemon.sh stop datanode
	if [ $? -eq 0 ];then
		jps | grep -i datanode | grep -v Jps
		if [ $? -eq 0 ];then
			false
		else
			true
		fi
		print_info  $?  "hadoop stop datanode"
	else
		lava-test-case "hadoop stop datanode" --result fail
	fi
jps	
	sleep 3
	sbin/hadoop-daemon.sh start datanode
	if [ $? -eq 0 ];then
		jps | grep -i datanode | grep -v Jps
		print_info $? "hadoop start datanode"
	else
		lava-test-case "hadoop start datanode" --result fail
	fi
jps	
	sbin/hadoop-daemon.sh stop secondarynamenode
	if [ $? -eq 0 ];then
		jps | grep -i secondarynamenode | grep -vi jps 
		if [ $? -eq 0 ];then
			false
		else
			true
		fi
		print_info $? "hadoop stop secondarynamenode"
	else
		lava-tese-case "hadoop stop secondarynamenode" --result fail
	fi
jps
 	sbin/hadoop-daemon.sh start secondarynamenode
    if [ $? -eq 0 ];then
        jps | grep -i secondarynamenode | grep -vi jps 
        print_info $? "hadoop start secondarynamenode"
    else    
        lava-tese-case "hadoop start secondarynamenode" --result fail
    fi		
jps
	sbin/yarn-daemon.sh stop nodemanager
    if [ $? -eq 0  ];then
        jps | grep -i nodemanager | grep -vi jps 
        if [ $? -eq 0 ];then
            false   
        else    
            true    
        fi      
        print_info $? "hadoop stop nodemanager"
    else    
        lava-tese-case "hadoop stop nodemanager" --result fail
    fi
jps
	sbin/yarn-daemon.sh start nodemanager
    if [ $? -eq 0 ];then
        jps | grep -i nodemanager | grep -vi jps      
        print_info $? "hadoop start nodemanager"
    else    
        lava-tese-case "hadoop start nodemanager" --result fail
    fi
jps	
 	sbin/yarn-daemon.sh stop resourcemanager
    if [ $? -eq 0 ];then
        jps | grep -i resourcemanager | grep -vi jps      
        if [ $? -eq 0 ];then
            false   
        else    
            true    
        fi      
        print_info $? "hadoop stop resourcemanager"
    else    
        lava-tese-case "hadoop stop resourcemanager" --result fail
    fi 
jps
	sbin/yarn-daemon.sh start resourcemanager
    if [ $?  -eq 0 ];then
        jps | grep -i resourcemanager | grep -vi jps      
        print_info $? "hadoop start resourcemanager"
    else    
        lava-tese-case "hadoop start resourcemanager" --result fail
    fi
jps	
	sbin/stop-yarn.sh
	print_info $? "hadoop single node  stop yarn"

	sbin/stop-dfs.sh
	print_info $? "hadoop single node stop dfs"
	
}

function uninstall_hadoop() {
	ps -ef |grep java | grep -v grep | awk {'print $2'}| xargs kill -9
	rm -rf $HADOOP_HOME
	rm -rf /tmp/hadoop-root
}


install_jdk
install_hadoop

hadoop_standalone

hadoop_ssh_nopasswd
hadoop_config_base
hadoop_namenode_format

hadoop_single_node

hadoop_config_yarn
hadoop_single_with_yarn

