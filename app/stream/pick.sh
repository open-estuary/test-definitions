#!/bin/bash

# Script to read file.
#
# Author: Fengliang <ChinaFengliang@163.com>
# (C) 2013 Huawei Software Engineering.

filename=$1
keyword=$2

key1="STREAM copy bandwidth:"
key2="STREAM scale bandwidth:"
key3="STREAM add bandwidth:"
key4="STREAM triad bandwidth:"
key5="STREAM2 fill bandwidth:"
key6="STREAM2 copy bandwidth:"
key7="STREAM2 daxpy bandwidth:"
key8="STREAM2 sum bandwidth:"

item1=$(grep "${key1}" "${filename}" | sed "s/^.*:[ \t]*\([0-9.]\+\)[ \t]\+.*\$/\1/")
item2=$(grep "${key2}" "${filename}" | sed "s/^.*:[ \t]*\([0-9.]\+\)[ \t]\+.*\$/\1/")
item3=$(grep "${key3}" "${filename}" | sed "s/^.*:[ \t]*\([0-9.]\+\)[ \t]\+.*\$/\1/")
item4=$(grep "${key4}" "${filename}" | sed "s/^.*:[ \t]*\([0-9.]\+\)[ \t]\+.*\$/\1/")
item5=$(grep "${key5}" "${filename}" | sed "s/^.*:[ \t]*\([0-9.]\+\)[ \t]\+.*\$/\1/")
item6=$(grep "${key6}" "${filename}" | sed "s/^.*:[ \t]*\([0-9.]\+\)[ \t]\+.*\$/\1/")
item7=$(grep "${key7}" "${filename}" | sed "s/^.*:[ \t]*\([0-9.]\+\)[ \t]\+.*\$/\1/")
item8=$(grep "${key8}" "${filename}" | sed "s/^.*:[ \t]*\([0-9.]\+\)[ \t]\+.*\$/\1/")

echo "Copy Scale Add Triad Fill Copy2 Daxpy Sum"

for ((i=1; i<11; i++)) do
	s1=$(sed -n "${i}p" <<< "${item1}")
	s2=$(sed -n "${i}p" <<< "${item2}")
	s3=$(sed -n "${i}p" <<< "${item3}")
	s4=$(sed -n "${i}p" <<< "${item4}")
	s5=$(sed -n "${i}p" <<< "${item5}")
	s6=$(sed -n "${i}p" <<< "${item6}")
	s7=$(sed -n "${i}p" <<< "${item7}")
	s8=$(sed -n "${i}p" <<< "${item8}")
	printf "%s %s %s %s %s %s %s %s\n" "${s1}" "${s2}" "${s3}" "${s4}" "${s5}" "${s6}" "${s7}" "${s8}"
done
