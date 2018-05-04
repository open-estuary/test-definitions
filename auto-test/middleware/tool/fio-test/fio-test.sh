#!/bin/sh 

# shellcheck disable=SC1091
cd ../../../../utils
.            ./sh-test-lib
.            ./sys_info.sh
cd -
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE
PARTITION=""
IOENGINE="sync"
BLOCK_SIZE="4k"

usage() {
    echo "Usage: $0 [-p <partition>] [-b <block_size>] [-i <sync|psync|libaio>]
                    [-s <true|false>]" 1>&2
    exit 1
}

while getopts "p:b:i:s:" o; do
  case "$o" in
    # The current working directory will be used by default.
    # Use '-p' specify partition that used for fio test.
    p) PARTITION="${OPTARG}" ;;
    b) BLOCK_SIZE="${OPTARG}" ;;
    i) IOENGINE="${OPTARG}" ;;
    s) SKIP_INSTALL="${OPTARG}" ;;
    *) usage ;;
  esac
done

install() {
    dist_name
    # shellcheck disable=SC2154
    case "${dist}" in
      debian | ubuntu )
        pkgs="fio"
        install_deps "${pkgs}" "${SKIP_INSTALL}"
        print_info $? install 
        ;;
      fedora | centos )
        pkgs="libaio-devel gcc wget fio"
        install_deps "${pkgs}" "${SKIP_INSTALL}"
        print_info $? install
        ;;
      opensuse )
        zypper install -y fio
      # When build do not have package manager
      # Assume development tools pre-installed
      # fio_build_install
        ;;
    esac
}
version="3.1"
from_repo="epel"
package="fio"

for P in ${package};do
    echo "$P install"
# Check the package version && source
from=$(yum info $P | grep "From repo" | awk '{print $4}')
if [ "$from" = "$from_repo"  ];then
     print_info 0 repo_check
else
     rmflag=1
      if [ "$from" != "Estuary"  ];then
           yum remove -y $P
            yum install -y $P
             from=$(yum info $P | grep "From repo" | awk '{print $4}')
             if [ "$from" = "$from_repo"   ];then
                   print_info 0 repo_check
            else
                  print_info 1 repo_check
           fi
    fi
fi

vers=$(yum info $P | grep "Version" | awk '{print $3}')
if [ "$vers" = "$version"   ];then
      print_info 0 version
else
      print_info 1 version
fi
done

fio_test() {
    # shellcheck disable=SC2039
    local rw="$1"
    file="${OUTPUT}/fio-${BLOCK_SIZE}-${rw}.txt"

    # Run fio test.
    echo
    info_msg "Running fio ${BLOCK_SIZE} ${rw} test ..."
    fio -name="${rw}" -rw="${rw}" -bs="${BLOCK_SIZE}" -size=1G -runtime=60 \
        -numjobs=1 -ioengine="${IOENGINE}" -direct=1 -group_reporting \
        -output="${file}"
    print_info $? fio_test_${rw}
    echo

    # Parse output.
    cat "${file}"
    measurement=$(grep -m 1 "iops=" "${file}" | cut -d= -f4 | cut -d, -f1)
    add_metric "fio-${rw}" "pass" "${measurement}" "iops"
    print_info $? info_fio_test_${rw}
    # Delete files created by fio to avoid out of space.
    rm -rf ./"${rw}"*
}

# Config test.
! check_root && error_msg "This script must be run as root"
create_out_dir "${OUTPUT}"

# Enter test directory.
if [ -n "${PARTITION}" ]; then
    if [ -b "${PARTITION}" ]; then
        if df | grep "${PARTITION}"; then
            mount_point=$(df | grep "${PARTITION}" | awk '{print $NF}')
        else
            mount_point="/media/fio"
            mkdir -p "${mount_point}"
            umount "${mount_point}" > /dev/null 2>&1 || true
            mount "${PARTITION}" "${mount_point}" && \
                info_msg "${PARTITION} mounted to ${mount_point}"
            df | grep "${PARTITION}"
        fi
        cd "${mount_point}"
    else
        error_msg "Block device ${PARTITION} NOT found"
    fi
fi

# Install and run fio test.
install
info_msg "About to run fio test..."
info_msg "Output directory: ${OUTPUT}"
info_msg "fio test directory: $(pwd)"
for rw in "read" randread write randwrite rw randrw; do
    fio_test "${rw}"
done

#Remove fio package
remove_deps "${pkgs}"
print_info $? remove

