#!/bin/bash
#Aurthor: liucaili
set -x

#加载外部环境
cd ../../../../utils
source ./sys_info.sh
source ./sh-test-lib
cd -

#检查用户权限
! check_root && error_msg "Please run this script as root."

#检查python版本信息
outDebugInfo
version=`python -V`
if [ $version > 2 && $version < 3 ];then
	print_info 0 python-version
else
	install_deps "python"
	python -V
	print_info $? python-version
fi

#环境准备
case $distro in
    "centos")
    pkgs="tensorflow wget python-pip python-devel gcc vim expect"
#    Check_Repo "${pkgs}" "Estuary"
#    print_info $? check-repo
    install_deps "${pkgs}"
    print_info $? install-tensorflow
    ;;
    "ubuntu"|"debian")
    pkgs="wget python-pip python-dev gcc vim expect"
    install_deps "$pkgs"
    sleep 18m
    mkdir -p /usr/share/tensorflow
    wget $ci_http_addr/test_dependents/tensorflow-1.2.1-cp27-none-linux_aarch64.whl /usr/share/tensorflow
    print_info $? install-tensorflow
    ;;
    "fedora"|"opensuse")
    pkgs="wget python-pip python-devel gcc vim expect"
    install_deps "$pkgs"
    sleep 18m
    mkdir -p /usr/share/tensorflow
    wget $ci_http_addr/test_dependents/tensorflow-1.2.1-cp27-none-linux_aarch64.whl /usr/share/tensorflow
    print_info $? install-tensorflow
    ;;
esac

#更新pip
pip install --upgrade pip
print_info $? upgrade-pip

#安装tensorflow
whl=`ls /usr/share/tensorflow`
cd /usr/share/tensorflow
pip install $whl
print_info $? pip-install-whl

#hello to check pip install tensorflow
cd -
EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn python
expect ">>>"
send "import tensorflow as tf\r"
expect ">>>"
send "hello = tf.constant('Hello, TensorFlow!')\r"
expect ">>>"
send "sess = tf.Session()\r"
expect ">>>"
send "print sess.run(hello)\r"
expect "Hello, TensorFlow!"
send "exit()\r"
expect eof
EOF
print_info $? tf-hello

#input & output
python ./op.py
print_info $? tf-op

#session object to make Graph
python ./chart.py
print_info $? tf-session-chart

#variable
python ./var.py
print_info $? tf-variables

#fetch back results
python ./fetch.py
print_info $? tf-fetch

#feed variable value
python ./feed.py
print_info $? tf-feed

#save model
python ./save_model.py
print_info $? tf-save-model

#load model
python ./load_model.py
print_info $? tf-load-model

cd /usr/share/tensorflow
pip uninstall tensorflow -y
print_info $? pip-remove-whl

#环境复原
case $distro in
    "centos")
    pkgs="tensorflow wget python-pip python-devel gcc vim expect"
    remove_deps "${pkgs}"
    print_info $? remove-pkgs
    ;;
    "ubuntu"|"debian")
    pkgs="wget python-pip python-dev gcc vim expect"
    remove_deps "$pkgs"
    print_info $? remove-tensorflow
    rm -rf /usr/share/tensorflow
    "fedora"|"opensuse")
    pkgs="wget python-pip python-devel gcc vim expect"
    rm -rf /usr/share/tensorflow
    remove_deps "$pkgs"
    print_info $? remove-tensorflow
    ;;
esac
