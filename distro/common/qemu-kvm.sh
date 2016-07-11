#!/bin/bash
pushd ./utils
. ./sys_info.sh
popd
QEMU='qemu-test'
IMAGE='Image_D02'
ROOTFS='mini-rootfs-arm64.cpio.gz'
HOME_PATH=$HOME
CUR_PATH=$PWD
set -x
chmod a+x ./expect-install.sh
./expect-install.sh
mkdir -p /${CUR_PATH}/${QEMU}
if [ ! -e ${CUR_PATH}/${QEMU} ]
then
   # echo 'mkdir dir ${QEMU} fail'
    lava-test-case mkdir-qemu-test --result fail 
    exit 0
else
    lava-test-case mkdir-qemu-test --result pass
fi
cd ${CUR_PATH}/${QEMU}
echo $install_commands
$install_commands qemu qemu-kvm libvirt-bin
if [ $? -ne 0 ]
then
   echo 'install qemu qemu-kvm libvirt-bin fail'
   lava-test-case install-qemu-kvm --result fail
   exit 0
else
   lava-test-case install-qemu-kvm --result pass
fi
if [[ ! -e ${CUR_PATH}/${IMAGE} || ! -e ${CUR_PATH}/${ROOTFS} ]]
then
   echo '${IMAGE} or ${ROOTFS} not exist'
   lava-test-case imge_or_rootfs_exist --result fail
   exit 0
else
   lava-test-case imge_or_rootfs_exist --result pass
fi
cp ${CUR_PATH}/${IMAGE} ${CUR_PATH}/${ROOTFS} $PWD/
chmod a+x ${CUR_PATH}/qemu-load-kvm.sh
${CUR_PATH}/qemu-load-kvm.sh
if [ $? -ne 0 ]
then
    echo 'qemu system load fail'
    lava-test-case qemu-system-load --result fail
    exit 0
ystem-loadlse
    lava-test-case qemu-system-load --esult pass
fi
qemu-img create -f qcow2 ubuntu.img 10G
if [ $? -ne 0 ]
then
    echo 'qemu-img create fail'
    lava-test-case qemu-img-create --result fail
    exit 0
else
   lava-test-case qemu-img-create --result pass
fi
modprobe nbd max_part=16
if [ $? -ne 0 ]
then
    echo 'modprobe nbd fail'
    lava-test-case modprob-nbd --result fail
    exit 0
else
    lava-test-case modprobe-nbd --result pass
fi
qemu-nbd -c /dev/nbd0 ubuntu.img
chmod a+x ${CUR_PATH}/qemu-create-partition.sh
${CUR_PATH}/qemu-create-partition.sh
if [ $? -ne 0 ]
then
    echo 'create nbd0 partition fail'
    lava-test-case create-partition --result fail
    exit 0
else
    lava-test-case create-partition --result pass
fi
fdisk /dev/nbd0 -l
mkfs.ext4 /dev/nbd0p1
if [ $? -ne 0 ]
then
    echo 'mkfs.ext4 nbd0p1 fail'
    lava-test-case mkfs.ext4-nbd0p1 --result fail
    exit 0
else
    lava-test-case mkfs.ext4-nbd0p1 --result pass
fi
mkdir -p /mnt/image
if [ $? -ne 0 ]
then
    echo 'create dir imge fail'
    lava-test-case create-image-dir --result fail
    exit 0
else
    lava-test-case create-image-dir --result pass
fi
mount /dev/nbd0p1 /mnt/image/
if [ $? -ne 0 ]
then
    echo 'mount image fail'
    lava-test-case mount-image --result fail
    exit 0
else
    lava-test-case mount-image --result pass
fi
cd /mnt/image
zcat ${CUR_PATH}/qemu-test/mini-rootfs-arm64.cpio.gz | cpio -dimv
if [ $? -ne 0 ]
then
    echo 'tar file system fail'
    lava-test-case tar-file-system --result fail
    exit 0
else
    lava-test-case tar-file-system --result pass
fi
cd ${CUR_PATH}/${QEMU}
umount /mnt/image
if [ $? -ne 0 ]
then
    echo 'umount image fail'
    lava-test-case umount-image --result fail
    exit 0
else
    lava-test-case umount-image --result fail
fi 
qemu-nbd -d /dev/nbd0
if [ $? -ne 0 ]
then
    echo 'qemu-nbd fail'
    lava-test-case qemu-nbd --result fail
    exit 0
else
    lava-test-case qemu-nbd --result pass    
fi 
chmod a+x ${CUR_PATH}/qemu-start-kvm.sh
${CUR_PATH}/qemu-start-kvm.sh
