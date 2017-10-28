#!/bin/sh -e
set -x
cd ../../utils
    . ./sys_info.sh
cd -
SERVER="127.0.0.1"
TIME="10"
THREADS="1"
VERSION="3.1.4"

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

#while getopts "c:t:p:v:s:h" o; do
 # case "$o" in
  #  c) SERVER="${OPTARG}" ;;
   # t) TIME="${OPTARG}" ;;
    #p) THREADS="${OPTARG}" ;;
    #v) VERSION="${OPTARG}" ;;
    #s) SKIP_INSTALL="${OPTARG}" ;;
   # h|*) usage ;;
 # esac
#done

case $distro in
    "ubuntu")
         apt-get install iperf -y
         apt-get install iperf3 -y
         ;;
    "centos")
         yum install wget -y
         yum install gcc -y
         yum install make -y
         wget https://github.com/esnet/iperf/archive/"${VERSION}".tar.gz
         tar xf "${VERSION}".tar.gz
         cd iperf-"${VERSION}"
         ./configure
         make
         make install
         ;;
    "opensuse")
         zypper install -y iperf
         ;;
 esac

# Run local iperf3 server as a daemon when testing localhost.
[ "${SERVER}" = "127.0.0.1" ] && iperf3 -s -D

# Run iperf test with unbuffered output mode.
stdbuf -o0 iperf3 -c "${SERVER}" -t "${TIME}" -P "${THREADS}" 2>&1 \
    | tee iperf.log
TCID="iperf test"
# Parse logfile.
if [ "${THREADS}" -eq 1 ]; then
    egrep "(sender|receiver)" iperf.log \
        | awk '{printf("iperf-%s pass %s %s\n", $NF,$7,$8)}' \
        | tee -a iperf.log
    lava-test-case $TCID --result pass
elif [ "${THREADS}" -gt 1 ]; then
    egrep "[SUM].*(sender|receiver)" "${LOGFILE}" \
        | awk '{printf("iperf-%s pass %s %s\n", $NF,$6,$7)}' \
        | tee -a iperf.log
    lava-test-case $TCID --result pass
else
    lava-test-case $TCID --result fail
fi

# Kill iperf test daemon if any.
pkill iperf3 || true
