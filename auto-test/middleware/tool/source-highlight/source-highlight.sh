#!/bin/bash
cd ../../../../utils
.            ./sh-test-lib
.            ./sys_info.sh
cd -
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
LOG_FILE="${OUTPUT}/log.txt"
SKIP_INSTALL="no"
VERSION="3.1.8"
SOURCE="Estuary"
SOURCE_FEDORA="fedora"
PACKAGE="source-highlight"
! check_root && error_msg "This script must be run as root"
create_out_dir "${OUTPUT}"
install_source-highlight() {
    dist_name
    # shellcheck disable=SC2154
    case "${dist}" in
      "centos"|"fedora") 
            install_deps "${PACKAGE}" "${SKIP_INSTALL}"
            if test $? -eq 0;then
                 print_info 0 install
            else
                print_info 1 install
                exit 1
            fi
            version=$(yum info ${PACKAGE} | grep "Version" | awk '{print $3}')
            if [ ${version} = ${VERSION} ];then
                 print_info 0 version
            else
                 print_info 1 version
            fi
            sourc=$(yum info ${PACKAGE} | grep "From repo" | awk '{print $4}')
            case "${dist}" in
              "centos") 
                   if [ ${sourc} = ${SOURCE} ];then
                      print_info 0 repo_check
                  else
                      print_info 1 repo_check
                  fi
                  ;;
              "fedora") 
                  if [ ${sourc} = ${SOURCE_FEDORA} ];then
                     print_info 0 repo_check
                 else
                    print_info 1 repo_check                
                 fi
                ;;
              unknown) warn_msg "Unsupported distro" 
                ;;
            esac
        ;;
      "ubuntu") 
            install_deps "${PACKAGE}" "${SKIP_INSTALL}"
            if test $? -eq 0;then
                 print_info 0 install
            else
                print_info 1 install
                exit 1
            fi
            VERSION="3.1.8-1.2"
            version=$( apt-show-versions ${PACKAGE} | grep "source-highlight" | awk '{print $2}')
            if [ ${version} = ${VERSION} ];then
                 print_info 0 version
            else
                 print_info 1 version
            fi
        ;;
      "debian") 
            install_deps "${PACKAGE}" "${SKIP_INSTALL}"
            if test $? -eq 0;then
                 print_info 0 install
            else
                print_info 1 install
                exit 1
            fi
            VERSION_DEBIAN="3.1.8-1.2~deb9u1"
            version=$( apt show ${PACKAGE} | grep "Version" | awk '{print $2}')
            if [ ${version} = ${VERSION_DEBIAN} ];then
                 print_info 0 version
            else
                 print_info 1 version
            fi
        ;;
      "opensuse") 
            install_deps "${PACKAGE}" "${SKIP_INSTALL}"
            if test $? -eq 0;then
                 print_info 0 install
            else
                print_info 1 install
                exit 1
            fi
            version=$(zypper info ${PACKAGE} | grep "Version" | awk '{print $3}')
            VERSION="3.1.8-lp150.1.1"
            if [ ${version} = ${VERSION} ];then
                 print_info 0 version
            else
                 print_info 1 version
            fi
             Repository=$(zypper info ${PACKAGE} | grep "Repository" | awk '{print $3}')
            if [ ${Repository} = ${SOURCE} ];then
                 print_info 0 Repository
            else
                 print_info 1 Repository
            fi
        ;;
     esac
}

install_source-highlight

######################  environment  restore ##########################
remove_deps "${PACKAGE}"
print_info $? remove            
