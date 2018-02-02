#!/bin/bash

if [ -z "${1}" ] ; then
    echo "Usage: ./run_client.sh <server ip (not local ip address)>"
    exit 0  
fi
ip=${1}

#Notes: Userid and passwd have been specified in scripts/init_client.sh

./setup.sh client


if [ `which sysbench;echo $? = 0 `  ];then
    lava-test-case alisql-sysbench_install --result pass
else
    lava-test-case alisql-sysbench_install --result fail
fi


#Start to initialize 200 mysql instances
./scripts/init_client.sh ${ip} init 1 
