#!/usr/bin/env bash
set -euxo pipefail

BASE_IMAGE="${1:-}"

# Enable EPEL and CRB repositories for Enterprise Linux images
if echo "$BASE_IMAGE" | grep -qE "centos|alma|rocky"; then
    dnf install -y epel-release
    dnf config-manager --set-enabled crb || true
    dnf config-manager --set-enabled epel-testing || true
fi

# Upgrade system packages and install required utilities
dnf clean all
dnf upgrade -y --refresh
dnf install -y \
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
    tcpdump
dnf clean all

# Set default timezone to UTC
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Enable and mask systemd services
if [ -f /usr/lib/systemd/system/cloud-init-main.service ]; then
    systemctl enable cloud-init-main.service
else
    systemctl enable cloud-init.service
fi

systemctl enable \
    cloud-config.service \
    cloud-final.service \
    cloud-init-local.service \
    podman.socket \
    podman-image-prune.timer

systemctl mask \
    wings.service \
    panel.service \
    panel-heavy.service \
    bootc-fetch-apply-updates.timer \
    bootc-fetch-apply-updates.service
