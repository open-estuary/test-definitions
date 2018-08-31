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
        sed -i s/5.[0-9]/5.1/g /etc/apt/sources.list.d/estuary.list
        apt-get update
        from_repo1='linux-estuary-latest'
        from_repo2='linux'
        v='2'
        version1="4.16+${v}"
        version2="4.16.0.estuary.${v}-1"
        version3="2.0+4.16.0.estuary.${v}-1"
        package_list="libcpupower1 libcpupower-dev  linux-cpupower linux-estuary-doc linux-estuary-perf linux-estuary-source linux-headers-4.16.0-${v}-all linux-headers-4.16.0-${v}-all-arm64 linux-headers-4.16.0-${v}-arm64 linux-headers-4.16.0-${v}-common linux-headers-estuary-arm64 linux-image-4.16.0-${v}-arm64 linux-image-estuary-arm64 linux-kbuild-4.16 linux-libc-dev linux-perf-4.16 linux-source-4.16 linux-support-4.16.0-${v} usbip"
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
        sed -i s/5.[0-9]/5.1/g /etc/yum.repos.d/estuary.repo
        version="4.16.0"
        release="estuary.6"
        from_repo="Estuary"
        package_list="kernel-devel kernel-headers kernel-tools-libs kernel-tools-libs-devel perf python-perf  kernel-debug kernel-debug-debuginfo"
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
                if test $rmflag -eq 0
                then
                    yum remove -y $p
                    status=$?
                    if test $status -eq 0
                    then
                        print_info 0 remove
                    else
                        print_info 1 remove
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
        sed -i s/5.[0-9]/5.1/g /etc/apt/sources.list.d/estuary.list 
        apt-get update -q=2
        v='4.16.0-504'
        v1='4.16.0'
        package_list="linux-estuary linux-headers-estuary linux-source-estuary linux-tools-estuary linux-cloud-tools-common linux-doc linux-headers-${v} linux-headers-${v}-generic linux-image-${v}-generic linux-image-extra-${v}-generic linux-source-${v1} linux-tools-${v} linux-tools-${v}-generic linux-tools-common"
        for p in ${package_list};do
            echo "$p install"
            apt-get install -y $p
            status=$?
            from_repo1='linux-meta-estuary'
            from_repo2='linux'
            version1='4.16.0.504.2'
            version2='4.16.0-504.estuary'
            rmflag=0
            if test $status -eq 0
            then
                print_info 0 installa
                from=$(apt show $p | grep -w "Source" | awk '{print $2}')
                if [ "$from" = "$from_repo1" -o "$from" = "$from_repo2" ];then
                print_info 0 repo_check
                else
                    #已经安装，但是安装源不是estuary的情况需要卸载重新安装
                    rmflag=1
                    echo "$p already installed,source is: $from " | tee -a ${RESULT_FILE}
                fi

                vs=$(apt show $p | grep "Version" | awk '{print $2}')
                if [ "$vs" = "$version1" -o "$vs" = "$version2" ];then
                    print_info 0 version_check 
                else
                    print_info 1 version_check 
                fi
            fi
            if [ "$p" != "linux-image-${v}-generic" ];then  
                echo "$p remove"
                apt-get remove -y $p
                status=$?
                if test $status -eq 0
                then
                    print_info 0 remove
                else
                    print_info 1 remove
                fi
            fi
        done
        ;;
    fedora)
        sed -i s/5.[0-9]/5.1/g /etc/yum.repos.d/estuary.repo
        yum update
        version="4.16.0"
        release="estuary.2.fc26"
        from_repo="estuary"
        from_repo1="Estuary"
        package_list="kernel kernel-core kernel-devel kernel-headers kernel-debuginfo kernel-debuginfo-common kernel-modules kernel-modules-extra"
        for p in ${package_list};do
            echo "$p install"
            yum install -y $p
            status=$?
            rmflag=0
            if test $status -eq 0
            then
                 print_info 0 install
                from=$(yum info $p | grep "From repo" | awk '{print $4}'|head -1)
                if [ "$from" = "$from_repo" -o "$from" = "$from_repo1" ];then
                   print_info 0 repo_check
                else
                    #已经安装，但是安装源不是estuary的情况需要卸载重新安装
                    rmflag=1
                    if [ "$from" != "$from_repo"  -o "$from" != "$from_repo1" ];then
                        yum remove -y $p
                        yum install -y $p
                        from=$(yum info $p | grep "From repo" | awk '{print $4}'|head -1)
                        if [ "$from" = "$from_repo" -o "$from" = "$from_repo1" ];then
                             print_info 0 repo_check
                        else
                            print_info 1 repo_check
                        fi
                    fi
                fi

                vs=$(yum info $p | grep "Version      : 4.16.0" | awk '{print $3}'|head -1)
                if [ "$vs" = "$version" ];then
                      print_info 0 version
                else
                      print_info 1 version
                fi

                rs=$(yum info $p | grep "Release      : estuary.2.fc26" | awk '{print $3}'|head -1)
                if [ "$rs" = "$release" ];then
                     print_info 0 release
                else
                     print_info 1 release
                fi
                #对于自带的包不去做卸载处理
                if test $rmflag -eq 0
                then
                    yum remove -y $p
                    status=$?
                    if test $status -eq 0
                    then
                        print_info 0 remove
                    else
                        print_info 1 remove
                    fi
                else
                    echo "$p don't remove" | tee -a ${RESULT_FILE}
                fi
            else
                echo "$p install [FAIL]"  | tee -a ${RESULT_FILE}
            fi
        done
        ;;
    opensuse)
         version="4.16.3-0.gd41301c" 
         source1="kernel-default-4.16.3-0.gd41301c.nosrc"  
         installed="No"
         package_list="kernel-default kernel-default-base"
          wget ftp://117.78.41.188/utils/distro-binary/opensuse/kernel-default-4.16.3-0.gd41301c.aarch64.rpm
         wget ftp://117.78.41.188/utils/distro-binary/opensuse/kernel-default-base-4.16.3-0.gd41301c.aarch64.rpm
