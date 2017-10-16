#!/bin/sh

# shellcheck disable=SC1091
. ../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
VERSION="8"

usage() {
    echo "Usage: $0 [-v <8|9>] [-s <true|false>]" 1>&2
    exit 1
}

while getopts "v:s:" o; do
  case "$o" in
    v) VERSION="${OPTARG}" ;;
    s) SKIP_INSTALL="${OPTARG}" ;;
    *) usage ;;
  esac
done

! check_root && error_msg "You need to be root to run this script."
create_out_dir "${OUTPUT}"

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
        *)
            error_msg "Unsupported distribution"
            ;;
    esac
fi

# Set the specific version as default in case more than one jdk installed.
for link in java javac; do
    path="$(update-alternatives --display "${link}" \
        | egrep "^/usr/lib/jvm/java-(${VERSION}|1.${VERSION}.0)" \
        | awk '{print $1}')"
    update-alternatives --set "${link}" "${path}"
done

javaversion=`java -version 2>&1 | grep "version \"1.${VERSION}"`
exit_on_fail "check-java-version"

if [ -z $javaversion  ];then
    lava-test-case OpenJDK-CheckJavaVersion --result pass
else
    lava-test-case OpenJDK-CheckJavaVersion --result fail
fi

javacversion=`javac -version 2>&1 | grep "javac 1.${VERSION}"`
exit_on_fail "check-javac-version"

if [ -z $javacversion  ];then
    lava-test-case OpenJDK-CheckJavacVersion --result pass
else
    lava-test-case OpenJDK-CheckJavacVersion --result fail
fi


# shellcheck disable=SC2164
cd "${OUTPUT}"
cat > "HelloWorld.java" << EOL
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World");
    }
}
EOL

javac=`javac HelloWorld.java`
check_return "compile-HelloWorld"
if [ $javac = 0  ];then
    lava-test-case OpenJDK-compileHelloWorld --result pass
else
    lava-test-case OpenJDK-CompileHelloWorld --result fail
fi

java=`java HelloWorld | grep "Hello, World"`
check_return "execute-HelloWorld"
if [ $java = 0  ];then
    lava-test-case OpenJDK-ExecuteHelloWorld --result pass
else
    lava-test-case OpenJDK-ExecuteHelloWorld --result fail
fi

