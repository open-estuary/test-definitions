# Copyright (C) 2018-9-4, Estuary.
# Author: wangsisi

#!/bin/sh 
set -x
if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

cd ../../../../utils
source  ./sys_info.sh
source  ./sh-test-lib
cd -

SERVER="127.0.0.1"
TIME="10"
THREADS="1"

case $distro in
    "ubuntu"|"debian")
         pkgs="iperf iperf3"
         install_deps "${pkgs}"
         print_info $? install-iperf
         ;;
    "centos")
         pkgs="iperf iperf3"
         install_deps "${pkgs}"
         print_info $? install-iperf
         ;;
    "fedora")
         pkgs="iperf3"
         install_deps "${pkgs}"
         print_info $? install-iperf
         ;;
    "opensuse")
         pkgs="iperf"
         install_deps "${pkgs}"
         print_info $? install-iperf
         ;;
 esac

sed -i '$a\/usr/local/lib' /etc/ld.so.conf
cd /etc
ldconfig
cd -

# Run local iperf3 server as a daemon when testing localhost.
 [ "${SERVER}" = "127.0.0.1" ] && iperf3 -s -D
 print_info $? start-iperf-server
# Run iperf test with unbuffered output mode.
 stdbuf -o0 iperf3 -c "${SERVER}" -t "${TIME}" -P "${THREADS}" 2>&1 \
  | tee iperf.log
 print_info $? start-iperf-client

# Parse logfile.
if [ "${THREADS}" -eq 1 ]; then
    egrep "(sender|receiver)" iperf.log
    print_info $? iperf_test
elif [ "${THREADS}" -gt 1 ]; then
    egrep "[SUM].*(sender|receiver)" iperf.log 
    print_info $? iperf_test
else
    print_info 1 iperf_test
fi

# Kill iperf test daemon if any.
pkill iperf3 || true
print_info $? kill-iperf
#uninstall
remove_deps "${pkgs}"
print_info $? remove-package
