FROM quay.io/fedora/fedora-bootc:44

# Base utilities and Podman
RUN dnf -y install \
    podman \
    cloud-init \
    btrfs-progs \
    tar \
    unzip \
    wget \
    jq \
    && dnf clean all

# Copy file structure
COPY rootfs/ /

# Enable system services
RUN systemctl enable \
    cloud-init.service \
    cloud-config.service \
    cloud-final.service \
    cloud-init-local.service \
    podman.socket \
    && systemctl mask wings.service