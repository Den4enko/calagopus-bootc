# calagopus-bootc

> [!WARNING]
> This is an experimental project and is **NOT** affiliated with or endorsed by the official Calagopus or Pterodactyl projects. Use it at your own risk.

This repository builds bootable container images (`bootc`) on top of Fedora and CentOS Stream 10 pre-configured with Calagopus Wings, Calagopus Panel, and Calagopus Panel Heavy.

## Architecture & Features

The image can be used to run either a Controller Node (Panel) or a Worker Node (Wings) by unmasking the respective systemd services.

- **Base OS options**:
  - `centos10` / `latest`: Built from `quay.io/centos-bootc/centos-bootc:stream10` (highly recommended for production).
  - `fedora`: Built from `quay.io/fedora/fedora-bootc:44` (bleeding-edge).
- **Podman Quadlets**: Services (Wings, Panel, Database, Cache) are managed by systemd using Podman Quadlets.
- **Unified Pod Architecture**: The `panel` and `panel-heavy` services share the same Podman Pod, database, and cache, communicating over local loopback.
- **XFS & Quota Support**: Directories are prepped for XFS project quotas (`xfs_quota`), enabled via kernel arguments (`rootflags=pquota`).

## Custom OS Configurations

The image includes the following configurations:

- **Kernel Arguments**: Audit logging is disabled (`audit=0`), log level is set to 3 to reduce console output, and XFS project quotas are enabled (`rootflags=pquota`).
- **System Provisioning**: Uses `systemd-tmpfiles` to create directories (`/etc/calagopus`, `/var/lib/calagopus`) and copy the default Wings config on first boot.
- **Packages & Utilities**: Includes `cloud-init` for deployments, `qemu-guest-agent` for VM integration, and `zram-generator-defaults` for ZRAM swap.
- **Podman Maintenance**: A `podman-image-prune.timer` is enabled to clean up unused container images.

## Included Services

Services are masked (disabled) by default. You must unmask the services you want to run:

- **`wings`**: The game server daemon.
- **`panel`**: The standard Calagopus web interface.
- **`panel-heavy`**: The "heavy" Calagopus web interface (includes binaries, extensions, and translations).

> [!NOTE]
> `panel` and `panel-heavy` are mutually exclusive and share the database and configuration.

## Getting Started

### 1. Setting up a Controller Node (Panel)

1. Edit the panel configuration file:
   ```bash
   sudo nano /etc/calagopus/panel.env
   ```
   *Configure `APP_ENCRYPTION_KEY`, `POSTGRES_PASSWORD`, etc.*

2. Unmask and start the panel (choose ONE):
   
   **For Standard Panel:**
   ```bash
   sudo systemctl unmask panel
   sudo systemctl start panel
   ```
   **For Heavy Panel:**
   ```bash
   sudo systemctl unmask panel-heavy
   sudo systemctl start panel-heavy
   ```

3. The panel starts its database and cache containers, maps port `8000`, and persists data in `/var/lib/calagopus/panel/`.

> [!TIP]
> **Changing the Port:**
> By default, the panel listens on port `8000`. To change it, copy the pod configuration to `/etc` and modify it:
> ```bash
> sudo cp /usr/share/containers/systemd/panel.pod /etc/containers/systemd/
> sudo nano /etc/containers/systemd/panel.pod
> # Change PublishPort=8080:8000
> sudo systemctl daemon-reload
> sudo systemctl restart panel
> ```

### 2. Setting up a Worker Node (Wings)

1. Edit the wings configuration file:
   ```bash
   sudo nano /etc/calagopus/config.yml
   ```
   *Paste the configuration token provided by your Calagopus Panel.*

2. Unmask and start wings:
   ```bash
   sudo systemctl unmask wings
   sudo systemctl start wings
   ```

## CI/CD Pipeline

The GitHub Actions workflow:
- Builds the OCI images (both CentOS Stream 10 and Fedora 44) on every push/PR to `main`.
- Pushes the images to GitHub Container Registry (GHCR) on merge to `main`:
  - `ghcr.io/<owner>/calagopus-bootc:centos10` (also tagged as `latest`)
  - `ghcr.io/<owner>/calagopus-bootc:fedora`
- Triggers a daily build at 18:00 UTC.
