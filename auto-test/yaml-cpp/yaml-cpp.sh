#!/bin/sh
# Copyright (C) 2017-8-29, Linaro Limited.
#qperf is a tool for testing bandwidth and latency
# Author: mahongxin <hongxin_228@163.com>

set -x

cd ../../utils
    . ./sys_info.sh
cd -

# Test user id
if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
case $distro in
    "centos")
         wget http://htsat.vicp.cc:804/yaml-cpp-yaml-cpp-0.5.3.tar.gz
         tar -zxvf yaml-cpp-yaml-cpp-0.5.3.tar.gz
         yum install cmake* -y
         yum install boost* -y
         cd yaml-cpp-yaml-cpp-0.5.3
         cmake -DBUILD_SHARED_LIBS=ON
         make
         ;;
esac
mkdir test3
cd test3
cp ../include/yaml-cpp/yaml.h ./
cp -rf ../include/yaml-cpp/ /usr/include/
#把测试文件test.cpp cmd_mux.yaml放到test3文件夹里面
#cp ../test.cpp ./
#cp ../cmd_mux.yaml ./
cat << EOF >> ./test.cpp
    #include <iostream>
    #include <fstream>
    #include <string>
    #include "yaml.h"

    using namespace std;

    //最新的yaml-cpp 0.5取消了运算符">>"，但是还是会有好多的旧代码
    //依旧在使用，所以重载下">>"运算符
    template<typename T>
    void operator >> (const YAML::Node& node, T& i)
    {
      i = node.as<T>();
    }

    void configure(const YAML::Node& node);
    void nodePrint(const YAML::Node& node);

    int main()
    {
      YAML::Node config = YAML::LoadFile("../cmd_mux.yaml");

      configure(config["subscribers"]);

      return 0;
    }

    void configure(const YAML::Node& node)
    {
      for (unsigned int i = 0; i < node.size(); i++)
      {
        nodePrint(node[i]);
      }
    }

    void nodePrint(const YAML::Node& node)
    {
      string name;
      string topic;
      double timeout;
      unsigned int priority;

      node["name"]       >> name;
      node["topic"]      >> topic;
      node["timeout"]    >> timeout;
      node["priority"]   >> priority;

      cout<<"    name: "<<name<<endl;
      cout<<"   topic: "<<topic<<endl;
      cout<<" timeout: "<<timeout<<" seconds."<<endl;
      cout<<"priority: "<<priority<<endl;
    }
EOF
cat << EOF >> ../cmd_mux.yaml
subscribers:
  - name:        "Default task"
    topic:       "input/cmd_default_check"
    timeout:     0.5
    priority:    1
    short_desc:  "Default controller"
  - name:        "Navigation stack"
    topic:       "input/cmd_serial_navi"
    timeout:     1.0
    priority:    3
    short_desc:  "Navigation controller"
publisher:       "output/cmd_vel"
EOF
sed -i '$a\/usr/local/lib' /etc/ld.so.conf
cd /etc
ldconfig
cd /root/test-definitions/auto-test/yaml-cpp/yaml-cpp-yaml-cpp-0.5.3
cp libyaml-cpp.so /usr/lib/
cd /usr/lib
ln -s libyaml-cpp.so libyaml-cpp.so.0.5
cd /root/test-definitions/auto-test/yaml-cpp/yaml-cpp-yaml-cpp-0.5.3/test3
g++ -g -o test test.cpp -I ../include/ ../libyaml-cpp.so
./test 2>&1 |tee yaml-cpp.log
TCID="yaml-cpp-test"
str=`grep -Po "name: Default task" yaml-cpp.log`
if [ "$str" != "" ];then
    lava-test-case $TCID --result pass
else
    lava-test-case $TCID --result fail
fi
