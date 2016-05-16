#!/bin/bash

pushd ./utils
. ./sys_info.sh
popd
log_file="mysql_sysbench.log"

set -x

function install_softwares()
{
    declare -A distro_softname_dic
    ubuntu_list='libtool autoconf automake libmysqlclient-dev mysql-client libmysqld-dev bzr expect'
    opensuse_list='bzr'
    debian_list='bzr'
    centos_list='bzr'
    fedora_list='bzr'
    distro_softname_dic=([ubuntu]=$ubuntu_list [opensuse]=$opensuse_list [debian]=$debian_list [centos]=$centos_list [fedora]=$fedora_list)
    softwares=${distro_softname_dic[$distro]}
    echo $update_commands
    echo $softwares
    . ./utils/install_update_soft.sh "$update_commands" "$install_commands" "$softwares" $log_file $distro
    [ $? -ne 0 ] && echo -1
}

sysbench_dir=sysbench-0.5
cpu_num=$(grep 'processor' /proc/cpuinfo |sort |uniq |wc -l)

db_driver=mysql
: ${mysql_user:=$1}
: ${mysql_user:=root}
: ${mysql_password:=$2}
: ${mysql_password:=123456}
: ${mysql_table_engine:=$3}
: ${mysql_table_engine:=innodb}
: ${oltp_table_size:=$4}
: ${oltp_table_size:=10000}
: ${oltp_tables_count:=$5}
: ${oltp_tables_count:=8}
#: ${num_threads:=$6}
: ${num_threads:=$((cpu_num*2))}
: ${mysql_host:=$7}
: ${mysql_host:=localhost}
: ${mysql_port:=$8}
: ${mysql_port:=33306}
: ${db_name:=$9}
: ${db_name:=sbtest}
#: ${max_requests:=$10}
: ${max_requests:=100000}
test_name="oltp"
echo "max_requests are $max_requests"

$install_commands 'expect'
./utils/${distro}_expect_mysql.sh $mysql_password | tee ${log_file}
install_softwares

mysql_version=$(mysql --version | awk '{ print $1"-" $2 ": " $3}')
exists=$(echo $mysql_version|awk -F":" '{print $1}')
if [ "$exists"x = "mysql-Ver"x ]; then
    echo "Found  $mysql_version  installed"
else
    echo "The mysql server has not been installed,Please install mysql,Refe caliper documentation"
    exit 1
fi

mysql_location=$(whereis mysql)

declare -a mysql_loc
read -a mysql_loc <<< $(echo $mysql_location)

for j in ${mysql_loc[@]}
do
echo $j
done

$install_commands sysbench  | tee ${log_file}
sysbench --test=cpu help
if [ $? -ne 0 ]; then
    echo 'sysbench has not been installed success'
    exit 1
fi

/usr/bin/expect > /dev/null 2>&1 <<EOF
set timeout 40

spawn mysql -u$mysql_user -p
expect "*password:"
send "$mysql_password\r"
expect "mysql>"
send "show databases;\r"

expect {
 "$db_name"
 {
     send "drop database $db_name;\r"
     expect "mysql>"
     send "create database $db_name;\r"
     expect "mysql>"
 }
 "mysql>"
 {
     send "create database $db_name;\r"
 }
}
expect "mysql>"
send "quit;\r"
expect eof
EOF

if [ $max_requests -eq 0 ]; then 
    max_requests=100000
fi
set -x

# --oltp-tables-count=$oltp_tables_count \
sys_str="sysbench \
  --db-driver=mysql \
  --mysql-table-engine=innodb \
  --oltp-table-size=$oltp_table_size \
  --num-threads=$num_threads \
  --mysql-host=$mysql_host \
  --mysql-user=$mysql_user \
  --mysql-password=$mysql_password \
  --max-requests=$max_requests\
  --test=$test_name \
  "
# prepare the test data
$sys_str  prepare  | tee ${log_file}
if [ $? -ne 0 ]; then
    echo "Prepare the oltp test data failed"
    exit 1
else
    echo "prepare the oltp test data pass"
fi

# do the oltp test
$sys_str run | tee ${log_file}
if [ $? -ne 0 ]; then
    echo "Run the oltp test failed"
    exit 1
else
    echo "run the oltp test pass"
fi

# cleanup the test data
$sys_str  cleanup | tee ${log_file}
if [ $? -ne 0 ]; then
    echo "cleanup the test data failed"
    exit 1
else
    echo "cleanup the test data pass"
fi
