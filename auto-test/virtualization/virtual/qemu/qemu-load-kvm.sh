#!/usr/bin/expect

set timeout 30
set IMAGE [lindex $argv 0]
set ROOTFS [lindex $argv 1]
set distro [lindex $argv 2]

if { $distro == "ubuntu" } {
    spawn qemu-system-aarch64 -m 1024 -machine virt -cpu cortex-a57 -nographic -smp 1 -initrd $ROOTFS -kernel $IMAGE --append "console=ttyAMA0"
    } else { 
    spawn qemu-system-aarch64 -m 1024 -machine virt  -cpu cortex-a57 -nographic -smp 1 -initrd $ROOTFS -kernel $IMAGE --append "console=ttyAMA0"
    }

expect "estuary:/$"
expect eof

