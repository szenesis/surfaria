#!/bin/bash

set -ouex pipefail

systemctl enable systemd-timesyncd
systemctl enable systemd-resolved.service

# See https://github.com/CentOS/centos-bootc/issues/191
mkdir -p /var/roothome

#Make sure flatpak is active
dnf5 install -y flatpak

# Add Flathub to the image for eventual application (got from Zirconium)
mkdir -p /etc/flatpak/remotes.d/
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo

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

systemctl enable podman.socket

if [ "$(arch)" != "aarch64" ] ; then
  dnf install -y \
    virtualbox-guest-additions \
    thermald
fi

# Saves a ton of space
# Got from Zirconium gotta verify
rm -rf /usr/share/doc
rm -rf /usr/bin/chsh # footgun

#run out of space?
dnf5 clean all
rm -rf /var/cache/dnf
rm -rf /usr/share/doc

HOME_URL="https://github.com/szenesis/mercuryos"
echo "Mercurium" | tee "/etc/hostname"
# OS Release File (changed in order with upstream)
# TODO: change ANSI_COLOR if applicable
sed -i -f - /usr/lib/os-release <<EOF
s|^NAME=.*|NAME=\"Mercurium\"|
s|^PRETTY_NAME=.*|PRETTY_NAME=\"Mercurium\"|
s|^VERSION_CODENAME=.*|VERSION_CODENAME=\"social possum\"|
s|^VARIANT_ID=.*|VARIANT_ID=""|
s|^HOME_URL=.*|HOME_URL=\"${HOME_URL}\"|
s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"${HOME_URL}/issues\"|
s|^SUPPORT_URL=.*|SUPPORT_URL=\"${HOME_URL}/issues\"|
s|^CPE_NAME=\".*\"|CPE_NAME=\"cpe:/o:szenesis:mercuryos\"|
s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"${HOME_URL}\"|
s|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME="mercurium"|

/^REDHAT_BUGZILLA_PRODUCT=/d
/^REDHAT_BUGZILLA_PRODUCT_VERSION=/d
/^REDHAT_SUPPORT_PRODUCT=/d
/^REDHAT_SUPPORT_PRODUCT_VERSION=/d
EOF
