
#!/bin/sh -e
set -x
cd ../../../../utils
    .        ./sys_info.sh
             ./sh-test-lib
cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

version="5.3.1"
from_repo="Estuary"
package="devtoolset-4-gcc"
for P in ${package};do
    echo "$P install"
case $distro in
    "centos" )
         yum install -y $P 
         print_info $? devtoolset-4-gcc
         ;;
 esac

# Check the package version && source
from=$(yum info $P | grep "From repo" | awk '{print $4}')
if [ "$from" = "$from_repo"  ];then
    echo "$P source is $from : [pass]" | tee -a ${RESULT_FILE}
else
    rmflag=1
    if [ "$from" != "Estuary"  ];then
        yum remove -y $P
        yum install -y $P
        from=$(yum info $P | grep "From repo" | awk '{print $4}')
        if [ "$from" = "$from_repo"   ];then
            echo "$P install  [pass]" | tee -a ${RESULT_FILE}
        else
            echo "$P source is $from : [failed]" | tee -a ${RESULT_FILE}
        fi
    fi
fi

vers=$(yum info $P | grep "Version" | awk '{print $3}')
if [ "$vers" = "$version"   ];then
    echo "$P version is $vers : [pass]" | tee -a ${RESULT_FILE}
else
    echo "$P version is $vers : [failed]" | tee -a ${RESULT_FILE}
fi
done

# Remove package
yum remove -y $P
print_info $? remove
