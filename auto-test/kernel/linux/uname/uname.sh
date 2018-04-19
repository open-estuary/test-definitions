
#!/bin/sh -e
cd ../../../../utils
    .        ./sys_info.sh
    .         ./sh-test-lib
cd -
if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

version="4.16.0"

# Check the version 
vers=`uname -r|cut -b 1-6`
echo $vers
if [ "$vers" = "$version" ];then
      print_info $? version
else
      print_info $? version
fi


