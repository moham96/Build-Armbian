
build_firmware-aml-20180213()
{
	display_alert "Merging and packaging linux firmware-aml-20180213" "@host" "info"

	local plugin_repo="https://github.com/150balbes/pkg-aml"
	local plugin_dir="firmware-aml-20180213"
	[[ -d "$SOURCES/$plugin_dir" && -n "$SOURCES$plugin_dir" ]] && rm -rf $SOURCES/$plugin_dir

	fetch_from_repo "$plugin_repo" "$plugin_dir/lib" "branch:firmware-aml-20180213"

	rm -R $SOURCES/$plugin_dir/lib/.git

	cd $SOURCES/$plugin_dir

	# set up control file
	mkdir -p DEBIAN
	cat <<-END > DEBIAN/control
	Package: firmware-aml-20180213
	Version: $REVISION
	Architecture: $ARCH
	Maintainer: $MAINTAINER <$MAINTAINERMAIL>
	Installed-Size: 1
	Replaces: linux-firmware
	Section: kernel
	Priority: optional
	Description: Linux firmware-aml-20180213
	END

	cd $SOURCES
	# pack
	mv firmware-aml-20180213 firmware-aml-20180213_${REVISION}_${ARCH}
	dpkg -b firmware-aml-20180213_${REVISION}_${ARCH} >> $DEST/debug/install.log 2>&1
	mv firmware-aml-20180213_${REVISION}_${ARCH} firmware-aml-20180213
	mv firmware-aml-20180213_${REVISION}_${ARCH}.deb $DEST/debs/ || display_alert "Failed moving firmware-aml-20180213 package" "" "wrn"
}

[[ ! -f $DEST/debs/firmware-aml-20180213_${REVISION}_${ARCH}.deb ]] && build_firmware-aml-20180213

# install basic firmware by default
display_alert "Installing firmware-aml-20180213" "$REVISION" "info"
install_deb_chroot "$DEST/debs/firmware-aml-20180213_${REVISION}_${ARCH}.deb"  >> $DEST/debug/install.log
