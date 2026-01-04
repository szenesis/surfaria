ARG BUILD_FLAVOR="${BUILD_FLAVOR:-}"

FROM scratch AS ctx

COPY build_files /build
COPY system_files /files
COPY --from=ghcr.io/ublue-os/brew:latest /system_files /
COPY --from=ghcr.io/projectbluefin/common:latest /system_files/shared/usr/bin/luks* /usr/bin
COPY cosign.pub /files/etc/pki/containers/mercurium.pub
#Replace default gnome background
COPY system_files/usr/share/mercuryos/Pictures/Walls/1471952432939.png /usr/share/backgrounds/
# Copy dconf defaults
COPY files/etc/dconf/db /etc/dconf/db

# Compile dconf database
RUN dconf update

# Base Image
FROM  quay.io/fedora/fedora-bootc:43
ARG BUILD_FLAVOR="${BUILD_FLAVOR:-}"

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/00-base.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build/01-cleanup.sh

RUN rm -rf /var/* && mkdir /var/tmp && bootc container lint
## Verify final image and contents are correct (got from Ziconium)
