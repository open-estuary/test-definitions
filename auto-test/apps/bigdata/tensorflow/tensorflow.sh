#!/bin/bash

#set -x

cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

outDebugInfo
version=`python -V`
if [ $version > 2 && $version < 3 ];then
	print_info 0 python-version
else
	install_deps python
	python -V
	print_info $? python-version
fi


pkgs="tensorflow"
install_deps "${pkgs}"
print_info $? install-tensorflow

Check_Version "${pkgs}" "1.2.1"
print_info $? check-tf-version

Check_Repo "${pkgs}" "Estuary"
print_info $? check-repo

pkgs="python-pip python-devel gcc vim expect"
install_deps "${pkgs}"
print_info $? install-pip

pip install --upgrade pip
print_info $? upgrade-pip

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
pip remove tensorflow -y
print_info $? pip-remove-whl

pkgs="python-pip python-devel"
remove_deps "${pkgs}"
print_info $? remove-pip

remove_deps tensorflow
print_info $? remove-tensorflow
