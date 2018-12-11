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
    source  ./sys_info.sh
    source  ./sh-test-lib
cd -

#################### precheck ####################

! check_root && error_msg "please run this script as root."

################## setting variables ##################

version="4.19"
machine="aarch64"

#################### install ####################

# case $distro in
  #  "centos")
   #     install_deps "${pkgs}"
    #    print_info $? install-pkgs
     #   ;;
  #  "debian")
   #     install_deps "${pkgs}" -y
    #    print_info $? install-pkgs
     #   ;;
#esac

#################### testing step ####################

## Check the version ##
vers=`uname -r|cut -b 1-4`
echo $vers
if [ "$vers" = "$version" ];then
      print_info 0 version
else
      print_info 1 version
fi

## check the machine ##
mach=`uname -m`
echo $mach
if [ "$mach" = "$machine" ];then
	print_info 0 machine
else
	print_info 1 machine
fi

################## restore environment ##################




