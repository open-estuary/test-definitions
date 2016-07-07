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
    echo 'mkdir dir ${QEMU} fail'
    exit 0
fi
cd ${CUR_PATH}/${QEMU}
echo $install_commands
$install_commands qemu qemu-kvm libvirt-bin
if [ $? -ne 0 ]
then
   echo 'install qemu qemu-kvm libvirt-bin fail'
   exit 0
fi
if [[ ! -e ${CUR_PATH}/${IMAGE} || ! -e ${CUR_PATH}/${ROOTFS} ]]
then
   echo '${IMAGE} or ${ROOTFS} not exist'
   exit 0
fi
cp ${CUR_PATH}/${IMAGE} ${CUR_PATH}/${ROOTFS} $PWD/
chmod a+x ${CUR_PATH}/qemu-load-kvm.sh
${CUR_PATH}/qemu-load-kvm.sh
if [ $? -ne 0 ]
then
    echo 'qemu system load fail'
    exit 0
fi
qemu-img create -f qcow2 ubuntu.img 10G
if [ $? -ne 0 ]
then
    echo 'qemu-img create fail'
    exit 0
fi
modprobe nbd max_part=16
if [ $? -ne 0 ]
then
    echo 'modprobe nbd fail'
    exit 0
fi
qemu-nbd -c /dev/nbd0 ubuntu.img
chmod a+x ${CUR_PATH}/qemu-create-partition.sh
${CUR_PATH}/qemu-create-partition.sh
if [ $? -ne 0 ]
then
    echo 'create nbd0 partition fail'
    exit 0
fi
fdisk /dev/nbd0 -l
mkfs.ext4 /dev/nbd0p1
if [ $? -ne 0 ]
then
    echo 'mkfs.ext4 nbd0p1 fail'
    exit 0
fi
mkdir -p /mnt/image
if [ $? -ne 0 ]
then
    echo 'create dir imge fail'
    exit 0
fi
mount /dev/nbd0p1 /mnt/image/
if [ $? -ne 0 ]
then
    echo 'mount image fail'
    exit 0
fi
cd /mnt/image
zcat ${CUR_PATH}/qemu-test/mini-rootfs-arm64.cpio.gz | cpio -dimv
if [ $? -ne 0 ]
then
    echo 'tar file system fail'
    exit 0
fi
cd ${CUR_PATH}/${QEMU}
umount /mnt/image
if [ $? -ne 0 ]
then
    echo 'umount image fail'
    exit 0
fi 
qemu-nbd -d /dev/nbd0
if [ $? -ne 0 ]
then
    echo 'qemu-nbd fail'
#    exit 0
    
fi 
chmod a+x ${CUR_PATH}/qemu-start-kvm.sh
${CUR_PATH}/qemu-start-kvm.sh

