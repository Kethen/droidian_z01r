echo usb_debug.sh begins > /userdata/usb_debug.log
sync

mkdir /run/configfs
mount -t configfs configfs /run/configfs

mkdir -p /run/configfs/usb_gadget/g1
echo 0x0200 > /run/configfs/usb_gadget/g1/bcdUSB
echo 1 > /run/configfs/usb_gadget/g1/os_desc/use
echo 0x2717 > /run/configfs/usb_gadget/g1/idVendor
echo 0xFF80 > /run/configfs/usb_gadget/g1/idProduct

mkdir -p /run/configfs/usb_gadget/g1/strings/0x409

mkdir -p /run/configfs/usb_gadget/g1/functions/gsi.rndis
 
mkdir -p /run/configfs/usb_gadget/g1/configs/b.1/strings/0x409
echo rndis > /run/configfs/usb_gadget/g1/configs/b.1/strings/0x409/configuration

rm /run/configfs/usb_gadget/g1/configs/b.1/f1
rm /run/configfs/usb_gadget/g1/configs/b.1/f2
rm /run/configfs/usb_gadget/g1/configs/b.1/f3
rm /run/configfs/usb_gadget/g1/configs/b.1/f4
rm /run/configfs/usb_gadget/g1/configs/b.1/f5
rm /run/configfs/usb_gadget/g1/configs/b.1/f6
rm /run/configfs/usb_gadget/g1/configs/b.1/f7
rm /run/configfs/usb_gadget/g1/configs/b.1/f8
rm /run/configfs/usb_gadget/g1/configs/b.1/f9

ln -s /run/configfs/usb_gadget/g1/functions/gsi.rndis /run/configfs/usb_gadget/g1/configs/b.1/f1
echo a600000.dwc3 > /run/configfs/usb_gadget/g1/UDC

ip link list >> /userdata/usb_debug.log
sync

ip addr add 192.168.99.1/24 dev rndis0
ip link set rndis0 up

ip addr list >> /userdata/usb_debug.log

while true
do
	busybox telnetd -F -l /bin/bash 2>&1 | cat >> /userdata/usb_debug.log
done

#reboot -f recovery
