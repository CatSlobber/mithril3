# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files

# Base image
FROM ghcr.io/ublue-os/akmods-nvidia-open:main-45 AS nvidia-akmods
FROM ghcr.io/ublue-os/silverblue-main:45

# Image modifications
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=bind,from=nvidia-akmods,source=/rpms,target=/tmp/akmods-rpms \
    /ctx/build.sh

# Install ublue-os/akmods xone
COPY --from=ghcr.io/ublue-os/akmods:main-45 /rpms /tmp/akmods-rpms
RUN dnf -y install /tmp/akmods-rpms/ublue-os/ublue-os-akmods-addons*.rpm && \
    dnf -y install /tmp/akmods-rpms/kmods/kmod-xone*.rpm && \
    rm -rf /tmp/akmods-rpms && \
    dnf clean all

RUN bootc container lint
