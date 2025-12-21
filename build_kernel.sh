set -xe

IMAGE=debian_z01r_kernel

if ! [ -e kernel_src ]
then
	git clone https://github.com/Kethen/android_kernel_asus_sdm845.git -b halium-11.0 kernel_src
fi

if ! [ -e clang_arm ]
then
	git clone https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 -b android11-gsi --depth 1 clang_arm
fi

if ! [ -e gcc_arm64 ]
then
	git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 -b pie-gsi --depth 1 gcc_arm64
fi

if ! [ -e gcc_arm ]
then
	git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 -b pie-gsi --depth 1 gcc_arm
fi

if ! podman image exists $IMAGE
then
	podman image build --arch=amd64 -t $IMAGE -f Dockerfile_kernel
fi

mkdir -p kbuild

podman run \
	--rm -it \
	-v ./kernel_src:/kernel_src \
	-w /kernel_src \
	-v ./kbuild:/kbuild \
	-v ./clang_arm:/clang_arm:ro \
	-v ./gcc_arm64:/gcc_arm64:ro \
	-v ./gcc_arm:/gcc_arm:ro \
	$IMAGE \
	bash -c '
	set -xe
	export PATH=/clang_arm/clang-r383902/bin:/gcc_arm64/bin:/gcc_arm/bin:$PATH
	export CLANG_TRIPLE=aarch64-linux-gnu-
	export CROSS_COMPILE=aarch64-linux-android-
	export CROSS_COMPILE_ARM32=arm-linux-androideabi-
	make O=/kbuild ARCH=arm64 CC=clang Z01R_defconfig
	make O=/kbuild ARCH=arm64 CC=clang -j$(nproc)
'
