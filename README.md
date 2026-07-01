# calagopus-bootc

> [!WARNING]
> This is an experimental project and is **NOT** affiliated with or endorsed by the official Calagopus project. Use it at your own risk.

This repository builds a bootable Fedora container image (`bootc`) pre-configured with Calagopus Wings, Podman, and XFS storage driver optimizations.

## Features

- **Fedora Bootc Base**: Streamlined bootable container image (`quay.io/fedora/fedora-bootc`).
- **Podman with XFS/Overlay**: Uses standard `overlay` driver optimized for XFS (with automatic reflink support if formatted appropriately).
- **Calagopus Wings via Quadlet**: Managed as a systemd service natively via Podman Quadlet.
- **XFS Quota Support**: State directories (`/var/lib/calagopus`) are ready for disk limiting using XFS project quotas (`xfs_quota`).
- **Config Overlay**: Default configuration is provided at `/usr/share/calagopus/config.yml` and copied to `/etc/calagopus/config.yml` on the first boot if it doesn't exist, allowing persistable user configuration.

## Getting Started

### 1. Initialization and Configuration

By default, the `wings.service` is **masked** to prevent it from starting before you configure it.

1. Once the system is booted, configure Wings by editing `/etc/calagopus/config.yml`:
   ```bash
   sudo vi /etc/calagopus/config.yml
   ```
   *Note: Do not completely overwrite the default configuration. Just append or fill in your `uuid`, `token_id`, `token`, and `api` fields as provided by your Calagopus Panel.*

### 2. Enable and Start Wings

After configuring the daemon, unmask and start the service:

```bash
sudo systemctl unmask wings
sudo systemctl start wings
```

Once unmasked, the service is automatically enabled on boot due to the Quadlet generator configuration.

## CI/CD Pipeline

The project includes a GitHub Actions workflow that:
- Builds the OCI image on every push/PR to `main`.
- Pushes the image to GitHub Container Registry (GHCR) as `ghcr.io/<owner>/calagopus-bootc:latest` (on main merge).
- Triggers a daily automatic build at 18:00 UTC to keep packages and base images up to date.
