#!/bin/bash 

# SysBench is a modular, cross-platform and multi-threaded benchmark tool.
# Current features allow to test the following system parameters:
# * file I/O performance
# * scheduler performance
# * memory allocation and transfer speed
# * POSIX threads implementation performance
# * database server performance
set -x
# shellcheck disable=SC1091
. ../../../../utils/sh-test-lib
. ../../../../utils/sys_info.sh
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
SKIP_INSTALL="false"

# sysbench test parameters.
NUM_THREADS="NPROC"
# TESTS="cpu memory threads mutex fileio oltp"
TESTS="cpu memory threads mutex fileio"

[ "${NUM_THREADS}" = "NPROC" ] && NUM_THREADS=$(nproc)

! check_root && error_msg "Please run this script as root."

#==================  test step ============================
./sysbench.sh
print_info $? sysbench-install

create_out_dir "${OUTPUT}"
cd "${OUTPUT}"

case "${distro}" in
    debian|ubuntu)
	pkgs="git gcc build-essential automake libtool"
	install_deps "$pkgs"
        print_info $? install-depend
        ;;
    fedora|centos)
	pkgs="git gcc make automake libtool"
        install_deps "$pkgs"
	print_info $? install-depend
        sysbench --version
	;;
     opensuse)
	pkgs="git gcc make automake"
        install_deps "$pkgs"
	print_info $? install-depend
        ;;
esac
       



general_parser() {
    # if $1 is there, let's append to test name in the result file
    # shellcheck disable=SC2039
    local tc="$tc$1"
    ms=$(grep -m 1 "total time" "${logfile}" | awk '{print substr($NF,1,length($NF)-1)}')
    add_metric "${tc}-total-time" "pass" "${ms}" "s"

    ms=$(grep "total number of events" "${logfile}" | awk '{print $NF}')
    add_metric "${tc}-total-number-of-events" "pass" "${ms}" "times"

    ms=$(grep "total time taken by event execution" "${logfile}" | awk '{print $NF}')
    add_metric "${tc}-total-time-taken-by-event-execution" "pass" "${ms}" "s"

    for i in min avg max approx; do
        ms=$(grep -m 1 "$i" "${logfile}" | awk '{print substr($NF,1,length($NF)-2)}')
        add_metric "${tc}-response-time-$i" "pass" "${ms}" "ms"
    done

    ms=$(grep "events (avg/stddev)" "${logfile}" |  awk '{print $NF}')
    ms_avg=$(echo "${ms}" | awk -F'/' '{print $1}')
    ms_stddev=$(echo "${ms}" | awk -F'/' '{print $2}')
    add_metric "${tc}-events-avg" "pass" "${ms_avg}" "times"
    add_metric "${tc}-events-stddev" "pass" "${ms_stddev}" "times"

    ms=$(grep "execution time (avg/stddev)" "${logfile}" |  awk '{print $NF}')
    ms_avg=$(echo "${ms}" | awk -F'/' '{print $1}')
    ms_stddev=$(echo "${ms}" | awk -F'/' '{print $2}')
    add_metric "${tc}-execution-time-avg" "pass" "${ms_avg}" "s"
    add_metric "${tc}-execution-time-stddev" "pass" "${ms_stddev}" "s"
}

