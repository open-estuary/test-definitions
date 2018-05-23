#!/bin/bash

#=================================================================
#   文件名称：spark.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2018年01月04日
#   描    述：
#
#================================================================*/



function spark_download(){
	yum update -y    
    yum install -y wget ansible 
    yum install -y java-1.8.0-openjdk-devel  java-1.8.0-openjdk 
    

    if [ -z $SPARKVERSION ];then
        SPARKVERSION="2.2.0"
    fi

 	spark=/var/bigdata/spark
	rm -rf $spark
	mkdir -p $spark
    
    pushd $spark
        if [ ! -f spark-${SPARKVERSION}-bin-hadoop2.7.tgz ];then
	          wget -c -q  http://192.168.50.122:8083/test_dependents/spark-${SPARKVERSION}-bin-hadoop2.7.tgz
            ret=$?
            if [ $ret -ne 0 ];then 
                wget -c -q  http://mirror.bit.edu.cn/apache/spark/spark-${SPARKVERSION}/spark-${SPARKVERSION}-bin-hadoop2.7.tgz
                ret=$?
            fi 
        fi 
		mkdir spark
        tar -zxf spark-$SPARKVERSION-bin-hadoop2.7.tgz -C spark
		export SPARK_HOME=$spark/spark/spark-$SPARKVERSION-bin-hadoop2.7

        if [ ! -f scala-2.12.4.tgz  ];then
            wget -c -q http://192.168.50.122:8083/test_dependents/scala-2.12.4.tgz
            ret=$?
            if [ $ret -ne 0 ];then
                wget -c -q  https://downloads.lightbend.com/scala/2.12.4/scala-2.12.4.tgz
                ret=$?
            fi
        fi 
        if test -f spark-${SPARKVERSION}-bin-hadoop2.7.tgz
        then
            true
        else
            false
        fi
        print_info $? "download_spark_bin_file"
        test -f scala-2.12.4.tgz && true || false
        if [ $? -ne 0 ];then
            echo
            echo "download_scala_package_fail,please check network or url"
            echo 
        fi 
		mkdir scala
		tar -zxf scala-2.12.4.tgz -C scala
		export SCALA_HOME=$spark/scala/scala-2.12.4/
		export PATH=$PATH:$SPARK_HOME/bin/:$SPARK_HOME/sbin:$SCALA_HOME/bin
		echo $PATH
    popd 
}

function spark_login_no_passwd(){
    
    # 本机到hostfile中每一个主机都是无密码登录，且hostfile中主机相互之间也是免密登录
    ../../utils/sshpasswd-ex.sh all hostfile 
    # 过滤出ip和主机名
    echo "" > ./hosts.template
    for line in `cat hostfile`
    do 
        ip=`echo $line | cut -d : -f 1`
        hostnm=`echo $line | cut -d : -f 4`
        if [ ! -z $hostnm ];then
            echo "$ip $hostnm" >> ./hosts.template
        fi 
    done

    cp -f  ./hosts.template ./spark/roles/common/templates/hosts.template

}

function spark_slave_host(){

    local cnt=0

    # hostfile 中第一个默认为sparkmaster，其他ip为sparkslave主机
    for line in `cat hostfile`
    do 
        echo $line | grep "^#.*" && continue 
        echo $line | grep "^$" && continue 
        ip=`echo $line | cut -d : -f 1`
        user=`echo $line | cut -d : -f 2`
        pswd=`echo $line | cut -d : -f 3`
        hostnm=`echo $line | cut -d : -f 4`
        let cnt=$cnt+1
        if [ $cnt -eq 1 ];then
            echo "[sparkmaster]" > ./spark/hosts 
            echo $ip >> ./spark/hosts
            echo "" > slave 
            continue 
        fi 
        if [ $cnt -eq 2 ];then
            echo "[sparkslave]" >> ./spark/hosts 
        fi
        echo "$ip" >> ./spark/hosts 
        echo $ip >> slave
    done 

    if [ $cnt -le 1 ];then
        echo -----------------------------------
        echo '-------------warning-------------'
        echo "`pwd` directory hostfile host count <2"
        echo -----------------------------------
    fi 
    diff slave ./spark/roles/common/files/slaves 2>&1 >/dev/null 
    if [ $? -ne 0 ];then
        /usr/bin/cp -f slave ./spark/roles/common/files/slaves 
    fi 

}

