#!/bin/bash

# Check for sudo
if [ "$(id -u)" != 0 ]; then
	echo "You need to run this script as sudo" && exit 1
fi

# Remove standard packages
remove_standard_packages() {
	dnf remove -y gnome-calendar* gnome-contacts* gnome-boxes* libreoffice*
}

update_system() {
	dnf update -y
}

# RPM Fusion
# https://rpmfusion.org/Configuration
add_rpm_fusion_repo() {
	dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
	
	# AppStream metadata
	dnf -y groupupdate core
	
	# Multimedia post-install
	dnf groupupdate -y multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
	dnf groupupdate -y sound-and-video
}

# Nvidia drivers
nvidia_drivers() {
	dnf -y install akmod-nvidia \
	xorg-x11-drv-nvidia-cuda \
	vulkan \
	xorg-x11-drv-nvidia-cuda-libs \
	vdpauinfo libva-vdpau-driver libva-utils
}

# Flathub
add_flathub_repo() {
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

# Flatpak packages
install_flatpak_packages() {
	flatpak install -y flathub com.spotify.Client \
	com.discordapp.Discord \
	us.zoom.Zoom \
	com.valvesoftware.Steam \
	org.libreoffice.LibreOffice \
	com.obsproject.Studio \
	com.github.tchx84.Flatseal \
	com.transmissionbt.Transmission \
	im.riot.Riot \
	org.jitsi.jitsi-meet \
	org.signal.Signal \
	org.pulseaudio.pavucontrol \
	org.keepassxc.KeePassXC \
	com.usebottles.bottles \
	org.standardnotes.standardnotes \
	org.chromium.Chromium \
	com.valvesoftware.Steam.CompatibilityTool.Proton-GE \
	org.gnome.Extensions
}

# Repo packages
install_rpm_packages() {
	dnf install -y gnome-tweaks
}

# Gnome shell extensions
install_gnome_shell_extensions() {
	dnf install -y openssl \ #For gsconnect
	"gnome-shell-extension-gsconnect*" \
	gnome-shell-extension-sound-output-device-chooser*
}

# VAAPI for intel
# https://lukas.zapletalovi.com/2020/10/enable-vaapi-on-intel.html
install_vaapi_intel() {
	dnf install -y libva libva-intel-driver libva-vdpau-driver libva-utils
}

# Wine
install_wine() {
	# Wine dependecy hell
	# https://www.gloriouseggroll.tv/how-to-get-out-of-wine-dependency-hell/
	dnf install -y alsa-plugins-pulseaudio.i686 glibc-devel.i686 glibc-devel libgcc.i686 libX11-devel.i686 freetype-devel.i686 libXcursor-devel.i686 libXi-devel.i686 libXext-devel.i686 libXxf86vm-devel.i686 libXrandr-devel.i686 libXinerama-devel.i686 mesa-libGLU-devel.i686 mesa-libOSMesa-devel.i686 libXrender-devel.i686 libpcap-devel.i686 ncurses-devel.i686 libzip-devel.i686 lcms2-devel.i686 zlib-devel.i686 libv4l-devel.i686 libgphoto2-devel.i686 cups-devel.i686 libxml2-devel.i686 openldap-devel.i686 libxslt-devel.i686 gnutls-devel.i686 libpng-devel.i686 flac-libs.i686 json-c.i686 libICE.i686 libSM.i686 libXtst.i686 libasyncns.i686 liberation-narrow-fonts.noarch libieee1284.i686 libogg.i686 libsndfile.i686 libuuid.i686 libva.i686 libvorbis.i686 libwayland-client.i686 libwayland-server.i686 llvm-libs.i686 mesa-dri-drivers.i686 mesa-filesystem.i686 mesa-libEGL.i686 mesa-libgbm.i686 nss-mdns.i686 ocl-icd.i686 pulseaudio-libs.i686 sane-backends-libs.i686 tcp_wrappers-libs.i686 unixODBC.i686 samba-common-tools.x86_64 samba-libs.x86_64 samba-winbind.x86_64 samba-winbind-clients.x86_64 samba-winbind-modules.x86_64 mesa-libGL-devel.i686 fontconfig-devel.i686 libXcomposite-devel.i686 libtiff-devel.i686 openal-soft-devel.i686 mesa-libOpenCL-devel.i686 opencl-utils-devel.i686 alsa-lib-devel.i686 gsm-devel.i686 libjpeg-turbo-devel.i686 pulseaudio-libs-devel.i686 pulseaudio-libs-devel gtk3-devel.i686 libattr-devel.i686 libva-devel.i686 libexif-devel.i686 libexif.i686 glib2-devel.i686 mpg123-devel.i686 mpg123-devel.x86_64 libcom_err-devel.i686 libcom_err-devel.x86_64 libFAudio-devel.i686 libFAudio-devel.x86_64
			
	dnf groupinstall -y "C Development Tools and Libraries" "Development Tools"

	dnf install -y wine
}

until [ "$selection" = "0" ]; do
	echo ""
	echo "Some post install stuff for Fedora. Install in descending order."
	echo ""
	echo "0  - Exit script"
	echo "1  - Remove standard packages"
	echo "2  - Update system"
	echo "3  - Add RPM Fusion repo"
	echo "4  - Install Nvidia drivers"
	echo "5  - Add Flathub repo"
	echo "6  - Install flatpak packages"
	echo "7  - Install RPM packages"
	echo "8  - Install Gnome shell extensions"
	echo "9  - Install VAAPI packages for Intel"
	echo "10 - Install Wine + dependencies"
	echo "11 - Do all options in descending order"
	echo ""
	read -p "Enter choice: " -r selection
	case $selection in
		1 ) remove_standard_packages ;;
		2 ) update_system ;;
		3 ) add_rpm_fusion_repo ;;
		4 ) nvidia_drivers ;;
		5 ) add_flathub_repo ;;
		6 ) install_flatpak_packages ;;
		7 ) install_rpm_packages ;;
		8 ) install_gnome_shell_extensions ;;
		9 ) install_vaapi_intel ;;
		10 ) install_wine ;;
		11 ) remove_standard_packages ; update_system ;
			add_rpm_fusion_repo ; nvidia_drivers ;
			add_flathub_repo ; install_flatpak_packages ;
			install_rpm_packages ; install_gnome_shell_extensions ;
			install_vaapi_intel ; install_wine ;;
	esac
done
