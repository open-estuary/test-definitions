#!/bin/bash

cd ../../../../utils
    .        ./sys_info.sh
    .         ./sh-test-lib
cd -
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
package_list=""
dist_name
! check_root && error_msg "This script must be run as root"
create_out_dir "${OUTPUT}"
case "${dist}" in
    debian)
        from_repo1='linux-estuary-latest'
        from_repo2='linux'
        v='1'
        version1="4.12+50${v}"
        version2="4.12.0.estuary.50${v}-1"
        version3="2.0+4.12.0.estuary.50${v}-1"
        package_list="libcpupower1 libcpupower-dev libusbip-dev linux-cpupower linux-estuary-doc linux-estuary-perf linux-estuary-source linux-headers-4.12.0-50${v}-all linux-headers-4.12.0-50${v}-all-arm64 linux-headers-4.12.0-50${v}-arm64 linux-headers-4.12.0-50${v}-common linux-headers-estuary-arm64 linux-image-4.12.0-50${v}-arm64 linux-image-4.12.0-50${v}-arm64-dbg linux-image-estuary-arm64 linux-image-estuary-arm64-dbg linux-kbuild-4.12 linux-libc-dev linux-perf-4.12 linux-source-4.12 linux-support-4.12.0-50${v} usbip"
        for p in ${package_list};do
            echo "$p install"
            apt-get install -y $p
            rmflag=0
            status=$?
            if test ${status} -eq 0;then
                print_info 0 $p_install
                from=$(apt show $p | grep "Source" | awk '{print $2}')
                if [ "$from" = "$from_repo1" -o "$from" = "$from_repo2" ];then
                print_info 0 repo_check
                else
                    #已经安装，但是安装源不是estuary的情况需要卸载重新安装
                    rmflag=1
                   # if [ "$from" != "anaconda" ];then
                   #     yum remove -y $p
                   #     yum install -y $p
                   #     from=$(yum info $p | grep "Source" | awk '{print $2}')
                   #     if [ "$from" = "$from_repo1" -o "$from" = "$from_repo2" ];then
                   #         echo "$p install  [PASS]" | tee -a ${RESULT_FILE}
                   #     else
                    print_info 1 repo_check
                   #    fi
                   # fi
                fi

                vs=$(apt show $p | grep "Version" | awk '{print $2}')
                if [ "$vs" = "$version1" -o "$vs" = "$version2" -o "$vs" = "$version3" ];then
                    print_info 0 version
                else
                    print_info 1 version
                fi

                #对于自带的包不去做卸载处理
                if test $rmflag -eq 0
                then
                    apt-get remove -y $p
                    status=$?
                    if test $status -eq 0
                    then
                        print_info 0 remove
                    else
                        print_info 1 remove
                    fi
                fi
            fi
        done
        ;;
    centos)
        version="4.12.0"
        release="estuary.3"
        from_repo="Estuary"
        package_list="kernel-debug-devel kernel-debuginfo kernel-debuginfo-common-aarch64 kernel-tools-debuginfo perf-debuginfo python-perf-debuginfo"
        for p in ${package_list};do
            echo "$p install"
            yum install -y $p
            status=$?
            rmflag=0
            if test $status -eq 0
            then
                 print_info 0 install
                from=$(yum info $p | grep "From repo" | awk '{print $4}')
                if [ "$from" = "$from_repo" ];then
                   print_info 0 repo_check
                else
                    #已经安装，但是安装源不是estuary的情况需要卸载重新安装
                    rmflag=1
                    if [ "$from" != "Estuary" ];then
                        yum remove -y $p
                        yum install -y $p
                        from=$(yum info $p | grep "From repo" | awk '{print $4}')
                        if [ "$from" = "$from_repo" ];then
                             print_info 0 repo_check
                        else
                            print_info 1 repo_check
                        fi
                    fi
                fi

                vs=$(yum info $p | grep "Version" | awk '{print $3}')
                if [ "$vs" = "$version" ];then
                      print_info 0 version
                else
                      print_info 1 version
                fi

                rs=$(yum info $p | grep "Release" | awk '{print $3}')
                if [ "$rs" = "$release" ];then
                     print_info 0 release
                else
                     print_info 1 release
                fi
                #对于自带的包不去做卸载处理
                # if test $rmflag -eq 0
                # then
                  #  yum remove -y $p
                   # status=$?
                    # if test $status -eq 0
                    # then
                       # print_info 0 remove
                    # else
                      #  print_info 1 remove
                    # fi
                # else
                  #  echo "$p don't remove" | tee -a ${RESULT_FILE}
                # fi
            # else
              #  echo "$p install [FAIL]"  | tee -a ${RESULT_FILE}
             fi
         done
        ;;
    ubuntu)
        package_list="linux-estuary linux-headers-estuary linux-image-estuary linux-source-estuary linux-tools-estuary linux-cloud-tools-common linux-doc linux-headers-4.12.0-502 linux-headers-4.12.0-502-generic linux-image-4.12.0-502-generic linux-image-extra-4.12.0-502-generic linux-libc-dev linux-source-4.12.0 linux-tools-4.12.0-502 linux-tools-4.12.0-502-generic linux-tools-common"
        for p in ${package_list};do
            echo "$p install"
            apt-get install -y $p
            status=$?
            from_repo1='linux-meta-estuary'
            from_repo2='linux'
            version1='4.12.0.502.2'
            version2='4.12.0-502.estuary'
            rmflag=0
            if test $status -eq 0
            then
                print_info 0 install
                from=$(apt show $p | grep "Source" | awk '{print $2}')
                if [ "$from" = "$from_repo1" -o "$from" = "$from_repo2" ];then
                print_info 0 repo_check
                else
                    #已经安装，但是安装源不是estuary的情况需要卸载重新安装
                    rmflag=1
                    echo "$p already installed,source is: $from " | tee -a ${RESULT_FILE}
                fi

                vs=$(apt show $p | grep "Version" | awk '{print $2}')
                if [ "$vs" = "$version1" -o "$vs" = "$version2" ];then
                    print_info 0 install
                else
                    print_info 1 install
                fi
            fi
            echo "$p remove"
            apt-get remove -y $p
            status=$?
            if test $status -eq 0
            then
                print_info 0 remove
            else
                print_info 1 remove
            fi
        done
        ;;
esac
