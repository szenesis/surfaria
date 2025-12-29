#!/bin/bash

set -ouex pipefail

systemctl enable systemd-timesyncd
systemctl enable systemd-resolved.service

# See https://github.com/CentOS/centos-bootc/issues/191
mkdir -p /var/roothome

#Make sure flatpak is active
dnf5 install -y flatpak

#Bazaar store
flatpak install -y flathub io.github.kolunmi.Bazaar

#Flatpak browser install
flatpak install -y com.vivaldi.Vivaldi

# Install terminal software from fedora repos
dnf5 install -y \
 sakura \
 fish \
 docker \
 fastfetch \
 fzf

#Remove software that is not needed for workflow.
dnf5 remove -y \
 gnome-software \
 gnome-tour \
 gnome-system-monitor \
 yelp \
 htop \
 nvtop \
 firefox

#Remove old/retro Gnome extensions
dnf5 remove -y \
 gnome-shell-extension-common \
 gnome-shell-extension-apps-menu \
 gnome-shell-extension-launch-new-instance \
 gnome-shell-extension-places-menu \
 gnome-shell-extension-window-list \
 gnome-shell-extension-background-logo \
 gnome-shell-extension-appindicator \
 gnome-extensions-app \
 gnome-software-rpm-ostree

# Install VS Code
tee /etc/yum.repos.d/vscode.repo <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
sed -i "s/enabled=.*/enabled=0/g" /etc/yum.repos.d/vscode.repo
dnf -y install --enablerepo=code \
    code


systemctl preset systemd-resolved.service

dnf -y copr enable ublue-os/packages
dnf -y copr disable ublue-os/packages
dnf -y --enablerepo copr:copr.fedorainfracloud.org:ublue-os:packages install uupd ublue-os-udev-rules

systemctl enable podman.socket

if [ "$(arch)" != "aarch64" ] ; then
  dnf install -y \
    virtualbox-guest-additions \
    thermald
fi
