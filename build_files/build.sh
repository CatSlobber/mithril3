#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# Install negativo17 Codecs
dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo
sudo dnf config-manager setopt fedora-multimedia.enabled=1
sudo dnf config-manager setopt fedora-multimedia.priority=90
dnf install -y --from-repo=fedora-multimedia \
    intel-gmmlib \
    intel-mediasdk \
    intel-vaapi-driver \
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
&& dnf clean all

# Install negativo17 Steam
dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-steam.repo
sudo dnf config-manager setopt fedora-steam.enabled=1
sudo dnf config-manager setopt fedora-steam.priority=90
dnf install -y --from-repo=fedora-steam \
    steam \
&& dnf clean all

# Additional packages from Fedora repos
dnf install -y \
    git \
    jetbrains-mono-fonts \
    lato-fonts \
    mtr \
    ocean-sound-theme \
    uswds-public-sans-fonts \
    uv \
&& dnf clean all

# Install bibata cursors
dnf -y copr enable peterwu/rendezvous
dnf -y install bibata-cursor-themes
dnf -y copr disable peterwu/rendezvous

#### Example for enabling a System Unit File
systemctl enable podman.socket

# Install Nvidia-open akmod
IMAGE_NAME=silverblue /tmp/akmods-rpms/ublue-os/nvidia-install.sh

KERNEL_VERSION="$(rpm -q --queryformat='%{VERSION}-%{RELEASE}.%{ARCH}' kernel-core)"
export DRACUT_NO_XATTR=1
dracut --no-hostonly --kver "$KERNEL_VERSION" --reproducible --add ostree \
    -f "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"
chmod 0600 "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"
