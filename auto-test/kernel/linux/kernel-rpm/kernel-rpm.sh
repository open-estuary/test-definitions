#!/bin/bash

cd ../../../../utils
    .        ./sys_info.sh
    .        ./sh-test-lib
cd -
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
LOG="${OUTPUT}/log.txt"
export RESULT_FILE
kernel_name=""
dist_name
! check_root && error_msg "This script must be run as root"
create_out_dir "${OUTPUT}"
cd ${OUTPUT}
headers=$(uname -r)
case "${dist}" in
    ubuntu)
        kernel_name="linux-image-${headers}"
        sudo apt-get -y build-dep ${kernel_name} 
        status=$?
        if test $status -eq 0;then
            print_info 0 install
        else
            print_info 1 install
        fi
        sudo apt-get source -b ${kernel_name} 
        status=$?
        if test $status -eq 0
        then
            print_info 0 source
        else
            print_info 1 source
        fi
        ;;
    debian)
        kernel_name="linux-image-${headers}"
        apt-get build-dep ${kernel_name} 
        status=$?
        if test $status -eq 0
        then
            print_info 0 install
        else
            print_info 1 install
        fi
        apt-get source -b ${kernel_name} 
        status=$?
        if test $status -eq 0
        then
            print_info 0 install
        else
            print_info 1 install
        fi
        ;;
    centos|fedora) 
        yum install yum-utils -y
        print_info $? yum-utils

        yum build-dep -y kernel 
        
        yum install -y pesign
        print_info $? pesign

        yum install rpm-build -y
        print_info $? rpm-build

        yumdownloader --source kernel
        status=$?
        if test $status -eq 0
        then
            print_info 0 install
        else
            print_info 0 install
        fi
        kernel_name=$(ls | grep "kernel-aarch64-")
        rpmbuild --rebuild  ${kernel_name} 
        status=$?
        if test $status -eq 0
        then
            print_info 0 rpmbuild
        else
            print_info 1 rpmbuild
        fi
        ;;
esac
cd -
