#!/bin/bash
. ../../../../utils/sh-test-lib
. ../../../../utils/sys_info.sh
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
LOG_FILE="${OUTPUT}/log.txt"
SKIP_INSTALL="no"
VERSION="3.1"
SOURCE="Estuary"
#PACKAGE="tiptop"

#检查是否为root
! check_root && error_msg "This script must be run as root"
create_out_dir "${OUTPUT}"

#安装包
#install_tiptop() {
    dist_name
    # shellcheck disable=SC2154
    case $distro in
      "centos"|"ubuntu"|"debian") 
            PACKAGE="tiptop"
            install_deps "${PACKAGE}" "${SKIP_INSTALL}"
            if test $? -eq 0;then
                echo "${PACKAGE} install: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "${PACKAGE} install: [FAIL]" | tee -a "${RESULT_FILE}"
                exit 1
            fi
	     print_info $? install-pkgs
	     ;;
            "fedora")
			PACKAGE="tiptop.aarch64"
			install_deps "${PACKAGE}" "${SKIP_INSTALL}"
			if test $? -eq 0;then
		        echo "${PACKAGE} install: [PASS]" | tee -a "${RESULT_FILE}"
			else
			echo "${PACKAGE} install: [FAIL]" | tee -a "${RESULT_FILE}"
			exit 1
			fi
			print_info $? install-pkgs
			;;
esac


#查version
case $distro in
	"centos")
            version=$(yum info ${PACKAGE} | grep "^Version" | awk '{print $3}')
            if [ ${version} = ${VERSION} ];then
                echo "${PACKAGE} version is ${version}: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "${PACKAGE} version is ${version}: [FAIL]" | tee -a "${RESULT_FILE}"
            fi
            print_info $? tiptop-version
#查source
            sourc=$(yum info ${PACKAGE} | grep "^From repo" | awk '{print $4}')
            if [ ${sourc} = ${SOURCE} ];then
                echo "${PACKAGE} source from ${version}: [PASS]" | tee -a "${RESULT_FILE}"
            else
                echo "${PACKAGE} source from ${version}: [FAIL]" | tee -a "${RESULT_FILE}"
            fi
            print_info $? tiptop-source
            ;;
      unknown) warn_msg "Unsupported distro: package install skipped" ;;
      
      
  esac
case $distro in
              "ubuntu")
	          version=$(apt show ${PACKAGE} | grep "^Version" | awk '{print $2}')
	          if [ ${version} = ${VERSION} ];then
	               echo "${PACKAGE} version is ${version}: [PASS]" | tee -a "${RESULT_FILE}"
		   #   print_info $? ${VERSION}
                  else
                #      print_info $? $version
			   echo "${PACKAGE} version is ${version}: [FAIL]" | tee -a "${RESULT_FILE}"
            fi
            print_info $? tiptop-version
#查source
     #       sourc=$(apt show ${PACKAGE} | grep "^From repo" | awk '{print $4}')
#	    if [ ${sourc} = ${SOURCE} ];then
#	       echo "${PACKAGE} source from ${version}: [PASS]" | tee -a "${RESULT_FILE}"
	      # print_info 0 ${SOURCE}
#	    else
#	   echo "${PACKAGE} source from ${version}: [FAIL]" | tee -a "${RESULT_FILE}"
             #print_info 0 ${source}	    
 #           fi
#	    print_info $? tiptop-source
#	    ;;												                
#	    unknown) warn_msg "Unsupported distro: package install skipped" ;;
esac
#查version
case $distro in
	  "fedora")
	     version=$(dnf info ${PACKAGE} | grep "^Version" | awk '{print $3}')
	     if [ ${version} = ${VERSION} ];then
	     echo "${PACKAGE} version is ${version}: [PASS]" | tee -a "${RESULT_FILE}"
	     else
	     echo "${PACKAGE} version is ${version}: [FAIL]" | tee -a "${RESULT_FILE}"
	     fi
	     print_info $? tiptop-version
	     #查source
	     sourc=$(dnf info ${PACKAGE}|grep Repo|awk '{print $3}')
	     if [ ${sourc} = ${SOURCE} ];then
	     echo "${PACKAGE} source from ${version}: [PASS]" | tee -a "${RESULT_FILE}"
            else																							  echo "${PACKAGE} source from ${version}: [FAIL]" | tee -a "${RESULT_FILE}"
	     fi
	     print_info $? tiptop-source
	     ;;
             unknown) warn_msg "Unsupported distro: package install skipped" ;;

     esac

case $distro in
     "debian")
      version=$(apt show ${PACKAGE} | grep "^Version" | awk '{print $2}')
      if [ ${version} = ${VERSION} ];then
      echo "${PACKAGE} version is ${version}: [PASS]" | tee -a "${RESULT_FILE}"
      else
      echo "${PACKAGE} version is ${version}: [FAIL]" | tee -a "${RESULT_FILE}"
      fi
      print_info $? tiptop-version
      sourc=$(apt show ${PACKAGE} | grep Source | awk '{print $3}'|head -1)
      if [ ${sourc} = ${SOURCE} ];then
      echo "${PACKAGE} source from ${version}: [PASS]" | tee -a "${RESULT_FILE}"
      else
      echo "${PACKAGE} source from ${version}: [FAIL]" | tee -a "${RESULT_FILE}"
       fi
      print_info $? tiptop-source
      ;;
       unknown) warn_msg "Unsupported distro: package install skipped" ;;
esac
#卸载安装包
#install_tiptop
remove_deps "${PACKAGE}"
if test $? -eq 0;then
    echo "${PACKAGE} remove: [PASS]" | tee -a "${RESULT_FILE}"
else
    echo "${PACKAGE} remove: [FAIL]" | tee -a "${RESULT_FILE}"
    exit 1
fi
print_info $? remove-pkgs

