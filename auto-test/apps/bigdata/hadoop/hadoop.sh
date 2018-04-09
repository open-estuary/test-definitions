#! /bin/bash

### install jdk
function install_jdk() {

    yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
    sed -i "/JAVA_HOME/d" ~/.bashrc
    echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk" >> ~/.bashrc
    echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc
	
    jps > /dev/null
    print_info $? "hadoop_java_install" 
    yum install -y wget 	
}

function install_hadoop() {
    ### install hadoop 


    local version='2.7.4'


    if test ! -d /var/bigdata/hadoop
    then
        mkdir -p /var/bigdata/hadoop
    fi 
    
    
    pushd   /var/bigdata/hadoop/



    if [  -d hadoop-$version ];then
		rm -rf hadoop-$version 
	fi

	if [ ! -f hadoop-${version}.tar.gz ];then
        #timeout 1m wget -c http://192.168.1.107/test-definitions/hadoop-${version}.tar.gz 
        timeout 1m  wget -c http://htsat.vicp.cc:804/test-definitions/hadoop-${version}.tar.gz
        if [ $? -ne 0 ];then 
            wget -q -c  http://mirror.bit.edu.cn/apache/hadoop/common/hadoop-${version}/hadoop-${version}.tar.gz 
        fi
        if test $? -ne 0;then
            echo 
            echo "download hadoop source error,please check url or network !!!"
            echo 
            exit 1
        fi 
    fi
    tar -zxf hadoop-${version}.tar.gz
 
    pushd hadoop-${version}
	
    sed -i "s/export JAVA_HOME=.*/export JAVA_HOME=\/usr\/lib\/jvm\/java-1.8.0-openjdk/g" etc/hadoop/hadoop-env.sh
	print_info $? "hadoop_edit_config_add_JAVA_HOME_env"
	
	grep HADOOP_HOME ~/.bashrc 
	if [ $? -eq 0 ];then
		sed -i "/HADOOP_HOME/d" ~/.bashrc	
	fi
	export HADOOP_HOME=`pwd`
	echo "export HADOOP_HOME=`pwd`" >> ~/.bashrc
	echo 'export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin' >> ~/.bashrc
	source ~/.bashrc > /dev/null 2>&1 
    
    
    popd 
    popd 


	if [ -n $HADOOP_HOME ];then
		lava-test-case "hadoop_set_HADOOP_HOME" --result pass
	else
		lava-test-case "hadoop_set_HADOOP_HOME" --result fail
	fi
	
}