#         wget ftp://117.78.41.188/utils/distro-binary/opensuse/kernel-default-devel-4.16.3-0.gd41301c.aarch64.rpm
         
          for p in ${package_list};do  
               inst=$(zypper info $p  |grep  "Installed      :" | awk '{print $3}')  
               if [ "$p" = "kernel-default" ];then
                  if [ "$inst" = "$installed" ];then
                     zypper --no-gpg-checks install -y kernel-default-4.16.3-0.gd41301c.aarch64.rpm
                     print_info $? install
                  else
                     zypper remove -y $p
                     zypper --no-gpg-checks install -y kernel-default-4.16.3-0.gd41301c.aarch64.rpm
                     print_info $? install
                  fi
               fi

               if [ "$p" = "kernel-default-base" ];then
                  if [ "$inst" = "$installed" ];then
                     zypper --no-gpg-checks install -y kernel-default-base-4.16.3-0.gd41301c.aarch64.rpm
                     print_info $? install
                  else
                     zypper remove -y $p
                     zypper --no-gpg-checks install -y kernel-default-base-4.16.3-0.gd41301c.aarch64.rpm
                     print_info $? install 
                  fi
               fi

#               if [ "$p" = "kernel-default-devel" ];then
#                  if [ "$inst" = "$installed" ];then
#                    zypper --no-gpg-checks  install -y kernel-default-devel-4.16.3-0.gd41301c.aarch64.rpm
#                    print_info $? install
#                 else
#                     zypper remove -y $p
#                     zypper --no-gpg-checks install -y kernel-default-devel-4.16.3-0.gd41301c.aarch64.rpm
#                     print_info $? install
#                  fi                   
#               fi
               vs=$(zypper info $p | grep "Version" | awk '{print $3}')               
                  if [ "$vs" = "$version" ];then
                      print_info 0 version
                  else
                      print_info 1 version
                  fi
              sr=$(zypper info $p | grep "Source package" | awk '{print $4}')
                  if [ "$sr" = "$source1" ];then
                      print_info 0 source_package
                  else
                      print_info 1 source_package
                  fi
              zypper remove -y $p
              print_info $? remove
         done
         ;;   
esac
