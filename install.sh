set -xe

yes | adb shell mkfs.ext4 /dev/block/bootdevice/by-name/system_a
yes | adb shell mkfs.ext4 /dev/block/bootdevice/by-name/system_b
yes | adb shell mkfs.ext4 /dev/block/bootdevice/by-name/userdata

adb shell mkdir /tmp/system_a
adb shell mkdir /tmp/system_b
adb shell mkdir /tmp/userdata

adb shell mount /dev/block/bootdevice/by-name/system_a /tmp/system_a
adb shell mount /dev/block/bootdevice/by-name/system_b /tmp/system_b
adb shell mount /dev/block/bootdevice/by-name/userdata /tmp/userdata
adb shell fallocate -l 10G /tmp/userdata/system.img
adb shell mkfs.ext4 /tmp/userdata/system.img
adb shell mkdir /tmp/userdata/system
adb shell mount /tmp/userdata/system.img /tmp/userdata/system

cat rootfs_out/first_stage.tar | adb shell 'busybox tar -C /tmp/system_a -xv'
cat rootfs_out/first_stage.tar | adb shell 'busybox tar -C /tmp/system_b -xv'
cat rootfs_out/rootfs.tar | adb shell 'busybox tar -C /tmp/userdata/system -xv'

adb shell umount /tmp/system_a
adb shell umount /tmp/system_b
adb shell umount /tmp/userdata/system
adb shell umount /tmp/userdata
adb shell sync

cat boot_out/boot_recovery.img | adb shell 'dd of=/dev/block/bootdevice/by-name/boot_a'
cat boot_out/boot_recovery.img | adb shell 'dd of=/dev/block/bootdevice/by-name/boot_b'
