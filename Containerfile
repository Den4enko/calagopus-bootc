ARG BASE_IMAGE=quay.io/fedora/fedora-bootc:44
FROM $BASE_IMAGE
ARG BASE_IMAGE

# Install EPEL & enable CRB/epel-testing for CentOS-based images to access htop/fastfetch
RUN if echo "$BASE_IMAGE" | grep -q "centos"; then \
        dnf install -y epel-release && \
        dnf config-manager --set-enabled crb && \
        dnf config-manager --set-enabled epel-testing; \
    fi

# Base utilities and Podman
RUN dnf clean all && \
    dnf upgrade -y --refresh && \
    dnf -y install \
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
    fastfetch \
    && dnf clean all

# Configure default timezone to UTC
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Copy file structure
COPY rootfs/ /

# Enable system services
RUN if [ -f /usr/lib/systemd/system/cloud-init-main.service ]; then \
        systemctl enable cloud-init-main.service; \
    else \
        systemctl enable cloud-init.service; \
    fi && \
    systemctl enable \
    cloud-config.service \
    cloud-final.service \
    cloud-init-local.service \
    podman.socket \
    podman-image-prune.timer \
    && systemctl mask wings.service panel.service panel-heavy.service \
    && systemctl disable bootc-fetch-apply-updates.service
