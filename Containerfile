ARG BUILD_FLAVOR="${BUILD_FLAVOR:-}"

FROM scratch AS ctx
COPY build_files /
COPY --from=ghcr.io/ublue-os/brew:latest /system_files /files
COPY --from=ghcr.io/projectbluefin/common:latest /system_files/shared/usr/bin/luks* /files/usr/bin
COPY cosign.pub /files/etc/pki/containers/mercurium.pub
# Base Image
FROM ghcr.io/ublue-os/silverblue-main:latest
ARG BUILD_FLAVOR="${BUILD_FLAVOR:-}"

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    ##/ctx/build.sh
    /ctx/build/00-base.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build/01-cleanup.sh

    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
