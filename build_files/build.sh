#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

dnf install -y dnf5-plugins

# Install negativo17 Codecs
dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo
dnf install -y --from-repo=fedora-multimedia \
    ffmpeg \
    ffmpeg-libs \
    intel-gmmlib \
    intel-mediasdk \
    intel-vaapi-driver \
    libavcodec \
    libfdk-aac \
    libheif \
    libva \
    libva-intel-media-driver \
    libva-utils \
    mesa-dri-drivers \
    mesa-filesystem \
    mesa-libEGL \
    mesa-libGL \
    mesa-libgbm \
    mesa-va-drivers \
    mesa-vulkan-drivers \
    pipewire-libs-extra \
&& dnf clean all

# Install negativo17 Steam
dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-steam.repo
dnf install -y --from-repo=fedora-steam \
    steam \
&& dnf clean all

# Fedora Hardware Support packages
dnf -y group install hardware-support

#"Fedora GNOME Desktop packages
dnf install -y \
    baobab \
    dconf \
    gdm \
    glycin-thumbnailer \
    gnome-bluetooth \
    gnome-boxes \
    gnome-browser-connector \
    gnome-calculator \
    gnome-calendar \
    gnome-characters \
    gnome-color-manager \
    gnome-control-center \
    gnome-disk-utility \
    gnome-epub-thumbnailer \
    gnome-font-viewer \
    gnome-initial-setup \
    gnome-logs \
    gnome-session-wayland-session \
    gnome-settings-daemon \
    gnome-shell \
    gnome-text-editor \
    gnome-user-share \
    gst-thumbnailers \
    gvfs-afc \
    gvfs-fuse \
    gvfs-goa \
    gvfs-gphoto2 \
    gvfs-mtp \
    gvfs-smb \
    librsvg2 \
    localsearch \
    loupe \
    ModemManager \
    nautilus \
    NetworkManager-adsl \
    NetworkManager-openconnect-gnome \
    NetworkManager-openvpn-gnome \
    NetworkManager-ppp \
    NetworkManager-ssh-gnome \
    NetworkManager-vpnc-gnome \
    NetworkManager-wwan \
    papers \
    papers-nautilus \
    ptyxis \
    snapshot \
    sushi \
    systemd-oomd-defaults \
    tinysparql \
    xdg-desktop-portal \
    xdg-desktop-portal-gnome \
    xdg-user-dirs-gtk

# Additional packages
dnf install -y \
    adw-gtk3-theme \
    bash-color-prompt \
    fedora-flathub-remote \
    fuse-libs \
    gamemode \
    git \
    glibc-langpack-en \
    libcamera-gstreamer \
    libcamera-tools \
    libimobiledevice-utils \
    libratbag-ratbagd \
    libvirt \
    libvirt-nss \
    mtr \
    rclone \
    rsync \
    symlinks \
    uv \
    virt-manager \
&& dnf clean all

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File
systemctl enable podman.socket

# Install Nvidia-open akmod
IMAGE_NAME=silverblue /tmp/akmods-rpms/ublue-os/nvidia-install.sh

KERNEL_VERSION="$(rpm -q --queryformat='%{VERSION}-%{RELEASE}.%{ARCH}' kernel-core)"
export DRACUT_NO_XATTR=1
dracut --no-hostonly --kver "$KERNEL_VERSION" --reproducible --add ostree \
    -f "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"
chmod 0600 "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"
