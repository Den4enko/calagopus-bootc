FROM quay.io/fedora/fedora-bootc:44

# Base utilities and Podman
RUN dnf -y install \
    podman \
    cloud-init \
    xfsprogs \
    tar \
    unzip \
    wget \
    nano \
    htop \
    qemu-guest-agent \
    zram-generator-defaults \
    rsync \
    && dnf clean all

# Configure default timezone to UTC
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Copy file structure
COPY rootfs/ /

# Enable system services
RUN systemctl enable \
    cloud-init-main.service \
    cloud-config.service \
    cloud-final.service \
    cloud-init-local.service \
    podman.socket \
    podman-image-prune.timer \
    && systemctl mask wings.service
