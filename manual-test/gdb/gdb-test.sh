#!/bin/bash

#================================================================
#   Copyright (C) 2017 tanliqing Ltd. All rights reserved.
#   
#   文件名称：test.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月22日
#   描    述：
#
#================================================================

function install_gdb(){

    yum install -y gcc gdb

}


function exec_gdb(){

    gcc -g test.c -o test 
    gdb test 


}

install_gdb 
exec_gdb
