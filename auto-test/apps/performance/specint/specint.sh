#!/bin/sh -e

. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
dist_name
case "${dist}" in
    centos)
        install_deps "automake numactl gcc* libgfortran *cmp cmp*"
        ;;
esac
! check_root && error_msg "You need to be root to run this script."
create_out_dir "${OUTPUT}"
cd ${OUTPUT}
./scp.sh
#scp chenshuangsheng@192.168.1.106:~/Ali-test/speccpu2006*
export FORCE_UNSAFE_CONFIGURE=1
SPEC_DIR=speccpu2006
cd $SPEC_DIR/tools/src&&echo y | ./buildtools
cd $SPEC_DIR
. ./shr
./bin/runspec -c config/lemon-2cpu.cfg int --rate 1 -n 1 -noreportable | tee "${RESULT_FILE}"
./bin/runspec -c config/lemon-2cpu.cfg int --rate 32 -n 1 -noreportable | tee "${RESULT_FILE}"
./bin/runspec -c config/lemon-2cpu.cfg int --rate 64 -n 1 -noreportable | tee "${RESULT_FILE}"

