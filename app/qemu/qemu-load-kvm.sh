#!/usr/bin/expect

set timeout 30
set IMAGE [lindex $argv 0]
set ROOTFS [lindex $argv 1]

spawn qemu-system-aarch64 -m 1024 -cpu cortex-a57 -M virt  -nographic -initrd $ROOTFS -kernel $IMAGE -enable-kvm
expect "estuary:/$"
expect eof

