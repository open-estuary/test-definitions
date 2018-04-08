#!/usr/bin/expect

set timeout 30
set IMAGE [lindex $argv 0]
set ROOTFS [lindex $argv 1]
set DISTRO [lindex $argv 2]

if { $distro == "ubuntu" } {
    spawn qemu-system-aarch64 -m 1024 -cpu host -M virt  -nographic -initrd $ROOTFS -kernel $IMAGE -enable-kvm
    } else { 
    spawn qemu-system-aarch64 -m 1024 -cpu cortex-a57 -M virt  -nographic -initrd $ROOTFS -kernel $IMAGE -enable-kvm
    }

expect "estuary:/$"
expect eof

