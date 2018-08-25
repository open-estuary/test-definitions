
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

IFCONFIG=`ip link|grep "state UP"|awk '{print $2}'|sed 's/://g'|head -1`

# Install package
install_deps "ethtool"
print_info $? install_ethtool

# Check ethernet drive
ethtool -i $IFCONFIG
print_info $? check-drive

# Check ethernet base configuration
ethtool $IFCONFIG
print_info $? check-configuration

# Resetting ethernet auto-negotiation
ethtool -r $IFCONFIG
print_info $? reset-autoneg

# Check ethernet statistic
ethtool -S $IFCONFIG
print_info $? check-statistics

# Set ethernet speed
ethtool -s $IFCONFIG speed 10
print_info $? speed-10

ethtool -s $IFCONFIG speed 100
print_info $? speed-100

ethtool -s $IFCONFIG speed 1000
print_info $? speed-1000

# Set ethernet duplex
ethtool -s $IFCONFIG speed 10 duplex half
print_info $? duplex-half

ethtool -s $IFCONFIG speed 10 duplex full
print_info $? duplex-full

ethtool -s $IFCONFIG speed 1000 duplex full
print_info $? duplex-full-1000

# Set ethernet autoneg
ethtool -s $IFCONFIG autoneg on
print_info $? autoneg

# Remove package
remove_deps "ethtool"
print_info $? remove
