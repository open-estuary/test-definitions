
#!/bin/sh -e
set -x
cd ../../../utils
    .     ./sys_info.sh
          ./sh-test-lib
cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

# run slabtop
slabtop
print_info $? slabtop

# adjust delay time
slabtop --delay=5
print_info $? delay

# output one time
slabtop --once
print_info $? once

# check version
slabtop --version
print_info $? version

# help options
slabtop --help
print_info $? help

