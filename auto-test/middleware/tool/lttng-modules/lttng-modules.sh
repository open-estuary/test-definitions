#!/bin/bash
cd ../../../../utils
.            ./sh-test-lib
.            ./sys_info.sh
cd -
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
LOG_FILE="${OUTPUT}/log.txt"
SKIP_INSTALL="no"
VERSION="2.10.3"
SOURCE="Estuary"
PACKAGE="lttng-modules"
! check_root && error_msg "This script must be run as root"
create_out_dir "${OUTPUT}"
install_lttng-modules() {
    dist_name
    # shellcheck disable=SC2154
    case "${dist}" in
      centos) 
            install_deps "lttng-tool" "${SKIP_INSTALL}"
            install_deps "${PACKAGE}" "${SKIP_INSTALL}"
            if test $? -eq 0;then
              print_info 0 install
            else
             print_info 1 install
                exit 1
            fi
            version=$(yum info ${PACKAGE} | grep "^Version" | awk '{print $3}')
            if [ ${version} = ${VERSION} ];then
                 print_info 0 version
            else
                print_info 1 version
                exit 1
            fi
            sourc=$(yum info ${PACKAGE} | grep "^From repo" | awk '{print $4}')
            if [ ${sourc} = ${SOURCE} ];then
                 print_info 0 repo_check
            else
                print_info 1 repo_check
                exit 1
            fi
            ;;
      unknown) warn_msg "Unsupported distro: package install skipped" ;;
    esac
}
lttng-modules-test(){
    lttng list -k
    if test $?-eq 0;then
        print_info 0 list
    else
       print_info 1 list
        exit 1
    fi
    lttng create mysession > log
    cat log | grep "Session mysession created"
    if test $? -eq 0;then
        print_info 0 create_session
    else
        print_info 1 create_session
        exit 1
    fi
    lttng set-session mysession > log
    cat log | grep "Session set to mysession"
    if test $?-eq 0;then
        print_info 0 set_session
    else
        print_info 1 set_session
        exit 1
    fi
    lttng enable-event -a -k
    if test $?-eq 0;then
        print_info 0 enable_event
    else
        print_info 1 enable_event
        exit 1
    fi
    lttng enable-event -a -k --tracepoint
    if test $?-eq 0;then
        print_info 0 event_trace
    else
        print_info 1 event_trace
        exit 1
    fi
    lttng enable-event -a -k --syscall
    if test $?-eq 0;then
        print_info 0 event_syscall
    else
        print_info 1 event_syscall
        exit 1
    fi
    lttng start
    if test $?-eq 0;then
        print_info 0 start
    else
        print_info 1 start
        exit 1
    fi
    lttng stop
    if test $?-eq 0;then
        print_info 0 stop
    else
        print_info 1 stop
        exit 1
    fi
    lttng destroy
    if test $?-eq 0;then
        print_info 0 destroy
    else
        print_info 1 destroy
        exit 1
    fi
}
install_lttng-modules
lttng-modules-test
remove_deps "${PACKAGE}"
if test $? -eq 0;then
    print_info 0 remove
else
    print_info 1 remove
    exit 1
fi


