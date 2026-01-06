ARG BUILD_FLAVOR="${BUILD_FLAVOR:-}"

FROM scratch AS ctx

COPY build_files /build
COPY system_files /files
COPY --from=ghcr.io/ublue-os/brew:latest /system_files /
COPY --from=ghcr.io/projectbluefin/common:latest /system_files/shared/usr/bin/luks* /usr/bin
COPY cosign.pub /files/etc/pki/containers/mercurium.pub

#Replace default gnome background
COPY system_files/usr/share/mercuryos/Pictures/Walls/1471952432939.png /usr/share/backgrounds/

# Base Image
FROM  quay.io/fedora/fedora-bootc:43
ARG BUILD_FLAVOR="${BUILD_FLAVOR:-}"

COPY --from=builder /usr/bin/plymouth /usr/bin/plymouth
COPY --from=builder /usr/share/plymouth /usr/share/plymouth
COPY --from=builder /etc/plymouth /etc/plymouth

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/00-base.sh

#Adding MercuryOS logo to plymout
RUN mkdir -p /usr/share/plymouth/themes/mercuryos && \
    cp -r /usr/share/plymouth/themes/spinner/* /usr/share/plymouth/themes/mercuryos/ && \
    # Replace the default watermark/logo with MercuryOS logo
    wget --tries=5 -O /usr/share/plymouth/themes/mercuryos/watermark.png \
        https://raw.githubusercontent.com/szenesis/MercuryOS_Walls/265eff6e1f8a8e61198209e2c32290e489797d69/MercuryOS_logo.png && \
    # Edit the spinner script to remove Fedora text or replace it with MercuryOS
    sed -i 's/Fedora/MercuryOS/g' /usr/share/plymouth/themes/mercuryos/spinner.script && \
    # Update theme metadata
    sed -i 's/Name=.*/Name=MercuryOS/' /usr/share/plymouth/themes/mercuryos/spinner.plymouth

# Set MercuryOS spinner theme as default
RUN mkdir -p /etc/plymouth && \
    echo -e '[Daemon]\nTheme=mercuryos' > /etc/plymouth/plymouthd.conf

# Optional: rebuild initramfs (Bootc usually handles this in build scripts)
RUN dracut -f
      
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build/01-cleanup.sh

RUN rm -rf /var/* && mkdir /var/tmp && bootc container lint
## Verify final image and contents are correct (got from Ziconium)
