
#!/bin/sh 
set -x
cd ../../../../utils
    .        ./sys_info.sh
             ./sh-test-lib
cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

# display version
swapon -V|grep "swapon from"
print_info $? version

# enable all swaps
swapon -a
print_info $? swapon

# enable swap discards
swapon -d|grep "NAME"
print_info $? discards

# silently skip devices that do not exist
swapon -e|grep "NAME"
print_info $? silent

# display summary about used swap devices
swapon -s|grep  "Filename"
print_info $? summary

# setup the priority
swapon -p -2|grep "NAME"
print_info $? priority

# off the swap
swapoff -a
print_info $? swapoff

# display this help and exit
swapon --help|grep Usage
print_info $? help

