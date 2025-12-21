set -xe

IMAGE=localhost/droidian_z01r

if ! [ -e vendor.img ]
then
	cat vendor_los/* > vendor.img
fi

if ! [ -e droidian.tar ]
then
	if ! [ -e droidian.zip ]
	then
		wget "https://github.com/droidian-images/droidian/releases/download/droidian%2F101.20251130/droidian-OFFICIAL-phosh-phone-rootfs-api30-arm64-101.20251130_20251207.zip" -O droidian.zip
	fi

	umount droidian/mnt || true
	sudo rm -rf droidian
	mkdir -p droidian
	(
		cd droidian
		unzip ../droidian.zip
		mkdir -p mnt
		sudo mount -o ro data/rootfs.img mnt
		sudo tar -C mnt -cf ../droidian.tar .
		sudo umount mnt
	)
fi

tar -cf overlay.tar overlay

podman image build --net host --arch arm64 -f Dockerfile_rootfs -t $IMAGE

mkdir -p rootfs_out

podman run \
	--arch arm64 \
	--rm -it \
	-v ./rootfs_out:/rootfs_out \
	$IMAGE \
	bash -c "
	tar -cvOf /rootfs_out/rootfs.tar --exclude './rootfs_out/*' --exclude './proc/*' --exclude './dev/*' --exclude './sys/*' --exclude './first_stage' .
	tar -cvOf /rootfs_out/first_stage.tar -C first_stage .
"
