#!/bin/bash
set -x
cd ../../../../utils
    . ./sys_info.sh
    . ./sh-test-lib
cd -


MEMTESTER=`pwd`/memtester
FREEPERCENT=0.99
FREEPERCENT=0.9
LOGDIR=log

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi


#if [ ! -x ${MEMTESTER} ]; then
#	echo "runmemtester.sh: ${MEMTESTER} do not exist!"
#	exit -1
#fi

mkdir log >& /dev/null

total_memory=$(free -m | grep 'Mem' | awk '{print $4}')
thread_num=$(cat /proc/cpuinfo | sed -n '/processor/h; ${ x; p; }' | awk '{print $3}')
thread_num=$[ thread_num + 1 ]
each_memory=$(awk 'BEGIN{printf '$total_memory'*'${FREEPERCENT}'/'$thread_num'}')
each_memory=$(echo $each_memory | awk -F '.' '{print $1}')
if [ $? -ne 0 ]; then
	echo 'runmemtester.sh: Failed to compute each memory'
	exit -2
fi

echo "Thread NO.: $thread_num CPUs, Total Memory: $total_memory MB, Each Memory: $each_memory MB"

#for (( i=1; i<$thread_num; i++)); do
#{

	#${MEMTESTER} "$each_memory"m 1 1>${LOGDIR}/memtester"$i".log &
         ${MEMTESTER} "$each_memory"m 1 1>${LOGDIR}/memtester2.log
        
#}
#done

touch 1.txt
chmod 777 1.txt

pwd
#cat log/memtester2.log
#cat ${LOGDIR}/memtester2.log |grep "ok" | awk -F '    ' '{print $1}' > test.txt
cat log/memtester2.log > 1.txt 
cat ${LOGDIR}/memtester2.log |grep "ok" | awk -F '    ' '{print $1}' > 1.txt
#cat 1.txt

sed -i s/': ok'/''/g 1.txt

sed -i 's/  //g' 1.txt
sed -i 's/ /-/g' 1.txt


while read line
do
str=$line
print_info $? $str
done < 1.txt
wait
