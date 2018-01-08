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
        tar -zxf spark-$SPARKVERSION-bin-hadoop2.7.tgz

        if [ ! -f scala-2.12.4.rpm ];then
            wget -c https://downloads.lightbend.com/scala/2.12.4/scala-2.12.4.tgz
        fi 
    cd -

}



