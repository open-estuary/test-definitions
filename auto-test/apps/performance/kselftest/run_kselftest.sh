#!/bin/bash
cd $(dirname $0)
ROOT=$PWD
cd $ROOT
echo ; echo Running tests in cpu-hotplug
echo ========================================
cd cpu-hotplug
(./cpu-on-off-test.sh && echo "selftests: cpu-on-off-test.sh [PASS]") || echo "selftests: cpu-on-off-test.sh [FAIL]"
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
