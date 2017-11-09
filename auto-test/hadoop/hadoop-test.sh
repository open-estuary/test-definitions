#! /bin/bash
set -x
export PS4='+{$LINENO:${FUNCNAME[0]}} '

basedir=$(cd `dirname $0`;pwd)
cd $basedir
source ./hadoop.sh

install_jdk
install_hadoop

hadoop_standalone

hadoop_ssh_nopasswd
hadoop_config_base
hadoop_namenode_format

hadoop_single_node

hadoop_config_yarn
hadoop_single_with_yarn




