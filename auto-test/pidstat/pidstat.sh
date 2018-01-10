
#!/bin/sh -e
set -x
cd ../../utils
    . ./sys_info.sh
      ./sh-test-lib
cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
# run pidstat
pidstat
print_info $? all-cpu

# statistics cpu usage information
pidstat 2 10
print_info $? cpu-usage

# display cpu usage
pidstat -u 1 2
print_info $? cpu

# display memory usage
pidstat -r 1 2
print_info $? memory

# display IO statistics
pidstat -d 1 2 
print_info $? IO

# check pid usage 
pidstat -p 1 1 
print_info $? pid
