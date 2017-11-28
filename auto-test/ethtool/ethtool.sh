
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

# Install package
case $distro in
    "ubuntu" | "debian" )
         apt-get install -y ethtool >> eth-install.log
         ;;
    "centos" )
         yum install -y ethtool >> eth-install.log
         ;;
 esac

str=`cat eth-install.log | grep error`
if [ $str != '' ];then
    lava-test-case ethtool-install --result fail
else
    lava-test-case ethtool-install --result pass
fi

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

ethtool -s eth0 speed 10 deplex full
print_info $? duplex-full

ethtool -s eth0 speed 1000 duplex full
print_info $? duplex-full-1000

# Set ethernet autoneg
ethtool -s eth0 autoneg on
print_info $? autoneg

# Remove package
yum remove -y ethtool 
print_info $? remove ethtool
