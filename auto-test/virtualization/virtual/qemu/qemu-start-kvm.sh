#!/usr/bin/expect

set IMAGE [lindex $argv 0]
set DISK [lindex $argv 1]

spawn qemu-system-aarch64 -machine virt -cpu host -kernel $IMAGE -drive if=none,file=${DISK},id=fs -device virtio-blk-device,drive=fs -append "console=ttyAMA0 root=/dev/vda1" -nographic -D -d -enable-kvm
set timeout 20
expect "estuary:/$"
send "mount -t ext4 -o remount,rw /dev/vda1 /\n"
set timeout 5
expect "re-mounted"
send \x01
send "c\n"
send "quit\n"
expect eof

