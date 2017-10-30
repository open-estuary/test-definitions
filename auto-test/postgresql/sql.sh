#! /bin/bash
set -x
datadir=data
log=logfile
cd
pwd

if [ -d /home/${user}/$datadir  ];then
    rm -rf /home/${user}/$datadir
fi
mkdir $datadir
pg_ctl -D $datadir init

pg_ctl -D $datadir -l $log start

pg_ctl -D $datadir status
set +x
exit

