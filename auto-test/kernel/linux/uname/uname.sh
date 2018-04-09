
#!/bin/sh -e
cd ../../../../utils
    .        ./sys_info.sh
             ./sh-test-lib
cd -
if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

version="4.16.0-rc3-arm64"
package="uname"

# Check the version 
vers=$(uname -r)
if [ "$vers" = "$version"   ];then
      print_info 0 version
else
     print_info 1 version
fi
done

