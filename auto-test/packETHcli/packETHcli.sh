
#!/bin/sh -e
set -x
cd ../../utils
    . ./sys_info.sh
      ./sh-test-lib
cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

case $distro in
    "centos" )
         yum install -y packETHcli 
         print_info $? packETHcli
         ;;
 esac

# Remove package
yum remove -y packETHcli
print_info $? remove
