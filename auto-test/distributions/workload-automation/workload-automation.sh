#!/bin/sh -ex
# shellcheck disable=SC1090
set -x
cd ../../utils
   . ./sh-test-lib
   . ./sys_info.sh
cd -
TEST_DIR=$(dirname "$(realpath "$0")")
OUTPUT="${TEST_DIR}/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
#SKIP_INSTALL="false"

WA_TAG="master"
WA_TEMPLATES_REPO="https://git.linaro.org/qa/wa2-lava.git"
TEMPLATES_BRANCH="wa-templates"
CONFIG="config/generic-linux-localhost.py"
AGENDA="agenda/linux-dhrystone.yaml"
if [ `whoami` != 'root' ]; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
#while getopts ":s:t:r:T:c:a:" opt; do
 #   case "${opt}" in
  #      s) SKIP_INSTALL="${OPTARG}" ;;
   #     t) WA_TAG="${OPTARG}" ;;
    #    r) WA_TEMPLATES_REPO="${OPTARG}" ;;
     #   T) TEMPLATES_BRANCH="${OPTARG}" ;;
      #  c) CONFIG="${OPTARG}" ;;
       # a) AGENDA="${OPTARG}" ;;
        #*) usage ;;
    #esac
#done
package1="git wget zip tar xz-utils python python-yaml python-lxml python-setuptools python-numpy python-colorama python-pip sqlite3 time sysstat openssh-client openssh-server sshpass python-jinja2 curl "
package2="git wget zip tar python python-yaml python-lxml python-setuptools python-numpy python-colorama python2-pip sqlite3 time sysstat openssh-client openssh-server sshpass python-jinja2 curl xz "
cd "${TEST_DIR}"
create_out_dir "${OUTPUT}"
case $distro in
    "ubuntu"|"debian")
     install_deps "${package1}"
     print_info $? install-package
     ;;
  "centos")
    install_deps "${package2}"
    print_info $? install-package
    ;;
esac
    pip install --upgrade pip && hash -r
    print_info $? run-hash-r

    pip install --upgrade setuptools

    pip install pexpect pyserial pyyaml docutils python-dateutil
    print_info $? pip-install

    rm -rf workload-automation
    git clone https://github.com/ARM-software/workload-automation
    print_info $? git-clone-workload-automation
    (
    cd workload-automation
    git checkout -b test-branch "${WA_TAG}"
    )
    print_info $? git-checkout-branch
    pip2 install ./workload-automation
    print_info $? pip2-install
    export PATH=$PATH:/usr/local/bin
    which wa
    print_info $? wa-commond
    mkdir -p ~/.workload_automation
    wa --version
    print_info $? wa-version

rm -rf wa-templates
git clone "${WA_TEMPLATES_REPO}" wa-templates
print_info $? git-clone-wa-templates
(
    cd wa-templates
    git checkout "${TEMPLATES_BRANCH}"
    cp "${CONFIG}" ../config.py
    cp "${AGENDA}" ../agenda.yaml
)
print_info $? git-checkout-wa-templates

# Setup root SSH login with password for test run via loopback.
sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^# *PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
grep "PermitRootLogin yes" /etc/ssh/sshd_config
echo "root:linaro123" | chpasswd
/etc/init.d/ssh restart && sleep 3
print_info $? restart-ssh
# Ensure that csv is enabled in result processors.
if ! awk '/result_processors = [[]/,/[]]/' ./config.py | grep -q 'csv'; then
    sed -i "s/result_processors = [[]/result_processors = [\n    'csv',/" ./config.py
fi

wa run ./agenda.yaml -v -f -d "${OUTPUT}/wa" -c ./config.py
 print_info $? wa-run
# Save results from results.csv to result.txt.
# Use id-iteration_metric as test case name.
awk -F',' 'NR>1 {gsub(/[ _]/,"-",$4); printf("%s-itr%s_%s pass %s %s\n",$1,$3,$4,$5,$6)}' "${OUTPUT}/wa/results.csv" \
    | sed 's/\r//g' \
    | tee -a "${RESULT_FILE}"

count=`ps -aux |grep ssh |wc -l`
if [ $count -gt 0 ]; then
    kill -9 ${pidof ssh}
    print_info $? kill-ssh
fi

case $distro in
    "ubuntu"|"debian")
        apt-get remove "${package1}" -y
        print_info $? remove-package
        ;;
    "centos")
       yum remove "${package2}" -y
       print_info $? remove-package
esac
