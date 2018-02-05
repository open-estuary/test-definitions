

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

version="1.95"
from_repo="Estuary"
package="nicstat"

for P in ${package};do
    echo "$P install"
# Install package
case $distro in
    "centos" )
        wget http://sourceforge.net/projects/nicstat/files/nicstat-1.92.tar.gz
        tar -zxvf nicstat-1.92.tar.gz 
        cd nicstat-1.92
        cp Makefile.Linux  Makefile
        sed -i 's/-m32//g' Makefile
        make
        make install
      #  yum install -y nicstat 
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

# Statistic ethernet flux 5 times
nicstat 1 5
print_info $? statistics

# Statistic ethernet tcp flux
nicstat -t 1 5
print_info $? tcp

# Statistic ethernet udp flux
nicstat -u 1 5
print_info $? udp

# Remove package
yum remove -y $P
print_info $? remove
