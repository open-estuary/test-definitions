#!/bin/bash

set -x

cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

version=`python -V`
if [ $version > 2 && $version < 3 ];then
	print_info 0 python-version
else
	pkgs="python expect"
	install_deps "${pkgs}"
	print_info $? install-python
	python -V
	print_info $? python-version
fi

# 交互性使用python
EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn python
expect ">>>"
send "print 'hello,world'\r"
expect "hello,world"
send "exit()\r"
expect eof
EOF
print_info $? python-interactive

# 测试python编译py脚本
cat > ./test.py << EOF
print "Hello, Python!";
EOF
python test.py | grep "Hello, Python!"
print_info $? python-script-type1
rm -f test.py

cd ./basic

# 测试py脚本直接运行
./test.py | grep "Hello, Python!"
print_info $? python-script-type2

# 测试if
./if.py | tee out.log
if [ $? || `cat out.log | grep 'error'` ];then
	print_info 1 python-if
else
	print_info 0 python-if

# 测试while循环
./while.py | tee out.log
if [ $? || `cat out.log | grep 'error'` ];then
	print_info 1 python-while
else
	print_info 0 python-while

# 测试for循环
./for.py | tee out.log
if [ $? || `cat out.log | grep 'error'` ];then
	print_info 1 python-for
else
	print_info 0 python-for

# 测试pass语句块
./pass.py
print_info $? python-pass

# 测试字符串
./string.py
print_info $? python-string

# 测试列表
./list.py
print_info $? python-list

# 测试元组
./tuple.py
print_info $? python-tuple

# 测试字典功能
./dictionary.py
print_info $? python-dictionary

# 测试日期与时间
./date.py
print_info $? python-date

# 测试函数功能
./function.py
print_info $? python-function

# 测试导入模块功能
./module.py
print_info $? python-module

# 测试python输入输出
EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn ./io.py
expect "请输入："
send "hello\r"
expect "请输入："
send "\[x*5 for x in range\(2,10,2\)\]\r"
expect eof
EOF
print_info $? python-io

# 测试文件读写
./file.py
print_info $? python-file

# 测试异常报错
./exception.py
print_info $? python-exception

rm -f out.log

cd ..

# 测试高级功能
cd ./advanced

# 测试对象
./object.py
print_info $? python-object

# 测试正则表达式
./re.py
print_info $? python-re

# 测试网络编程
./pyserver.py &
print_info $? python-socket-server

./client.py | grep 'welcome'
count=`ps -aux | grep pyserver | wc -l`
if [ $count -gt 0 ];then
    kill -9 $(pidof pyserver)
	print_info $? kill-pyserver
fi

# 测试多线程编程
./thread.py
print_info $? python-thread

# 测试python解析xml
./xml.py
print_info $? python-xml

# 测试python解析json
./json.py
print_info $? python-json

cd ..

pkgs="python expect"
remove_deps "${pkgs}"
print_info $? remove-python

