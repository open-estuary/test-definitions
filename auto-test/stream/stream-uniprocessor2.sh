#!/bin/bash 

# author:tanliqing2012@163.com
# time  :2017.10.17

basepath=$(cd `dirname $0`; pwd)
cd $basepath

. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
TEST_LOG="${OUTPUT}/stream-output.txt"

create_out_dir "${OUTPUT}"

# Run Test.
detect_abi
# shellcheck disable=SC2154

if [ $# -eq 1  ];then
    repeat=$1
else
    repeat=10 
fi

# centos has not per install bc command
install_deps "bc"



# get system argment
memCountKB=`cat /proc/meminfo  |grep MemTotal | cut -d ":" -f2|tr -d "a-z" | awk {'print $1'}`
memCountGB=`echo "scale=2;$memCountKB / 1024 / 1024" | bc `
memCountGB=`echo $((${memCountGB//.*/+1}))`

# count chips count
currChipsNum=`dmidecode -t memory | grep  -A5 Memory | grep Size | grep -v No| cut -d : -f2|tr -d A-Z|wc -l`
chipType=`dmidecode -t memory | grep "Type: DD" | grep -v Unknown| head -n 1 | awk {'print $2'}`
chipManufacturer=`dmidecode -t memory | grep Manufacturer | grep -v NO|head -n 1| awk {'print $2'}`
chipSpeed=`dmidecode -t memory | grep "Speed" | grep -v Unknown|grep -v Clock|awk {'print $2'}|head -n 1`

biosVersion=`dmidecode -t bios|grep Version|cut -d : -f 2`
biosDate=`dmidecode -t bios|grep "Release Date"|cut -d : -f 2`

declare -A speedMap=()
declare -A stdevMap=()

speedMap["Copy"]=98103.49
speedMap["Scale"]=98127.90
speedMap["Add"]=99356.54
speedMap["Triad"]=99463.96
speedMap["Fill"]=99463.96
speedMap["Copy2"]=99463.96
speedMap["Daxpy"]=99463.96
speedMap["Sum"]=99463.96

stdevMap["Copy"]=0.62
stdevMap["Scale"]=0.74
stdevMap["Add"]=0.27
stdevMap["Triad"]=0.15
stdevMap["Fill"]=0.15
stdevMap["Copy2"]=0.15
stdevMap["Daxpy"]=0.15
stdevMap["Sum"]=0.15

echo "-----------------------------------------------------------------"
echo "Memory_Count= $memCountGB, Chips_Count= $currChipsNum" | tee $TEST_LOG
echo "chipType=$chipType , chipManufacturer=$chipManufacturer , chipSpeed=$chipSpeed" | tee -a $TEST_LOG
echo "biosVersion=$biosVersion , biosDate=$biosDate" | tee -a $TEST_LOG 
echo ""

install_deps gcc 
install_deps make
install_deps numactl

numaNode=`lscpu | grep "NUMA node(s)" | awk '{print $3}'`
if [ $numaNode -lt 4  ];then
	echo "Now system Numa node dose not meet requirement!!!!"
	lava-test-case STREAM-NUMA --result fail
	exit
fi


mkdir -p stream-test
cd stream-test
./stream-build.sh
echo "build stream finished ---------------------------------"
./stream-test.sh 2>&1 | tee stream-result.txt 
echo "run stream finished -----------------------------------"
cd ..

if [ $? = 0  ];then
    lava-test-case STREAM-Execute --result pass
else
    lava-test-case STREAM-Execute --result fail
fi

./pick.sh ./stream-test/stream-result.txt > result.txt

echo "pick data finished ------------------------------------"

if [ $currChipsNum -ne 8 ];then
    echo "Now system Memory Count does not meet quantity requirements!!!!!!"
    # exit;
elif [ $memCountGB -lt 128 ] ;then
    echo "Now system Memory summory dose not meet quantity requirements!!!!!!!"
    # exit;
fi


# define a map variable
declare -A  map=()
map[Copy]=1
map[Scale]=2
map[Add]=3
map[Triad]=4
map[Fill]=5
map[Copy2]=6
map[Daxpy]=7
map[Sum]=8


for case in Copy Scale Add Triad Fill Copy2 Daxpy Sum;do
   # ret=`grep "^$case" "$TEST_LOG" | awk {'print $2'}`
   var=`echo ${map[$case]}`
#   ret=`cat result.txt | awk -v var=`echo ${map[$case]}` {'if(NR>1) print $var'} ` 
	ret=`cat result.txt | cut -d " " -f $var | tr -d [:alpha:]`	 
	sum=0.0
    count=0
    
    for i in $ret 
    do
        sum=`echo "$i + $sum" | bc`
        let count=count+1
    done

    avg=`echo "scale=5 ; $sum / $count" | bc`
    s2=0.0
    
    for i in $ret
    do
        s2=`echo "$s2 + ($i -$avg) * ($i -$avg)" | bc`
    done
    s2=`echo "scale=5 ; sqrt($s2/$count)/$avg *100" | bc`
    echo testcase-${case}-${s2}%


    if [ `echo "$avg < ${speedMap[$case]}" | bc ` -eq 1   ];then
        echo tasecase-speed-${case}-pass
    else
        echo testcase-speed-${case}-fail
    fi
    
    if [ `echo "$s2 < ${stdevMap[$case]}" | bc ` -eq 1 ];then
        echo testcase-stdev-${case}-pass
    else
        echo testcase-stdev-${case}-fail
    fi


done
