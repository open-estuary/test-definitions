# =================================================================
#   Filename: uname
#   Author:  
#   Email: 
#   Date: 2018-11-22 
#   Description: Print certain system information.
# ================================================================

################## specify interpreter path ##################

#!/bin/bash

############# importing environment variable ##############

cd ../../../../utils
   .         ./sys_info.sh
   .         ./sh-test-lib
cd -

#################### precheck ####################

if [ 'whoami' != 'root' ];then
	echo "You must be the root to run this script" >$2
	exit 1
fi

################## setting variables ##################

OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE

# pkgs="uname"
version="4.18"
machine="aarch64"

#################### install ####################

case $distro in
    "centos")
        install_deps "${pkgs}"
        print_info $? install-pkgs
        ;;
    "debian")
        install_deps "${pkgs}" -y
        print_info $? install-pkgs
        ;;
esac

#################### testing step ####################

## Check the version ##
vers=`uname -r|cut -b 1-4`
echo $vers
if [ "$vers" = "$version" ];then
      print_info $0 version
else
      print_info $1 version
fi

## check the machine ##
mach='uname -m'
echo $mach
if [ "$mach" = "$machine" ];then
	print_info $0 machine
else
	print_info $1 machine
fi

################## restore environment ##################




