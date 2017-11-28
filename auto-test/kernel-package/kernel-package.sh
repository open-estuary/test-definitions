#!/bin/bash

. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
package_list=""
dist_name
! check_root && error_msg "This script must be run as root"
create_out_dir "${OUTPUT}"
case "${dist}" in
    debian)
        package_list="libcpupower1 libcpupower-dev libusbip-dev linux-cpupower linux-estuary-doc linux-estuary-perf  linux-estuary-source linux-headers-4.12.0-500-all linux-headers-4.12.0-500-all-arm64 linux-headers-4.12.0-500-arm64 linux-headers-4.12.0-500-common linux-headers-estuary-arm64 linux-kbuild-4.12 linux-libc-dev linux-perf-4.12 linux-source-4.12 linux-support-4.12.0-500 usbip"
        for p in ${package_list};do
            echo "$p install"
            apt-get install -y $p
            status=$?
            if test $status -eq 0
            then
                echo "$p install  [PASS]" | tee -a ${RESULT_FILE}
            else
                echo "$p install [FAIL]"  | tee -a ${RESULT_FILE}
            fi
            echo "$p remove"
            apt-get remove -y $p
            status=$?
            if test $status -eq 0
            then
                echo "$p remove  [PASS]" | tee -a ${RESULT_FILE}
            else
                echo "$p remove [FAIL]"  | tee -a ${RESULT_FILE}
            fi
        done
        ;;
    centos)
        version="4.12.0"
        release="estuary.2"
        from_repo="Estuary"
        package_list="kernel-devel kernel-headers kernel-tools kernel-tools-libs kernel-tools-libs-devel perf python-perf  kernel-debug kernel-debug-debuginfo kernel-debug-devel kernel-debuginfo kernel-debuginfo-common-aarch64 kernel-tools-debuginfo perf-debuginfo python-perf-debuginfo"
        for p in ${package_list};do
            echo "$p install"
            yum install -y $p
            status=$?
            rmflag=0
            if test $status -eq 0
            then
                echo "$p install  [PASS]" | tee -a ${RESULT_FILE}
                from=$(yum info $p | grep "From repo" | awk '{print $4}')
                if [ "$from" = "$from_repo" ];then
                    #echo "$p install  [PASS]" | tee -a ${RESULT_FILE}
                    echo "$p source is $from : [PASS]" | tee -a ${RESULT_FILE}
                else
                    #已经安装，但是安装源不是estuary的情况需要卸载重新安装
                    rmflag=1
                    if [ "$from" != "anaconda" ];then
                        yum remove -y $p
                        yum install -y $p
                        from=$(yum info $p | grep "From repo" | awk '{print $4}')
                        if [ "$from" = "$from_repo" ];then
                            echo "$p install  [PASS]" | tee -a ${RESULT_FILE}
                        else
                            echo "$p source is $from : [FAILED]" | tee -a ${RESULT_FILE}
                        fi
                    fi
                fi

                vs=$(yum info $p | grep Version | awk '{print $3}')
                if [ "$vs" = "$version" ];then
                    echo "$p version is $vs : [PASS]" | tee -a ${RESULT_FILE}
                else
                    echo "$p version is $vs : [FAILED]" | tee -a ${RESULT_FILE}
                fi

                rs=$(yum info $p | grep Release | awk '{print $3}')
                if [ "$rs" = "$release" ];then
                    echo "$p release is $rs : [PASS]" | tee -a ${RESULT_FILE}
                else
                    echo "$p release is $rs : [FAILED]" | tee -a ${RESULTFILE}
                fi
                #对于自带的包不去做卸载处理
                if test $rmflag -eq 0
                then
                    yum remove -y $p
                    status=$?
                    if test $status -eq 0
                    then
                        echo "$p remove  [PASS]" | tee -a ${RESULT_FILE}
                    else
                        echo "$p remove [FAIL]"  | tee -a ${RESULT_FILE}
                    fi
                else
                    echo "$p don't remove" | tee -a ${RESULT_FILE}
                fi
            else
                echo "$p install [FAIL]"  | tee -a ${RESULT_FILE}
            fi
        done
        ;;
    ubuntu) 
        package_list= "linux-estuary linux-headers-estuary linux-image-estuary linux-source-estuary linux-tools-estuary linux-cloud-tools-common linux-doc linux-headers-4.12.0-501 linux-headers-4.12.0-501-generic linux-image-4.12.0-501-generic linux-image-extra-4.12.0-501-generic linux-libc-dev linux-source-4.12.0 linux-tools-4.12.0-501 linux-tools-4.12.0-501-generic linux-tools-common"
        for p in ${package_list};do
            echo "$p install"
            apt-get install -y $p
            status=$?
            from_repo1='linux-meta-estuary'
            from_repo2='linux'
            version1='4.12.0.501.2'
            version2='4.12.0-501.estuary'
            if test $status -eq 0
            then
                echo "$p install  [PASS]" | tee -a ${RESULT_FILE}
                from=$(apt show $p | grep "^Source" | awk '{print $2}')
                if [ "$from" = "$from_repo1" -o "$from" = "$from_repo2" ];then
                    #echo "$p install  [PASS]" | tee -a ${RESULT_FILE}
                    echo "$p source is $from : [PASS]" | tee -a ${RESULT_FILE}
                else
                    #已经安装，但是安装源不是estuary的情况需要卸载重新安装
                    rmflag=1
                    echo "$p already installed,source is: $from " | tee -a ${RESULT_FILE}
                fi

                vs=$(apt show $p | grep "^Version" | awk '{print $2}')
                if [ "$vs" = "$version1" -o "$vs" = "$version2" ];then
                    echo "$p version is $vs : [PASS]" | tee -a ${RESULT_FILE}
                else
                    echo "$p version is $vs : [FAILED]" | tee -a ${RESULT_FILE}
                fi

            else
                echo "$p install [FAIL]"  | tee -a ${RESULT_FILE}
            fi
            echo "$p remove"
            apt-get remove -y $p
            status=$?
            if test $status -eq 0
            then
                echo "$p remove  [PASS]" | tee -a ${RESULT_FILE}
            else
                echo "$p remove [FAIL]"  | tee -a ${RESULT_FILE}
            fi
        done
        ;;
esac
