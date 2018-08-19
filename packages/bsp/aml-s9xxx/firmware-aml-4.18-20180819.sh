
build_firmware-aml()
{
	display_alert "Merging and packaging linux firmware-aml-4.18-20180819" "@host" "info"

	local plugin_repo="https://github.com/150balbes/pkg-aml"
	local plugin_dir="firmware-aml-4.18-20180819"
	[[ -d $SRC/cache/sources/$plugin_dir ]] && rm -rf $SRC/cache/sources/$plugin_dir

	fetch_from_repo "$plugin_repo" "$plugin_dir/lib" "branch:firmware-aml-4.18-20180819"

	rm -R $SRC/cache/sources/$plugin_dir/lib/.git
	cd $SRC/cache/sources/$plugin_dir

	# set up control file
	mkdir -p DEBIAN
	cat <<-END > DEBIAN/control
	Package: firmware-aml-4.18-20180819
	Version: $REVISION
	Architecture: $ARCH
	Maintainer: $MAINTAINER <$MAINTAINERMAIL>
	Installed-Size: 1
	Replaces: linux-firmware
	Section: kernel
	Priority: optional
	Description: Linux firmware-aml-4.18-20180819
	END

	cd $SRC/cache/sources
	# pack
	mv firmware-aml-4.18-20180819 firmware-aml-4.18-20180819_${REVISION}_${ARCH}
	dpkg -b firmware-aml-4.18-20180819_${REVISION}_${ARCH} >> $DEST/debug/install.log 2>&1
	mv firmware-aml-4.18-20180819_${REVISION}_${ARCH} firmware-aml-4.18-20180819
	mv firmware-aml-4.18-20180819_${REVISION}_${ARCH}.deb $DEST/debs/ || display_alert "Failed moving firmware-aml-4.18-20180819 package" "" "wrn"
}

[[ ! -f $DEST/debs/firmware-aml-4.18-20180819_${REVISION}_${ARCH}.deb ]] && build_firmware-aml

# install basic firmware by default
display_alert "Installing firmware-aml-4.18-20180819" "$REVISION" "info"
install_deb_chroot "$DEST/debs/firmware-aml-4.18-20180819_${REVISION}_${ARCH}.deb"
