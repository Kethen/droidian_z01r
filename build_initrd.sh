set -xe

IMAGE=debian_z01r_kernel

if ! podman image exists $IMAGE
then
	podman image build --arch=amd64 -t $IMAGE -f Dockerfile_kernel
fi

if ! [ -e mkbootimg ]
then
	wget https://raw.githubusercontent.com/LineageOS/android_system_tools_mkbootimg/lineage-19.1/mkbootimg.py -O mkbootimg
	chmod 755 mkbootimg
fi

mkdir -p boot_out

podman run \
	--rm -it \
	-v ./boot_out:/boot_out \
	-v ./:/work_dir:ro \
	-w /work_dir \
	-v ./boot_out:/boot_out \
	$IMAGE \
	bash -c '
	set -xe

	./mkbootimg \
		--kernel kbuild/arch/arm64/boot/Image.gz-dtb \
		--ramdisk ramdisk-recovery.img \
		--base 0x0 \
		--kernel_offset 0x100 \
		--ramdisk_offset 0x1000000 \
		--second_offset 0x0 \
		--tags_offset 0x100 \
		--pagesize 4096 \
		--cmdline "androidboot.hardware=qcom androidboot.console=ttyMSM0 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 service_locator.enable=1 swiotlb=2048 androidboot.configfs=true androidboot.usbcontroller=a600000.dwc3 loop.max_part=7 console=tty0 systemd.log_level=debug systemd.default_standard_output=kmsg systemd.log_target=kmsg systemd.journald.forward_to_kmsg=1 systemd.log_ratelimit_kmsg=0" \
		-o /boot_out/boot_recovery.img \
		--os_version 11 \
		--os_patch_level 2024-02 \
		--recovery_dtbo dtbo.img \
		--header_version 0
'

EXTRAS="systemd.log_level=debug systemd.default_standard_output=kmsg systemd.log_target=kmsg systemd.journald.forward_to_kmsg=1 systemd.log_ratelimit_kmsg=0"
