#!/bin/bash 
set -x
cd ../../../../utils
. ./sh-test-lib
. ./sys_info.sh
cd -


IOENGINE="sync"
BLOCK_SIZE="4k"


if [ `whoami` != "root" ];then
	echo "YOu must be the root to run this script" >$2
	exit 1
fi


#install the packgs
pkgs="fio"
install_deps "${pkgs}"
print_info $? install_pkgs


fio_test() {
    local rw="$1"
    file="fio-${BLOCK_SIZE}-${rw}.txt"
    
    # Run fio test.
    fio -name="${rw}" -rw="${rw}" -bs="${BLOCK_SIZE}" -size=1G -runtime=60 \
        -numjobs=1 -ioengine="${IOENGINE}" -direct=1 -group_reporting  -output="${file}"
    print_info $? fio_test_${rw}
    

    # Parse output.
    IOPS=`cat "${file}"|grep -m 1 "iops" "${file}" | cut -d= -f4 | cut -d, -f1`
    if [ "$IOPS"x != ""x ];then
	 print_info 0 info_fio_test_${rw}
    else
	 print_info 0 info_fio_test_${rw}
    fi
    # Delete files created by fio to avoid out of space.
    rm -rf ${file}
    rm -rf "${rw}"*
    
}



#  run fio test.
for rw in read randread write randwrite rw randrw; do
    fio_test "${rw}"
done

#Remove fio package
remove_deps "${pkgs}"
print_info $? remove

