#!/bin/bash

#=================================================================
#   文件名称：setupSparkRunningEnv.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2018年01月05日
#   描    述：
#
#================================================================*/

function setupJDK(){

    dir=`which java`
    path=`readlink -f $dir`
    path=`dirname \`dirname $path\``
    path=`dirname $path`
    grep JAVA_HOME ~/.bashrc 
    if [ $? -eq 0 ];then
        sed -i '/JAVA_HOME/'d ~/.bashrc 
    fi 
    echo "export JAVA_HOME=$path" >> ~/.bashrc 
    echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc 

    
}

function setupScala(){
    
    grep SCALA_HOME ~/.bashrc 
    if [ $? -eq 0 ];then
        sed -i '/SCALA_HOME/'d ~/.bashrc 
    fi 
    echo "export SCALA_HOME=/var/bigdata/scala/ " >> ~/.bashrc 
    echo 'export PATH=$PATH:$SCALA_HOME/bin' >> ~/.bashrc 

}

function setupSpark(){

    grep SPARK_HOME ~/.bashrc 
    if [ $? -eq 0 ];then
        sed -i '/SPARK_HOME/'d ~/.bashrc 
    fi 
    echo "export SPARK_HOME=/var/bigdata/spark" >> ~/.bashrc 
    
}


if [ $1 = "all" ];then
    setupJDK
    setupScala
    setupSpark 
else if [ $1 = "JDK" ];then
    setupJDK
else if [ $1 = 'scala' ];then
    setupScala
else if [ $1 = "spark" ];then
    setupSpark
else
    echo "usage: $0 [all | JDK | scala ]"
    exit 1
fi 


