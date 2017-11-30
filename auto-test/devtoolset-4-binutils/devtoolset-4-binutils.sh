
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
         yum install -y devtoolset-4-binutils 
         ;;
 esac
 print_info $? devtoolset-4-binutils

# Remove package
yum remove -y devtoolset-4-binutils
print_info $? remove
