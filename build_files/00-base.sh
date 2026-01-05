#!/bin/bash

set -ouex pipefail

systemctl enable systemd-timesyncd
systemctl enable systemd-resolved.service

# Making sure user home exists for flatpak --user
export HOME=/var/root
mkdir -p "$HOME/.local/share"


# Make sure flatpak is active
dnf5 install -y flatpak
# Adding flathub remotes
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# Flatpak update remotes
flatpak update --appstream
# Flatpak browser and other necesary installs (subject to be removed if preinstalls work)
flatpak install --system -y flathub com.vivaldi.Vivaldi
flatpak install --system -y flathub com.mattjakeman.ExtensionManager

# Update packeges just in case
dnf5 update -y
# Install terminal software from fedora repos
dnf5 install -y \
 @gnome-desktop \
 foot \
 fish \
 docker \
 fastfetch \
 fzf \
 emacs
# Remove software that is not needed for workflow.
dnf5 remove -y \
 gnome-software \
 gnome-tour \
 gnome-system-monitor \
 yelp \
 htop \
 nvtop \
 firefox \
 ptyxis
# Remove old/retro Gnome extensions
dnf5 remove -y \
 gnome-shell-extension-common \
 gnome-shell-extension-apps-menu \
 gnome-shell-extension-launch-new-instance \
 gnome-shell-extension-places-menu \
 gnome-shell-extension-window-list \
 gnome-shell-extension-background-logo \
 gnome-shell-extension-appindicator \
 gnome-extensions-app \
 gnome-software-rpm-ostree \
 gnome-backgrounds \
 gnome-terminal
# Remove and cleanup of flatpaks
flatpak uninstall --noninteractive \
  org.gnome.Extensions \
  org.gnome.Contacts \
  org.gnome.Maps \
  org.gnome.Papers \
  org.gnome.Connections


systemctl preset systemd-resolved.service

if [ "$(arch)" != "aarch64" ] ; then
  dnf install -y \
    virtualbox-guest-additions \
    thermald
fi
