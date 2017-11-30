
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
# Statistic ethernet flux 5 times
nicstat 1 5
print_info $? statistic

# Statistic ethernet tcp flux
nicstat -t 1 5
print_info $? tcp-statistic

# Statistic ethernet udp flux
nicstat -u 1 5
print_info $? udp-statistic

# Remove package
yum remove nicstat -y
print_info $? remove
