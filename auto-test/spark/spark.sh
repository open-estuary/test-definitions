#!/bin/bash

#=================================================================
#   文件名称：spark.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2018年01月04日
#   描    述：
#
#================================================================*/

function spark_download(){
    
    yum install -y wget 
    if [ ! -d ~/bigdata/spark ];then
        mkdir -p ~/bigdata/spark
    fi 

    if [ -z $SPARKVERSION ];then
        SPARKVERSION="2.2.0"
    fi

    cd ~/bigdata/spark
        if [ ! -f spark-$SPARKVERSION-bin-hadoop2.7.tgz ];then
            wget -c http://mirror.bit.edu.cn/apache/spark/spark-$SPARKVERSION/spark-$SPARKVERSION-bin-hadoop2.7.tgz
        fi 
#        tar -zxf spark-$SPARKVERSION-bin-hadoop2.7.tgz

        if [ ! -f scala-2.12.4.tgz  ];then
            wget -c https://downloads.lightbend.com/scala/2.12.4/scala-2.12.4.tgz
        fi 
    cd -

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

    ansible-playbook -i ./spark/hosts ./spark/site.yml -t spark
    if [ $> -eq 0 ];then
        echo "---------------"
        echo "-----ERROR-----"
        echo "---------------"
    fi 
}

function spark_start_cluster(){

    ansible-playbook -i ./spark/hosts ./spark/site.yml -t start_cluster

    jps_cnt=`ansible -i ./spark/hosts all -m shell -a "jps" | grep -Ec "Worker|Master"`
    ansible -i ./spark/hosts --list-hosts all 

    
}
function spark_stop_cluster(){
    
    ansible_playbook -i ./spark/hosts ./spark/site.yml -t stop_cluster 
    jps_cnt=`ansible -i ./spark/hosts all -m shell -a "jps" | grep -Ec "Worker|Master"`
    if [ $jps_cnt -eq 0 ];then
        true
    else
        false
    fi 
    print_info $? "spark stop cluster"

}

function spark_RDD_test(){

    $SPARK_HOME/bin/pyspark --master spark://sparkmaster:7077 RDD_test.py 2>&1 | grep -vE "Warn|INFO" > out.tmp
    grep "rdd_test_parallelize" out.tmp && true || false 
    print_info $? "spark_rdd_parallelize_test"
    grep "rdd_test_file" out.tmp && true || false
    print_info $? "spark_rdd_file_test"

}

function spark_conf_test(){


}



