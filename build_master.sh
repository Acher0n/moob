VERSION="$(cat version)"

echo "Compiling kernel"
START=$(date +"%s")

sed -i -e 's@"want_initramfs"@"skip_initramfs"@g' init/initramfs.c
cp defconfig .config
make -j$(nproc --all) || exit 1

if [ -e arch/arm64/boot/Image.gz ] ; then
	echo
	echo "Building Kernel Package"
	echo
	rm Moob-kernel-*.zip 2>/dev/null
	rm -rf kernelzip 2>/dev/null
	mkdir kernelzip
	echo "
kernel.string=moob-kernel-$(cat version)-@xda-developers
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=OnePlus7
device.name2=OnePlus7Pro
device.name3=OnePlus7T
device.name4=OnePlus7TPro
device.name5=guacamoleb
device.name6=guacamole
device.name7=hotdogb
device.name8=hotdog
block=/dev/block/bootdevice/by-name/boot
is_slot_device=1
ramdisk_compression=gzip
" > kernelzip/props
	cp -rp ../anykernel3/* kernelzip/
	find arch/arm64/boot/dts -name '*.dtb' -exec cat {} + > kernelzip/dtb
	cd kernelzip/
	7z a -mx9 Moob-kernel-$VERSION-tmp.zip *
	7z a -mx0 Moob-kernel-$VERSION-tmp.zip ../arch/arm64/boot/Image.gz
	zipalign -v 4 Moob-kernel-$VERSION-tmp.zip ../Moob-kernel-$VERSION.zip
	rm Moob-kernel-$VERSION-tmp.zip
	cd ..
	ls -al Moob-kernel-$VERSION.zip
fi

END=$(date +"%s")
DIFF=$((END - START))
echo -e "Kernel compiled successfully in $((DIFF / 60)) minute(s) $((DIFF % 60)) second(s)"
