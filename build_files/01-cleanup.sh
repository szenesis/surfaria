#!/bin/bash

set -xeuo pipefail

# See https://github.com/CentOS/centos-bootc/issues/191
mkdir -p /var/roothome

HOME_URL="https://github.com/szenesis/mercuryos"
echo "mercuryos" | tee "/etc/hostname"
# OS Release File (changed in order with upstream)
# TODO: change ANSI_COLOR if applicable
sed -i -f - /usr/lib/os-release <<EOF
s|^NAME=.*|NAME=\"MercuryOS\"|
s|^PRETTY_NAME=.*|PRETTY_NAME=\"MercuryOS\"|
s|^VERSION_CODENAME=.*|VERSION_CODENAME=\"Stressed Possum\"|
s|^VARIANT_ID=.*|VARIANT_ID=""|
s|^HOME_URL=.*|HOME_URL=\"${HOME_URL}\"|
s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"${HOME_URL}/issues\"|
s|^SUPPORT_URL=.*|SUPPORT_URL=\"${HOME_URL}/issues\"|
s|^CPE_NAME=\".*\"|CPE_NAME=\"cpe:/o:szenesis:mercuryos\"|
s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"${HOME_URL}\"|
s|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME="mercuryos"|

/^REDHAT_BUGZILLA_PRODUCT=/d
/^REDHAT_BUGZILLA_PRODUCT_VERSION=/d
/^REDHAT_SUPPORT_PRODUCT=/d
/^REDHAT_SUPPORT_PRODUCT_VERSION=/d
EOF

# Add Flathub to the image for eventual application (got from Zirconium)
mkdir -p /etc/flatpak/remotes.d/
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo

# Remove annoying fedora flatpaks
rm -rf /usr/lib/systemd/system/flatpak-add-fedora-repos.service
UNIT=flatpak-add-flathub-repos.service
if [ -f "/usr/lib/systemd/system/$UNIT" ] || [ -f "/etc/systemd/system/$UNIT" ]; then
    systemctl enable "$UNIT"
fi

# Saves a ton of space (got from Zirconium)
rm -rf /usr/share/doc
rm -rf /usr/bin/chsh

# Copies `grub` and `shim` EFI binaries to bootupd directory so that bootc-image-builder can work
# FIX: Will be removed once https://github.com/osbuild/bootc-image-builder/issues/1171 is resolved
cp -r /usr/lib/efi/*/*/* /usr/lib/bootupd/updates

KERNEL_VERSION="$(find "/usr/lib/modules" -maxdepth 1 -type d ! -path "/usr/lib/modules" -exec basename '{}' ';' | sort | tail -n 1)"
export DRACUT_NO_XATTR=1
dracut --no-hostonly --kver "$KERNEL_VERSION" --reproducible --zstd -v --add ostree -f "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"
chmod 0600 "/usr/lib/modules/${KERNEL_VERSION}/initramfs.img"
