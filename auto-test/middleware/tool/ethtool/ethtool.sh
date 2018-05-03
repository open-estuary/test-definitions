
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

version="4.8"
from_repo="base"
package="ethtool"

for P in ${package};do
    echo "$P install"
# Install package
case $distro in
    "ubuntu" | "debian" )
         apt-get install -y $P 
         print_info $? $P
         ;;
    "centos" )
         yum install -y $P
         print_info $? ethtool
         ;;
 esac

# Check the package version && source
from=$(yum info $P | grep "From repo" | awk '{print $4}')
if [ "$from" = "$from_repo"  ];then
      print_info 0 repo_check
else
     rmflag=1
      if [ "$from" != "base"  ];then
           yum remove -y $P
            yum install -y $P
             from=$(yum info $P | grep "From repo" | awk '{print $4}')
             if [ "$from" = "$from_repo"   ];then
                   print_info 0 repo_check
            else
                  print_info 1 repo_check
           fi
        fi
fi

vers=$(yum info $P | grep "Version" | awk '{print $3}')
if [ "$vers" = "$version"   ];then
      print_info 0 version
else
     print_info 1 version
fi 
done

# Check ethernet drive
ethtool -i eth0
print_info $? check-drive

# Check ethernet base configuration
ethtool eth0
print_info $? check-configuration

# Resetting ethernet auto-negotiation
ethtool -r eth0
print_info $? reset-autoneg

# Check ethernet statistic
ethtool -S eth0
print_info $? check-statistics

# Set ethernet speed
ethtool -s eth0 speed 10
print_info $? speed-10

ethtool -s eth0 speed 100
print_info $? speed-100

ethtool -s eth0 speed 1000
print_info $? speed-1000

# Set ethernet duplex
ethtool -s eth0 speed 10 duplex half
print_info $? duplex-half

ethtool -s eth0 speed 10 duplex full
print_info $? duplex-full

ethtool -s eth0 speed 1000 duplex full
print_info $? duplex-full-1000

# Set ethernet autoneg
ethtool -s eth0 autoneg on
print_info $? autoneg

# Remove package
yum remove -y $P
print_info $? remove