# Test run.
for tc in ${TESTS}; do
    echo
    info_msg "Running sysbench ${tc} test..."
    logfile="${OUTPUT}/sysbench-${tc}.txt"
    case "${tc}" in
        percpu)
            processor_id="$(awk '/^processor/{print $3}' /proc/cpuinfo)"
            for i in ${processor_id}; do
                taskset -c "$i" sysbench --num-threads=1 --test=cpu run | tee "${logfile}"
                general_parser "$i"
                print_info $? per-cpu
            done
            ;;
        cpu|threads|mutex)
            sysbench --num-threads="${NUM_THREADS}" --test="${tc}" run | tee "${logfile}"
            general_parser
            print_info $? ${tc}
            #print_info $? threads-test
            #print_info $? mutex-test
            ;;
        memory)
            for j in ['8k','16k']; do
                for i in ['rnd','seq']; do
                    sysbench --num-threads="${NUM_THREADS}" --test=memory --memory-block-size=$j --memory-total-size=100G --memory-access-mode=$i run | tee "${logfile}"
                    general_parser "$i"
                    print_info $? $j-$i
                    ms=$(grep "Operations" "${logfile}" | awk '{print substr($4,2)}')
                    add_metric "${tc}-ops" "pass" "${ms}" "ops"

                    ms=$(grep "transferred" "${logfile}" | awk '{print substr($4, 2)}')
                    units=$(grep "transferred" "${logfile}" | awk '{print substr($5,1,length($NF)-1)}')
                    add_metric "${tc}-transfer" "pass" "${ms}" "${units}"
                done
            done
            ;;
        fileio)
            mkdir fileio && cd fileio
            for mode in seqwr seqrewr seqrd rndrd rndwr rndrw; do
                tc="fileio-${mode}"
                logfile="${OUTPUT}/sysbench-${tc}.txt"
                sync
                echo 3 > /proc/sys/vm/drop_caches
                sleep 5
                sysbench --num-threads="${NUM_THREADS}" --test=fileio --file-total-size=2G --file-test-mode="${mode}" prepare
                # --file-extra-flags=direct is needed when file size is smaller then RAM.
                sysbench --num-threads="${NUM_THREADS}" --test=fileio --file-extra-flags=direct --file-total-size=2G --file-test-mode="${mode}" run | tee "${logfile}"
                sysbench --num-threads="${NUM_THREADS}" --test=fileio --file-total-size=2G --file-test-mode="${mode}" cleanup
                print_info $? $mode
                general_parser

                ms=$(grep "transferred" "${logfile}" | awk '{print substr($NF, 2,(length($NF)-8))}')
                units=$(grep "transferred" "${logfile}" | awk '{print substr($NF,(length($NF)-6),6)}')
                add_metric "${tc}-transfer" "pass" "${ms}" "${units}"

                ms=$(grep "Requests/sec" "${logfile}" | awk '{print $1}')
                add_metric "${tc}-ops" "pass" "${ms}" "ops"
            done
            cd ../
            ;;
        oltp)
            # Use the same passwd as lamp and lemp tests.
            mysqladmin -u root password lxmptest  > /dev/null 2>&1 || true
            # Delete sysbench in case it exists.
            mysql --user='root' --password='lxmptest' -e 'DROP DATABASE sysbench' > /dev/null 2>&1 || true
            # Create sysbench database.
            mysql --user="root" --password="lxmptest" -e "CREATE DATABASE sysbench"

            sysbench --num-threads="${NUM_THREADS}" --test=oltp --db-driver=mysql --oltp-table-size=1000000 --mysql-db=sysbench --mysql-user=root --mysql-password=lxmptest prepare
            sysbench --num-threads="${NUM_THREADS}" --test=oltp --db-driver=mysql --oltp-table-size=1000000 --mysql-db=sysbench --mysql-user=root --mysql-password=lxmptest run | tee "${logfile}"

            # Parse test log.
            general_parser

            for i in "read" write other total; do
                ms=$(grep "${i}:" "${logfile}" | awk '{print $NF}')
                add_metric "${tc}-${i}-queries" "pass" "${ms}" "queries"
            done

            for i in transactions deadlocks "read/write requests" "other operations"; do
                ms=$(grep "${i}:" sysbench-oltp.txt | awk '{print substr($(NF-2),2)}')
                i=$(echo "$i" | sed 's/ /-/g')
                add_metric "${tc}-${i}" "pass" "${ms}" "ops"
            done

            # cleanup
            mysql --user='root' --password='lxmptest' -e 'DROP DATABASE sysbench'
            ;;
    esac
done


case "$distro" in
    centos)
	pkg=`rpm -aq|grep sysbench`
	yum remove $pkg -y
	print_info $? remove-sysbench
	;;
    debian)
	apt-get remove sysbench -y	
	print_info $? remove-sysbench
	;;
esac


