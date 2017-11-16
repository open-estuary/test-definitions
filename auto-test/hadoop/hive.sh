#! /bin/bash

. ./hadoop.sh

function hive_install(){
	pwd
	if [ -f apache-hive-2.1.1-bin.tar.gz ];then
		if [ -d apache-hive-2.1.1-bin ];then
			rm -rf apache-hive-2.1.1-bin
		fi
	else
		wget  http://mirrors.shuosc.org/apache/hive/hive-2.1.1/apache-hive-2.1.1-bin.tar.gz
		if [ $? ];then
			lava-test-case "hive download bin file" --result pass
		else
			lava-test-case "hive download bin file" --result fail
			exit 1
		fi
	fi
	tar  -zxf apache-hive-2.1.1-bin.tar.gz
	cd apache-hive-2.1.1-bin
	pwd
	sed -i "/HIVE_HOME/d" ~/.bashrc
	export HIVE_HOME=`pwd` &&
	echo "export HIVE_HOME=`pwd`" >> ~/.bashrc &&
	echo 'export PATH=$PATH:$HIVE_HOME/bin' >> ~/.bashrc 
	print_info $? "hive config system envriment parament"
	source ~/.bashrc 	
	print_info $? "hive install"
}

function hive_edit_config(){
	cd $HIVE_HOME
	cp -f  ${basedir}/hive-site.xml conf/hive-site.xml
    	
	res=`diff  conf/hive-default.xml.template conf/hive-site.xml | grep "/tmp/hive" -c`
	if [ $res -ge 3 ];then
		lava-test-case "hive edit config file" --result pass
	else 
		lava-test-case "hive edit config file" --result fail
	fi

}

function isDfsRunning(){
    res1=`jps | grep -i namenode | grep -vi secondarynamenode | grep -vc Jps`
    res2=`jps | grep -i datanode | grep -vc Jps`
    res3=`jps | grep -i secondarynamenode | grep -vc Jps`
    if [ $res1 -eq 1 ] && [ $res2 -eq 1 ] && [ $res3 -eq 1 ] ;then
        return 0
    else
        return 1
    fi
}

function isYarnRunning() {
	res1=`jps | grep -i nodemanager | grep -vc Jps`
	res2=`jps | grep -i resourcemanager | grep -vc Jps`
	if [ $res1 -eq 1 ] && [ $res2 -eq 1 ];then
		return 0
	else
		return 1
	fi
}

function start_hadoop(){
	
	isDfsRunning && isYarnRunning
	if [ $? -eq 0 ];then
		return 0
	fi
	
	install_jdk
	install_hadoop
	hadoop_ssh_nopasswd
	hadoop_config_base
	hadoop_namenode_format
	hadoop_config_yarn
	
	start-dfs.sh
	
	start-yarn.sh
	
	isDfsRunning
	res1=$?
	isYarnRunning
	res2=$?
	if [ $res1 -eq 0 ] && [ $res2 -eq 0 ];then
		return 0
	else
		return 1
	fi
}
function hive_create_dir_on_hdfs() {
	hdfs dfs -test -e /tmp
	if [ $? ];then
		hdfs dfs -rm -f -r /tmp
	fi
	hdfs dfs -mkdir /tmp
	print_info $ "hive create tmp dir"

	hdfs dfs -test -e /user/hive/warehouse
	if [ $? ];then
		hdfs dfs -rm -f -r /user/hive/warehouse
		sleep 3
	fi
	hdfs dfs -mkdir -p /user/hive/warehouse	 
	print_info $?  'hive create /user/hive/warehouse'
	
	hdfs dfs -chmod g+w /tmp /user/hive/warehouse
	print_info $? "hive change work dir mod"	
 
}
