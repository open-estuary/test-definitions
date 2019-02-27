#!/bin/bash

#=================================================
# Global variable
GLOBAL_BASH_PID=$$



#=================================================

MODULE_NAME="`basename $0 | sed 's/\.sh$//g'`"
ABSOLUATELY_PATH=`pwd`

SCRIPT_PATH="`dirname $0`"
if [ "$SCRIPT_PATH" = "." ]
then
    SCRIPT_PATH=`pwd`
fi



HOME_PATH=`dirname ${SCRIPT_PATH}`
FILENAME=${0##*/}
DATE_PLUS_INFO="`date '+%Y%m%d%H%M%S'`"
RANDOM_INFO="${DATE_PLUS_INFO}${RANDOM}"
LOGPATH="${SCRIPT_PATH}/logs/${MODULE_NAME}"
THELOGFILE="${LOGPATH}/${MODULE_NAME}.log"

TMPDIR=${SCRIPT_PATH}/logs/temp
mkdir -p ${TMPDIR}
TMPFILE=${TMPDIR}/${FILENAME%%.*}.tmp
TMPCFG=${TMPDIR}/${FILENAME%%.*}.tmp_cfg
RESULT_FILE=${TMPDIR}/${FILENAME%%.*}.result

printf "%s %s %-50s %s\n" `date "+[%F %T]"` $0 ${LOGFILE:-${THELOGFILE}} >> /var/bash.trc
[ "`wc -l /var/bash.trc | awk '{ print $1 }'`" -gt 1200 ] && \
sed -i 1,200d  /var/bash.trc


#**************************************************************
# Name:        getSysTime                                     *
# Description: get the system time   2019-01-10 03:52:33      *
#**************************************************************
function fn_getSysTime()
{
    date "+%Y-%m-%d %T"
}


#**************************************************************
# Name:         LOG                                           *
# Description: record the message into the logfile            *
# Inout:  log message                                         *
#**************************************************************
function LOG()
{
    local strTime=`fn_getSysTime`
    local curSize
    local maxSize=10240
    local maxRecord=3
    local index=2
    local content="$*"
    

    if [ -z ${LOGFILE} ]
    then
        echo  -e "[${strTime}] [${GLOBAL_BASH_PID}] ${content}"
    elif [  -f ${LOGFILE} ]
    then
        curSize=`ls -lk ${LOGFILE} | awk -F" " '{print $5}'`
        if [ ${curSize} -ge ${maxSize} ]
        then
            while [ ${index} -gt 0 ]
            do
                if [ -f ${LOGFILE}.${index} ]
                then
                    mv ${LOGFILE}.${index} ${LOGFILE}.`expr ${index} + 1`

                fi
                let index--
            done
            mv ${LOGFILE} ${LOGFILE}.1
        fi
        echo -e  "[${strTime}] [${GLOBAL_BASH_PID}] ${content}" | tee -a ${LOGFILE}    
    else
        mkdir -p `dirname ${LOGFILE}`
        chmod 750 `dirname ${LOGFILE}`
        echo -e "[${strTime}] [${GLOBAL_BASH_PID}] ${content}" | tee -a ${LOGFILE}
    fi
}


#**************************************************************
# Name:        WARN                                           *
# Description: record the warning message into the logfile    *
# Inout:  warning message                                     *
#**************************************************************
function WARN()
{
    LOG "WARN: $*"
}


#**************************************************************
# Name:        ERROR                                          *
# Description: record the error message into the logfile      *
# Inout:  error message                                       *
#**************************************************************
function ERROR()
{
    LOG "ERROR: $*"
}


##*************************************************************
# Name        : PRINT_LOG                                     *
# Description : print log                                     *
# Parameters  : $1 the print level                            *
# Parameters  : $2 the log                                    *
#**************************************************************
function PRINT_LOG()
{
    local LOG_LEVEL=$1
    local LOG_INFO=$2

    if [ -z "${LOGFILE}" ]
    then
        LOGFILE="${THELOGFILE}"
    fi

    case ${LOG_LEVEL} in
        "INFO")
            LOG "${LOG_INFO}"
        ;;
        "WARN")
            WARN "${LOG_INFO}"
        ;;
        "FATAL")
            ERROR "[Line-${BASH_LINENO}] ${LOG_INFO}"
        ;;
        *)
            WARN " The LOG_LEVEL must be <INFO|WARN|FATAL>, it will be set to WARN by default.."
            WARN "${LOG_INFO}"
        ;;
    esac
}
#**************************************************************
# Name        : PRINT_FILE_TO_LOG                             *
# Description : print file content into log file              *
# Parameters  : $1 the file to be printed                     *
#**************************************************************
function PRINT_FILE_TO_LOG()
{
    local FILE_NAME=$1

    if [ -z "${LOGFILE}" ]
    then
        LOGFILE="${THELOGFILE}"
    fi

    if [ -f "${FILE_NAME}" ]
    then
        CHECK_CONTENT=`cat ${FILE_NAME}`
        if [ -z "${CHECK_CONTENT}" ]
        then
            LOG "This file FILE_NAME<${FILE_NAME}> is empty!!!"
            return ${ERR_FILEISNULL};
        else
            LOG "Print <${FILE_NAME}>"
            LOG "`cat \"${FILE_NAME}\" | sed 's/\r//g'`"
        fi
    else
        LOG "This file FILE_NAME<${FILE_NAME}> is not exist!!!"
        return ${ERR_FILEEXIST};
    fi
}



