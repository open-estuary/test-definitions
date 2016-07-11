#!/bin/bash
pushd ./utils
. ./sys_info.sh
popd
$install_commands expect
if [ $? -ne 0 ]
then
   echo 'install expect fail'
   lava-test-case qemu-run-result --result fail
   exit 0
else
   lava-test-case qemu-run-result --result pass
fi