function spark_deploy_cluster(){
echo `pwd`
    ansible-playbook -i ./spark/hosts ./spark/site.yml -t spark
    ret=$?
    if [ $ret -eq 0 ];then
        true
    else
        false
    fi 
    print_info $? "spark_deploy_cluster"
    if [ $ret -ne 0 ];then
        echo "---------------"
        echo "-----ERROR-----"
        echo "---------------"
        exit 1
    fi 
    source ~/.bashrc 
}

function spark_start_cluster(){

#    ansible-playbook -i ./spark/hosts ./spark/site.yml -t start_cluster
	$SPARK_HOME/sbin/start-all.sh

#    jps_cnt=`ansible -i ./spark/hosts all -m shell -a "jps" | grep -Ec "Worker|Master"`
    jps_cnt=`jps | grep -Ec "Worker|Master"`
    if [ $jps_cnt = 2 ];then
        true
    else
        false
    fi 

    print_info $? "spark_start_cluster"
    
}

function spark_stop_cluster(){
    
#    ansible-playbook -i ./spark/hosts ./spark/site.yml -t stop_cluster 
	$SPARK_HOME/sbin/stop-all.sh
    #jps_cnt=`ansible -i ./spark/hosts all -m shell -a "jps" | grep -Ec "Worker|Master"`
	jps_cnt=`jps | grep -Ec "Worker|Master"`
   	if [ $jps_cnt -eq 0 ];then
        true
    else
        false
    fi 
    print_info $? "spark_stop_cluster"

}

function spark_SparkContext_test(){

    $SPARK_HOME/bin/spark-submit ./addfile.py 2>&1 | egrep -vi "warn|info" | grep "addfile_test_ok"
    if [ $? -eq 0 ];then
        true
    else
        false
    fi 
    print_info $? "sparkcontext_addfile_function_test"

    $SPARK_HOME/bin/spark-submit ./cancelJobGroup.py 2>&1 | egrep -vi "warn|info" | grep "cancelJobGroup_test_ok"
    if [ $? -eq 0 ];then
        true
    else
        false
    fi 
    print_info $? "sparkcontext_cancelJobGroup_function_test"



    $SPARK_HOME/bin/spark-submit ./wholeTextFiles.py 2>&1 | egrep -vi "warn|info" | grep "wholeTextFiles_test_ok"
    if [ $? -eq 0 ];then
        true
    else
        false
    fi 
    print_info $? "sparkcontext_wholeTextFiles_function_test"

}

function spark_RDD_test(){
    
    
    $SPARK_HOME/bin/spark-submit ./RDD_test.py 2>&1 | egrep -vi "warn|info" > out.tmp
    list='''ggregate
    cartesian
    glom
    coalesce
    cogroup
    collectAsMap
    combineByKey
    countByKey
    countByValue
    distinct
    filter
    first
    flatMap
    fold
    foldByKey
    getNumPartitions
    groupBy
    groupByKey
    groupWith
    intersection
    keyBy
    keys
    map
    mapPartitions
    mapValues
    partitionBy
    reduce
    reduceByKey
    repartition
    sortBy
    take
    zip
    '''
    for word in $list 
    do 
        grep "${word}_test_ok" out.tmp
        if [ $? -eq 0 ];then
            true
        else
            false
        fi 
        print_info $? "sparkcontext_${word}_function_test"
    done 

}


function spark_sql_test(){


    $SPARK_HOME/bin/spark-submit ./RDD_test.py 2>&1 | egrep -vi "warn|info" > out.tmp
    list='''SparkSession
    createDataFrameFromList
    createDataFrameFromRDD
    createDataFrameListSchema
    createDataFrameUseRowSchema
    createDataFrameUseStructType
    range
    registerFunction'''

    for word in $list
    do 
        grep "${word}_test_ok" out.tmp
        if [ $? -eq 0 ];then
            true
        else
            false
        fi 
        print_info $? "spark_sql_${word}_function_test"

    done 


}