#*************************************************************
# Name        : fn_get_value                                 *
# Description : get the config from config file              *
# Parameters  : $1 the absoluately path of config file       *
# Parameter   : $2 the key name                              *
#*************************************************************
function fn_get_value()
{
    local TMP_CONFIG_FILE=$1
    local TMP_KEY_NAME=$2
    
    [ ! -f "${TMP_CONFIG_FILE}" ] && { ERROR "The file TMP_CONFIG_FILE<${TMP_CONFIG_FILE}> is not exist" &>/dev/null; return ${ERROR_PARAM}; }   
    cat "${TMP_CONFIG_FILE}" | grep -m1 "^${TMP_KEY_NAME}=" | awk 'BEGIN {FS="="}{print $2}'
    
}


#*************************************************************
# Name        : fn_writeResultFile                           *
# Description : write result to result file                  *
# Parameters  : $1 result file                               *
# Parameter   : $2 the key                                   *
# Parameter   : $3 the value                                 *
#*************************************************************
function fn_writeResultFile()
{
    local RESULT_FILE=$1
    local RESULT_NAME=$2
    local RESULT_VALUE=$3

    if [ $# -ne 3 ]
    then
        ERROR "[fn_writeResultFile]Parameter number is correct."
    fi

    echo -e  "${RESULT_NAME}=${RESULT_VALUE}" | tee -a ${RESULT_FILE}
    if [ $? -ne 0 ]
    then
        ERROR "Failed to write \"${RESULT_NAME}=${RESULT_VALUE}\" to ${RESULT_FILE}."
        return ${ERR_EXECSYS}
    else
        LOG "Success to write \"${RESULT_NAME}=${RESULT_VALUE}\" to ${RESULT_FILE}."
        return 0;
    fi
}

#*************************************************************
# Name        : fn_checkResultFile                           *
# Description : create result file                           *
# Parameters  : $1 result file                               *
#*************************************************************
function fn_checkResultFile()
{
    local RESULT_FILE=$1
    local RESULT_PATH

    if [ ! -f "${RESULT_FILE}" ]
    then
        RESULT_PATH=`dirname "${RESULT_FILE}"`
        if [ ! -d "${RESULT_PATH}" ]
        then
            mkdir -p "${RESULT_PATH}"
        fi
    fi

    rm -f "${RESULT_FILE}"
    touch "${RESULT_FILE}"
    if [ $? -ne 0 ]
    then
        ERROR "FUNC:fn_checkResultFile execute touch command fail."
        return ${ERR_EXECSYS}
    fi

    LOG "Success to create ${RESULT_FILE} file"
    return 0
}


#*************************************************************
#Name         :check result                                  *
#Description  :check test case items result                  *
#Parameters   :result file                                   *
#*************************************************************
function check_result()
{
    result_file=$1
    PRINT_FILE_TO_LOG "${result_file}"
    cat ${result_file} | awk -F"=" '{print $2}' | egrep -v "pass"
    if [ $? -eq 0 ]
	then
		PRINT_LOG "FATAL" "Test case <${test_name}>  is fail ,please check it !"
		return 1
	else
		PRINT_LOG "INFO" "Test case <${test_name}> is success."
		return 0
	fi
}

#*************************************************************
#Name         :clean tmp file                                *
#Description  :clean script product tmp_file                 *
#Parameters   :NO                                            *
#*************************************************************
function FUNC_CLEAN_TMP_FILE()
{
    [ -e "${TMPFILE}" ] && rm -f "${TMPFILE}" > /dev/null 2>&1
    [ -e "${TMPCFG}" ]&& rm -f "${TMPCFG}" > /dev/null 2>&1
    [ -d "${TMPDIR}" ] && rm -rf "${TMPDIR}" > /dev/null 2>&1
    return 0
}




