#!/bin/sh

echo "Start copy system for DATA partition."

mkdir -p /ddbr
chmod 777 /ddbr

VER=`uname -r`

IMAGE_KERNEL="/boot/zImage"
IMAGE_INITRD="/boot/initrd.img-$VER"
PART_ROOT="/dev/data"
DIR_INSTALL="/ddbr/install"
IMAGE_DTB="/boot/dtb.img"


if [ ! -f $IMAGE_KERNEL ] ; then
    echo "Not KERNEL.  STOP install !!!"
    return
fi

if [ ! -f $IMAGE_INITRD ] ; then
    echo "Not INITRD.  STOP install !!!"
    return
fi


echo "Formatting DATA partition..."
umount -f $PART_ROOT
mke2fs -F -q -t ext4 -m 0 $PART_ROOT
e2fsck -n $PART_ROOT
echo "done."

echo "Copying ROOTFS."

if [ -d $DIR_INSTALL ] ; then
    rm -rf $DIR_INSTALL
fi

mkdir -p $DIR_INSTALL
mount -o rw $PART_ROOT $DIR_INSTALL

cd /
echo "Copy BIN"
tar -cf - bin | (cd $DIR_INSTALL; tar -xpf -)
echo "Copy BOOT"
#mkdir -p $DIR_INSTALL/boot
tar -cf - boot | (cd $DIR_INSTALL; tar -xpf -)
echo "Create DEV"
mkdir -p $DIR_INSTALL/dev
#tar -cf - dev | (cd $DIR_INSTALL; tar -xpf -)
echo "Copy ETC"
tar -cf - etc | (cd $DIR_INSTALL; tar -xpf -)
echo "Copy HOME"
tar -cf - home | (cd $DIR_INSTALL; tar -xpf -)
echo "Copy LIB"
tar -cf - lib | (cd $DIR_INSTALL; tar -xpf -)
echo "Create MEDIA"
mkdir -p $DIR_INSTALL/media
#tar -cf - media | (cd $DIR_INSTALL; tar -xpf -)
echo "Create MNT"
mkdir -p $DIR_INSTALL/mnt
#tar -cf - mnt | (cd $DIR_INSTALL; tar -xpf -)
echo "Copy OPT"
tar -cf - opt | (cd $DIR_INSTALL; tar -xpf -)
echo "Create PROC"
mkdir -p $DIR_INSTALL/proc
echo "Copy ROOT"
tar -cf - root | (cd $DIR_INSTALL; tar -xpf -)
echo "Create RUN"
mkdir -p $DIR_INSTALL/run
echo "Copy SBIN"
tar -cf - sbin | (cd $DIR_INSTALL; tar -xpf -)
echo "Copy SELINUX"
tar -cf - selinux | (cd $DIR_INSTALL; tar -xpf -)
echo "Copy SRV"
tar -cf - srv | (cd $DIR_INSTALL; tar -xpf -)
echo "Create SYS"
mkdir -p $DIR_INSTALL/sys
echo "Create TMP"
mkdir -p $DIR_INSTALL/tmp
echo "Copy USR"
tar -cf - usr | (cd $DIR_INSTALL; tar -xpf -)
echo "Copy VAR"
tar -cf - var | (cd $DIR_INSTALL; tar -xpf -)

echo "Copy fstab"

rm $DIR_INSTALL/etc/fstab
cp -a /root/fstab $DIR_INSTALL/etc
#cp -a /boot/hdmi.sh $DIR_INSTALL/boot

rm $DIR_INSTALL/root/install.sh
rm $DIR_INSTALL/root/fstab
rm $DIR_INSTALL/usr/bin/ddbr
rm $DIR_INSTALL/usr/bin/ddbr_backup_nand
rm $DIR_INSTALL/usr/bin/ddbr_restore_nand

cd /
sync

umount $DIR_INSTALL

echo "*******************************************"
echo "Done copy ROOTFS"
echo "*******************************************"

echo "Writing new kernel image..."

mkdir -p $DIR_INSTALL/aboot
cd $DIR_INSTALL/aboot
dd if=/dev/boot of=boot.backup.img
abootimg -i /dev/boot > aboot.txt
abootimg -x /dev/boot
abootimg -u /dev/boot -k $IMAGE_KERNEL
abootimg -u /dev/boot -r $IMAGE_INITRD

echo "done."

if [ -f $IMAGE_DTB ] ; then
#    abootimg -u /dev/boot -s $IMAGE_DTB
    echo "Writing new dtb ..."
    dd if="$IMAGE_DTB" of="/dev/dtb" bs=262144 status=none && sync
    echo "done."
fi

echo "Write env bootargs"
/usr/sbin/fw_setenv initargs "root=/dev/data rootflags=data=writeback rw console=ttyS0,115200n8 console=tty0 no_console_suspend consoleblank=0 fsck.repair=yes net.ifnames=0 mac=\${mac}"

echo "*******************************************"
echo "Complete copy OS to eMMC parted DATA"
echo "*******************************************"
