#!/bin/sh

echo "Start script create MBR and filesystem"

DEV_EMMC=/dev/mmcblk1

echo "Start backup u-boot default"

dd if="${DEV_EMMC}" of=/boot/u-boot-default.img bs=1M count=4

echo "Start create MBR and partittion"

parted -s "${DEV_EMMC}" mklabel msdos
parted -s "${DEV_EMMC}" mkpart primary fat32 700M 828M
parted -s "${DEV_EMMC}" mkpart primary ext4 829M 100%

echo "Start restore u-boot"

dd if=/boot/u-boot-default.img of="${DEV_EMMC}" conv=fsync bs=1 count=442
dd if=/boot/u-boot-default.img of="${DEV_EMMC}" conv=fsync bs=512 skip=1 seek=1

sync

echo "Done"

exit 0
