#!/bin/bash


function check_release()
{
    cat /etc/os-release
    uname -a
    dmidecode --type processor |grep Version
}


function check_resultes()
{
    result_file=$1
    #PRINT_FILE_TO_LOG "${result_file}"
    for line in `tail -n +1 ${result_file} |awk '!a[$0]++'`
    do
        if [[ "$line" =~ "=pass"  ]];then
            echo -e "\033[32m${line}\033[0m"
        else
            echo -e "\033[31m${line}\033[0m"
        fi
    done

    ret1=`cat ${result_file} |grep "=pass" |awk '!a[$0]++' |wc -l`
    ret2=`cat ${result_file} |grep "=fail" |awk '!a[$0]++' |wc -l`
    tail -n +1 ${result_file} | awk -F "=" '{print $2}' | egrep -v "pass" > /dev/null
    if [ $? -eq 0 ]
	then
		echo -e "\033[31m FATAL Test case $ret1 is pass,$ret2 is fail, <${test_name}>  is fail ,please check it ! \033[0m"
		return 1
	else
		echo -e "\033[32m Test case  $ret1 is pass,$ret2 is fail,<${test_name}> is success.\033[0m "
		return 0
	fi

}


function check_server()
{
    server=$1
    ${server} &   
    count=$(ps -ef | grep ${server} | grep -v "grep"| wc -l)
    if [ ${count} -gt 0 ];
    then
        echo "start-${server}-server pass"
		return 0
    else
        echo "start-${server}-server failed"
		return 1
    fi
}


function add_json()
{
	addjson=$1   
	os_version=`cat /etc/os-release |grep PRETTY_NAME |awk -F "=" '{print $2}'`
	kernel_version=`uname -r`
	hostname=`hostname`
	page_value=`getconf PAGE_SIZE`
	hz_value=`cat /boot/config-${kernel_version} | grep '^CONFIG_HZ=' |awk -F "=" '{print $2}'`
	name=$(dmidecode -t system|grep -i "product name"|awk -F: '{gsub(/^[ \t]/,"",$2);print $2}')
	version=$(dmidecode -t system|grep -i "version"|awk -F: '{gsub(/^[ \t]/,"",$2);print $2}')
	cpu_type=$(dmidecode -t processor|grep -i version|head -1|awk -F: '{gsub(/^[ \t]/,"",$2);print $2}')
	cpu_speed=$(dmidecode -t processor|grep -i "Current Speed"|head -1|awk -F: '{gsub(/^[ \t]/,"",$2);print $2}')
	enabledcore=$(lscpu|grep -i "On-line cpu"|awk -F: '{gsub(/^[ \t]+/,"",$2);print $2}')
	memtypes=$(lshw -short|grep memory|grep DIMM|grep -v empty|awk '{print $3}'|sort|uniq)
	tmp_num=0
	
	for mem in $memtypes
	do
		tmp_num=$((tmp_num+1))
		num_type=$(lshw -short|grep memory|sort|grep DIMM|grep -v empty|grep $mem|wc -l)
		devicestr=${num_type}*${mem}
		if [ $tmp_num -eq 1 ];then
			target=${devicestr}
		fi
		if [ $tmp_num -gt 2 -o $tmp_num -eq 2 ];then
			target+=';'$devicestr
		fi
	done

	totalmem=$target
	memspeed=$(dmidecode -t memory|grep -i "Clock Speed"|head -1|awk -F: '{gsub(/^[ \t]+/,"",$2);print $2}')
	testpath=$(pwd)

	storedevices=$(lsblk|grep -v part|grep -v lvm|grep -v loop|grep -v NAME|awk '{print $1}')
	storedevice=$(echo $storedevices|awk -F: 'gsub(/[ \t]/,";",$1)')
	filesystem=$(basename $(df -Th $(pwd)|tail -1|awk '{print $2}'))
	storetypes=$(lshw -short|grep disk|awk '{print $5}'|sort|uniq)
	tmp_num=0
	
	for sto in $storetypes
	do
		tmp_num=$((tmp_num+1))
		num_type=$(lshw -short|grep disk|awk '{print $5}'|grep $sto|wc -l)
		devicestr=${num_type}*${sto}
		if [ $tmp_num -eq 1 ];then
			target=${devicestr}
		fi
		if [ $tmp_num -gt 2 -o $tmp_num -eq 2 ];then
			target+=';'$devicestr
		fi
	done    
	storetype=$target
	netports=$(lshw -short |grep network|grep -v docker|grep -v virt|grep -v br0|grep -v bond|awk '{print $2}')
	netinter=$(echo $netports|awk -F: 'gsub(/[ \t]/,";",$1)')
	tmp_num=0
	for netp in $netports
	do
		tmp_num=$((tmp_num+1))
		nettypestr=$(dmesg | grep -i eth | grep $netp |awk '{print $3}')
		if [ $tmp_num -eq 1 ];then
			targetnetstr=${nettypestr}
		fi
		if [ $tmp_num -gt 2 -o $tmp_num -eq 2 ];then
			targetnetstr+=';'${nettypestr}
		fi
	done

	netinfo_interface=$netinter    
	netinfo_driver_tmp=`readlink /sys/class/net/$netinter/device/driver/module`
	netinfo_driver=`basename $netinfo_driver_tmp`
	nettype=$targetnetstr 
	tmp_num=0
	for netp in $netports
	do
		tmp_num=$((tmp_num+1))
		nettypestr=$(ethtool $netp|grep -i speed|awk -F: '{gsub(/^[ \t]+/,"",$2);print $2}')
		if [ $tmp_num -eq 1 ];then
			targetnetstr=${nettypestr}
		fi
		if [ $tmp_num -gt 2 -o $tmp_num -eq 2 ];then
			targetnetstr+=';'${nettypestr}
		fi
	done
	netband=$targetnetstr

	sed -i '$a\,' ${addjson}
	sed -i '1 i\testresult:' ${addjson}
	sed -i '1 i\{' ${addjson}
	echo "\"boardinfo\":{\"name\" : \"$name\",\"version\" : \"$version\",\"boardalias\" : \"d\",\"cpu_type\" : \"$cpu_type\",\"cpu_speed\" : \"$cpu_speed\",\"enabledcore\" : \"$enabledcore\",\"totalmem\" : \"$totalmem\",\"memspeed\" : \"$memspeed\",\"testpath\" : \"$testpath\",\"storedevice\" : \"$storedevice\",\"filesystem\" : \"$filesystem\",\"storetype\" : \"$storetype\",\"netinter\" : \"$netinter\",\"nettype\" : \"$nettype\",\"netband\" : \"$netband\",\"bmc_ver\" : \"null\",\"cpld_ver\" : \"null\",\"bios_ver\" : \"null\"}, " >> ${addjson}
	echo "\"biosinfo\":{\"smmu_state\":\"no-need\",\"turbo_state\":\"no-need\"}, " >> ${addjson}
	echo "\"kernel\":{\"kernel version\":\"${kernel_version}\",\"stream_state\":\"no-need\",\"prefetch_state\":\"no-need\",\"hha state\":\"no-need\"}, " >> ${addjson}
	echo "\"os\":{\"os_version\":${os_version},\"hostname\":\"${hostname}\",\"compiler_name\":\"default\",\"compiler_ver\":\"default\",\"thp_state\":\"default\",\"page_value\":\"${page_value}\",\"hz_value\":\"${hz_value}\"},\"glibc_version\":\"default\" " >> ${addjson}
	sed -i '$a\}' ${addjson}
}