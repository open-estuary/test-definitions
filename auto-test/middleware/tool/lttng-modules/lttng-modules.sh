#!/bin/bash
. ../../lib/sh-test-lib
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
                echo "${PACKAGE} install: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "${PACKAGE} install: [FAIL]" | tee -a "${RESULT_FILE}"
                exit 1
            fi
            version=$(yum info ${PACKAGE} | grep "^Version" | awk '{print $3}')
            if [ ${version} = ${VERSION} ];then
                echo "${PACKAGE} version is ${version}: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "${PACKAGE} version is ${version}: [FAIL]" | tee -a "${RESULT_FILE}"
                exit 1
            fi
            sourc=$(yum info ${PACKAGE} | grep "^From repo" | awk '{print $4}')
            if [ ${sourc} = ${SOURCE} ];then
                echo "${PACKAGE} source from ${version}: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "${PACKAGE} source from ${version}: [FAIL]" | tee -a "${RESULT_FILE}"
                exit 1
            fi
            ;;
      unknown) warn_msg "Unsupported distro: package install skipped" ;;
    esac
}
lttng-modules-test(){
    lttng list -k
    if test $?-eq 0;then
        echo "lttng list: [PASS]" | tee -a "${RESULT_FILE}"
    else
        echo "lttng list: [FAIL]" | tee -a "${RESULT_FILE}"
        exit 1
    fi
    lttng create mysession > log
    cat log | grep "Session mysession created"
    if test $? -eq 0;then
        echo "lttng create session: [PASS]" | tee -a "${RESULT_FILE}"
    else
        echo "lttng create Session: [FAIL]" | tee -a "${RESULT_FILE}"
        exit 1
    fi
    lttng set-session mysession > log
    cat log | grep "Session set to mysession"
    if test $?-eq 0;then
        echo "设置当前追踪会话: [PASS]" | tee -a "${RESULT_FILE}"
    else
        echo "设置当前追踪会话: [FAIL]" | tee -a "${RESULT_FILE}"
        exit 1
    fi
    lttng enable-event -a -k
    if test $?-eq 0;then
        echo "追踪内核所有的探测点和所有的系统调用事件: [PASS]" | tee -a "${RESULT_FILE}"
    else
        echo "追踪内核所有的探测点和所有的系统调用事件: [FAIL]" | tee -a "${RESULT_FILE}"
        exit 1
    fi
    lttng enable-event -a -k --tracepoint
    if test $?-eq 0;then
        echo "追踪内核所有的探测点: [PASS]" | tee -a "${RESULT_FILE}"
    else
        echo "追踪内核所有的探测点: [FAIL]" | tee -a "${RESULT_FILE}"
        exit 1
    fi
    lttng enable-event -a -k --syscall
    if test $?-eq 0;then
        echo "追踪内核所有的系统调用事件: [PASS]" | tee -a "${RESULT_FILE}"
    else
        echo "追踪内核所有的系统调用事件: [FAIL]" | tee -a "${RESULT_FILE}"
        exit 1
    fi
    lttng start
    if test $?-eq 0;then
        echo "开始追踪: [PASS]" | tee -a "${RESULT_FILE}"
    else
        echo "开始追踪: [FAIL]" | tee -a "${RESULT_FILE}"
        exit 1
    fi
    lttng stop
    if test $?-eq 0;then
        echo "停止追踪: [PASS]" | tee -a "${RESULT_FILE}"
    else
        echo "停止追踪: [FAIL]" | tee -a "${RESULT_FILE}"
        exit 1
    fi
    lttng destroy
    if test $?-eq 0;then
        echo "关闭追踪: [PASS]" | tee -a "${RESULT_FILE}"
    else
        echo "关闭追踪: [FAIL]" | tee -a "${RESULT_FILE}"
        exit 1
    fi
}
install_lttng-modules
lttng-modules-test
remove_deps "${PACKAGE}"
if test $? -eq 0;then
    echo "${PACKAGE} remove: [PASS]" | tee -a "${RESULT_FILE}"
else
    echo "${PACKAGE} remove: [FAIL]" | tee -a "${RESULT_FILE}"
    exit 1
fi


