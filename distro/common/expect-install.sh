#!/bin/bash
pushd ./utils
. ./sys_info.sh
popd
$install_commands expect
if [ $? -ne 0 ]
then
   echo 'install expect fail'
   exit 0
fi


