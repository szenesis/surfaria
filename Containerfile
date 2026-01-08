ARG BUILD_FLAVOR="${BUILD_FLAVOR:-}"

FROM scratch AS ctx

COPY build_files /build
COPY system_files /files
COPY --from=ghcr.io/ublue-os/brew:latest /system_files /
COPY --from=ghcr.io/projectbluefin/common:latest /system_files/shared/usr/bin/luks* /usr/bin
COPY cosign.pub /files/etc/pki/containers/mercurium.pub

# Base Image
#FROM  quay.io/fedora/fedora-bootc:43
FROM  quay.io/fedora/fedora-silverblue:latest
ARG BUILD_FLAVOR="${BUILD_FLAVOR:-}"

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/00-base.sh

#Adding wallpaper
COPY system_files/usr/share/wallpapers usr/share/backgrounds
#Adding MercuryOS logo to plymout
COPY system_files/usr/share/mercuryos/pixmaps/MercuryOSlogo.png /usr/share/plymouth/themes/spinner/MercuryOSlogo.png

# Set MercuryOS spinner theme as default
RUN mkdir -p /etc/plymouth && \
    echo -e '[Daemon]\nTheme=mercuryos' > /etc/plymouth/plymouthd.conf
    
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build/01-cleanup.sh

RUN rm -rf /var/* && mkdir /var/tmp && bootc container lint
## Verify final image and contents are correct (got from Ziconium)