function hadoop_standalone() {
	cd $HADOOP_HOME
	rm -rf input output
	mkdir input
  	cp etc/hadoop/*.xml input
  	bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-${version}.jar grep input output 'dfs[a-z.]+' > /dev/null 2>&1
  	if [ -f output/_SUCCESS ];then
		lava-test-case "hadoop_standalone_test" --result pass
	else
		lava-test-case "hadoop_standalone_test" --result fail
	fi
}

function hadoop_config_base() {

 #1\ edit config file
    pushd $HADOOP_HOME
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
    print_info $? "hadoop_single_node_edit_defaultFS_argment"

    cp etc/hadoop/hdfs-site.xml{,.bak}
    cat <<EOF > etc/hadoop/hdfs-site.xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>

</configuration>
EOF
    print_info $? "hadoop_single_node_edit_replication_argment"

    popd 

}
function hadoop_namenode_format() {
	pushd  $HADOOP_HOME
	rm -rf /tmp/hadoop-root
    bin/hdfs namenode -format
    print_info $? "hadoop_single_node_format_namenode"
    
    popd 

}


function hadoop_ssh_nopasswd() {
	#2\ ssh without password
    if [ -d ~/.ssh ];then
        rm -rf ~/.ssh
    fi
    
    ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    chmod 0600 ~/.ssh/authorized_keys
	echo  "StrictHostKeyChecking=no" >> ~/.ssh/config
	print_info $? "hadoop_single_node_ssh_without_password"

    
}

function hadoop_single_node() {
	#1\ edit config file 

	pushd  $HADOOP_HOME

	# 4 start namenode 
	sbin/start-dfs.sh
	print_info $? "hadoop_single_node_start_dfs"
	
	# 5 
	jps | grep NameNode | grep -v Jps
	res1=$?
	jps | grep DataNode | grep -v Jps
	res2=$?
	jps | grep SecondaryNameNode | grep -v  Jps
	res3=$?
	if [ -n $res1 ] && [  -n $res2 ] && [ -n  $res3 ];then
		lava-test-case "hadoop_single_node_dfs_process" --result pass
	else
		lava-test-case "hadoop_single_node_dfs_process" --result fail
		echo "-------------------------------------------------"
		echo "---------------------hadoop hdfs can not start normal----------------------------"
		echo "-------------------------------------------------"
		exit 1
	fi
	
	bin/hdfs dfsadmin -safemode leave	
	print_info $? "hadoop_close_safe_node_mode"
	bin/hdfs dfs -test -e /aa
	if [ $? ];then
		bin/hdfs dfs -rm  -r /aa
	fi
	bin/hdfs dfs -mkdir /aa
	print_info $? "hadoop_mkdir_command"

	bin/hdfs dfs -test -e /input
	if [ $? -eq 0 ];then
		bin/hdfs dfs -rm -r /input
	fi	
	bin/hdfs dfs -put etc/hadoop /input
	print_info $? "hadoop_put_command"
	
	bin/hdfs dfs -ls /aa
	print_info $? "hadoop_ls_command"
	bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.4.jar grep /input /output 'dfs[a-z.]+' > /dev/null 2>&1
	
	bin/hdfs dfs -ls /output/_SUCCESS
	print_info $? "hadoop_jar_command"


	sbin/stop-dfs.sh
	res1=`jps | grep NameNode | grep -vci jps`
	res2=`jps | grep DataNode | grep -vic jps`
	res3=`jps | grep SecondaryNameNode | grep -vci jps`
	if [ $res1 -eq 0 ] && [ $res2 -eq 0 ] && [ $res3 -eq 0 ];then
		true
	else
		false
	fi
	print_info $?  "hadoop_stop_hdfs"

    popd 
}

function hadoop_config_yarn() {
	pushd  $HADOOP_HOME
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
    print_info $? "hadoop_edit_mapreduce.frameword.name"
    
    cat > etc/hadoop/yarn-site.xml <<EOF
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
</configuration>
EOF
    print_info $? "hadoop_edit_enable_shuffle_para"	

    popd 
}

function hadoop_single_with_yarn() {
	pushd  $HADOOP_HOME
	print_info $? "hadoop_edit_enable_shuffle_para"
	sbin/start-dfs.sh
	sbin/start-yarn.sh
	res1=`jps | grep NodeManager | grep -vc Jps`
	res2=`jps | grep ResourceManager | grep -vc Jps`
	if [ $res1 -eq 1 ] && [ $res2 -eq 1 ];then
		lava-test-case "hadoop_start_yarn" --result pass
	else
		lava-test-case "hadoop_start_yarn" --result fail
		echo "hadoop_start_yarn error ---------------"
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
	print_info $res "hadoop_command_dir_test"
	
	bin/hdfs dfs -test -e /output2	
	if [ $? -eq 0 ] ;then
		bin/hdfs dfs -rm -R /output2
		print_info $? "hadoop_command_rm_dir"
	fi
	sleep 3
	bin/hdfs dfsadmin -safemode leave 
	bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.4.jar grep /input /output2 'dfs[a-z.]+'>/dev/null 2>&1
	
	bin/hadoop fs -test -e /output2/_SUCCESS
	print_info  $?  "hadoop_single_node_exec_mapred"

	bin/hdfs dfs -cat /input/core-site.xml | grep defaultFS
	print_info $? "hadoop_commadn_cat_file"
	
	bin/hdfs getconf -confkey dfs.replication
	print_info $? "hadoop_get_config_from_key"

	bin/hdfs dfsadmin -report
	print_info $? "hadoop_report_status"
	
	bin/hdfs dfs -cp /input/core-site.xml /output2/core-site.xml
    print_info $? "hadoop_command_cp_operator"
	
	bin/hdfs dfs -mv /input/core-site.xml /output/core-site.xml
	print_info $? "hadoop_command_mv_operator"
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
		print_info $? "hadoop_stop_namenode_daemon "
	else
		lava-test-case "hadoop_stop_namenode_daemon" --result fail
	fi
jps	
	sleep 3
	sbin/hadoop-daemon.sh start namenode
	if [ $? -eq 0 ];then
		res1=`jps | grep -i namenode | grep -vi secondarynamenode | grep -ivc jps`
		if [ $res1 -eq 1 ];then
			lava-test-case "hadoop_start_namenode" --result pass
		else
			lava-test-case "hadoop_start_namenode" --result fail
		fi
	else
		lava-test-case "hadoop_start_namenode" --result fail
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
		print_info  $?  "hadoop_stop_datanode"
	else
		lava-test-case "hadoop_stop_datanode" --result fail
	fi
jps	
	sleep 3
	sbin/hadoop-daemon.sh start datanode
	if [ $? -eq 0 ];then
		jps | grep -i datanode | grep -v Jps
		print_info $? "hadoop_start_datanode"
	else
		lava-test-case "hadoop_start_datanode" --result fail
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
		print_info $? "hadoop_stop_secondarynamenode"
	else
		lava-tese-case "hadoop_stop_secondarynamenode" --result fail
	fi
jps
 	sbin/hadoop-daemon.sh start secondarynamenode
    if [ $? -eq 0 ];then
        jps | grep -i secondarynamenode | grep -vi jps 
        print_info $? "hadoop_start_secondarynamenode"
    else    
        lava-tese-case "hadoop_start_secondarynamenode" --result fail
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
        print_info $? "hadoop_stop_nodemanager"
    else    
        lava-tese-case "hadoop_stop_nodemanager" --result fail
    fi
jps
	sbin/yarn-daemon.sh start nodemanager
    if [ $? -eq 0 ];then
        jps | grep -i nodemanager | grep -vi jps      
        print_info $? "hadoop_start_nodemanager"
    else    
        lava-tese-case "hadoop_start_nodemanager" --result fail
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
        print_info $? "hadoop_stop_resourcemanager"
    else    
        lava-tese-case "hadoop_stop_resourcemanager" --result fail
    fi 
jps
	sbin/yarn-daemon.sh start resourcemanager
    if [ $?  -eq 0 ];then
        jps | grep -i resourcemanager | grep -vi jps      
        print_info $? "hadoop_start_resourcemanager"
    else    
        lava-tese-case "hadoop_start_resourcemanager" --result fail
    fi
    popd 
jps	
}

function hadoop_stop_all(){

    pushd  $HADOOP_HOME
	sbin/stop-yarn.sh
	print_info $? "hadoop_single_node_stop_yarn"

	sbin/stop-dfs.sh
	print_info $? "hadoop_single_node_stop_dfs"
	popd 
}

function uninstall_hadoop() {
	ps -ef |grep java | grep -v grep | awk {'print $2'}| xargs kill -9
	rm -rf $HADOOP_HOME
	rm -rf /tmp/hadoop-root
}


