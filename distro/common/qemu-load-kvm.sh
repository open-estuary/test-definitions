#!/usr/bin/expect -f
spawn qemu-system-aarch64 -m 1024 -cpu cortex-a57 -M virt  -nographic -initrd mini-rootfs-arm64.cpio.gz -kernel   Image_D02  -enable-kvm
set timeout 30
expect "estuary:/$"
expect eof

