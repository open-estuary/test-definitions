#!/bin/bash

cd lmbench-3.0-a9/bin/lmbench

function stream_test() {
        echo ": streamv2core0"
        numactl -C 0 --localalloc ./stream -v 1 -M 200M -P 1
        numactl -C 0 --localalloc ./stream -v 2 -M 200M -P 1
        echo ": streamv2core0-3"
        numactl -C 0-3 --localalloc ./stream -v 1 -M 200M -P 4
        numactl -C 0-3 --localalloc ./stream -v 2 -M 200M -P 4
        echo ": streamv2core0-15"
        numactl --cpunodebind=0 --localalloc ./stream -v 1 -M 200M -P 16
        numactl --cpunodebind=0 --localalloc ./stream -v 2 -M 200M -P 16
        echo ": streamv2core0-31"
        numactl --cpunodebind=0,1 --localalloc ./stream -v 1 -M 200M -P 32
        numactl --cpunodebind=0,1 --localalloc ./stream -v 2 -M 200M -P 32
        echo ": streamv2core32-63"
        numactl --cpunodebind=2,3 --localalloc ./stream -v 1 -M 200M -P 32
        numactl --cpunodebind=2,3 --localalloc ./stream -v 2 -M 200M -P 32
        echo ": streamv2core0-63"
        numactl --cpunodebind=0,1,2,3 --localalloc ./stream -v 1 -M 200M -P 64
        numactl --cpunodebind=0,1,2,3 --localalloc ./stream -v 2 -M 200M -P 64
}

function stream_test_64core() {
        echo ": streamv2core0-63"
        numactl --cpunodebind=0,1,2,3 --localalloc ./stream -v 1 -M 200M -P 64
        numactl --cpunodebind=0,1,2,3 --localalloc ./stream -v 2 -M 200M -P 64
}
for ((i=0;i<10;i++));do
	stream_test_64core
done
