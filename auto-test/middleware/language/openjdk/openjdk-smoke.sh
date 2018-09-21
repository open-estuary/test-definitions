#!/bin/bash
##openjdk是jdk的开放原始码版本
set -x

#####加载外部文件################
. ../../../../utils/sh-test-lib
. ../../../../utils/sys_info.sh 

#############################  Test user id       #########################
! check_root && error_msg "Please run this script as root."

OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
VERSION="8"

export PS4='+{$LINENO:${FUNCNAME[0]}} '


usage() {
    echo "Usage: $0 [-v <8|9>] [-s <true|false>]" 1>&2
    exit 1
}

######################## Environmental preparation   ######################
if [ "${SKIP_INSTALL}" = "True" ] || [ "${SKIP_INSTALL}" = "true" ]; then
    info_msg "JDK package installation skipped"
else
    dist_name
    # shellcheck disable=SC2154
    case "${dist}" in
        debian|ubuntu)
            dist_info
            # shellcheck disable=SC2154
            if [ "${Codename}" = "jessie" ] && [ "${VERSION}" -ge "8" ]; then
                install_deps "-t jessie-backports openjdk-${VERSION}-jdk"
            else
                install_deps "openjdk-${VERSION}-jdk"
            fi
            ;;
        centos|fedora)
            install_deps "java-1.${VERSION}.0-openjdk-devel"
            ;;
        opensuse)
	    install_deps "java-1_${VERSION}_0-openjdk-devel"
	    ;;
        *)
            error_msg "Unsupported distribution"
            ;;
    esac
fi
print_info $? OpenJDK-Install

# Set the specific version as default in case more than one jdk installed.
case $dirstro in
	"ubuntu"|"fedora"|"centos"|"debian")
for link in java javac; do
    path="$(update-alternatives --display "${link}" \
        | egrep "^/usr/lib/jvm/java-(${VERSION}|1.${VERSION}.0)" \
        | awk '{print $1}')"
    update-alternatives --set "${link}" "${path}"
done
;;
esac

case $dirstro in
     "opensuse")
     for link in java javac; do
     path="$(update-alternatives --display "${link}" \
     | egrep "^/usr/lib/jvm/java-(${VERSION}|1_${VERSION}_0)" \
     | awk '{print $1}')"
     update-alternatives --set "${link}" "${path}"
done
     ;;
esac

#######################  testing the step ###########################
#java -version 2>&1 | grep "version \"1.${VERSION}"
java -version 2>&1 | grep "version"
print_info $? OpenJDK-CheckJavaVersion 

javac -version 2>&1 | grep "javac 1.${VERSION}"
print_info $? OpenJDK-CheckJavacVersion


# shellcheck disable=SC2164

cat > "HelloWorld.java" << EOL
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World");
    }
}
EOL
#编译
javac HelloWorld.java 
print_info $?  OpenJDK-compileHelloWorld 
#是否编译成功
java HelloWorld | grep "Hello, World"
if [ $? -eq 0  ];then
    true 
else
    false
fi
print_info $?  OpenJDK-ExecuteHelloWorld 

######################  environment  restore ##########################
if [ "${SKIP_INSTALL}" = "True" ] || [ "${SKIP_INSTALL}" = "true" ]; then
    info_msg "JDK package removing skipped"
else
    dist_name
    # shellcheck disable=SC2154
    case "${dist}" in
        debian|ubuntu)
            dist_info
            # shellcheck disable=SC2154
            if [ "${Codename}" = "jessie" ] && [ "${VERSION}" -ge "8" ]; then
                remove_deps "-t jessie-backports openjdk-${VERSION}-jdk"
            else
                remove_deps "openjdk-${VERSION}-jdk"
            fi
            ;;
        centos|fedora)
            remove_deps "java-1.${VERSION}.0-openjdk-devel"
            ;;
        opensuse)
	    remove_deps "java-1_${VERSION}_0-openjdk-devel"
	    ;;
        *)
            error_msg "Unsupported distribution"
            ;;
    esac
fi
print_info $?  OpenJDK-Remove
