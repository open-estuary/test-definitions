#!/bin/bash
cd $(dirname $0)
ROOT=$PWD
cd $ROOT
echo ; echo Running tests in cpu-hotplug
echo ========================================
cd cpu-hotplug
(./cpu-on-off-test.sh && echo "selftests: cpu-on-off-test.sh [PASS]") || echo "selftests: cpu-on-off-test.sh [FAIL]"
cd $ROOT
echo ; echo Running tests in efivarfs
echo ========================================
cd efivarfs
(./efivarfs.sh && echo "selftests: efivarfs.sh [PASS]") || echo "selftests: efivarfs.sh [FAIL]"
cd $ROOT
echo ; echo Running tests in exec
echo ========================================
cd exec
mkdir -p subdir; (./execveat && echo "selftests: execveat [PASS]") || echo "selftests: execveat [FAIL]"
cd $ROOT
echo ; echo Running tests in firmware
echo ========================================
cd firmware
(./fw_filesystem.sh && echo "selftests: fw_filesystem.sh [PASS]") || echo "selftests: fw_filesystem.sh [FAIL]"
(./fw_userhelper.sh && echo "selftests: fw_userhelper.sh [PASS]") || echo "selftests: fw_userhelper.sh [FAIL]"
cd $ROOT
echo ; echo Running tests in ftrace
echo ========================================
cd ftrace
(./ftracetest && echo "selftests: ftracetest [PASS]") || echo "selftests: ftracetest [FAIL]"
cd $ROOT
echo ; echo Running tests in kcmp
echo ========================================
cd kcmp
(./kcmp_test && echo "selftests: kcmp_test [PASS]") || echo "selftests: kcmp_test [FAIL]"
cd $ROOT
echo ; echo Running tests in memfd
echo ========================================
cd memfd
(./memfd_test && echo "selftests: memfd_test [PASS]") || echo "selftests: memfd_test [FAIL]"
cd $ROOT
echo ; echo Running tests in memory-hotplug
echo ========================================
cd memory-hotplug
./mem-on-off-test.sh -r 2 || echo selftests: memory-hotplug [FAIL]
cd $ROOT
echo ; echo Running tests in mount
echo ========================================
cd mount
if [ -f /proc/self/uid_map ] ; then ./unprivileged-remount-test ; fi
cd $ROOT
echo ; echo Running tests in mqueue
echo ========================================
cd mqueue
./mq_open_tests /test1 || echo "selftests: mq_open_tests [FAIL]"
./mq_perf_tests || echo "selftests: mq_perf_tests [FAIL]"
cd $ROOT
echo ; echo Running tests in net
echo ========================================
cd net
(./run_netsocktests && echo "selftests: run_netsocktests [PASS]") || echo "selftests: run_netsocktests [FAIL]"
(./run_afpackettests && echo "selftests: run_afpackettests [PASS]") || echo "selftests: run_afpackettests [FAIL]"
cd $ROOT
