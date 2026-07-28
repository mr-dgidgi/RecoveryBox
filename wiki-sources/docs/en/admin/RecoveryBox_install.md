---
title: RecoveryBox_install.sh
description: Automated installation script for RecoveryBox on Debian/amd64.
tags:
  - tool
  - installation
---

# RecoveryBox_install.sh

## Overview

`RecoveryBox_install.sh` is the main installation script for the **RecoveryBox** project. It automates the complete deployment as well as updates and service enable/disable operations.

The script orchestrates the entire process:
- System prerequisites verification (root, amd64 architecture, `/data` mount point, WiFi interface)
- Ansible and required collections installation
- Interactive service configuration
- Ansible playbook execution (Docker deployment, services, network)
- Final network configuration via `systemd-networkd`
- Mandatory reboot to apply configuration

!!! warning "Root execution required"
    The script **must be run as root** (`sudo`). It checks UID at startup and exits if not compliant.

!!! warning "Mandatory reboot"
    A full system reboot is **required** at the end of installation to enable `systemd-networkd`, the WiFi access point, and all services.

---

## Execution Modes

| Mode | Command | Description |
|------|---------|-------------|
| **Full installation (interactive)** | `sudo ./RecoveryBox_install.sh` | Runs complete installation with interactive menus |
| **Configuration only** | `sudo ./RecoveryBox_install.sh config` | Shows only service configuration menu (generates `/etc/recoverybox/custom_config.yml`) |
| **Install with existing config** | `sudo ./RecoveryBox_install.sh custom` | Uses existing `/etc/recoverybox/custom_config.yml` (skips menu) |

---

## Usage Guide

### Full Installation (Interactive Mode)

```bash
sudo ./RecoveryBox_install.sh
```

- The script offers to reconfigure keyboard layout via `dpkg-reconfigure keyboard-configuration`.
- **Default installation? (yes/no)**
  - **Yes** → All services enabled with defaults. No detailed menu.
  - **No** → Detailed per-service configuration menu (see below).

- Each service can be individually enabled or disabled:

| Service | Default | Description |
|---------|---------|-------------|
| **Apache (web server)** | `true` | Enables Apache + modules (PHP, etc.) |
| **RecoveryBox Library** | `true` | Local library (requires Apache) |
| **BRouter** | `true` | Offline routing (bike, hike, car) |
| **BRouter map download** | `true` | Downloads cartographic data |
| **TileServer-GL** | `true` | Vector tile server (OSM) |
| **World map download (mbtiles)** | `true` | Downloads world map for TileServer |
| **Meshtastic** | `true` | Meshtastic services (MQTT, web, etc.) |
| **Web Console** | `true` | Admin web console (ShellInABox) |
| **OpenWebRX+** | `true` | Web SDR (radio reception) |
| **Kiwix (offline Wikipedia)** | `true` | Kiwix server + ZIM files |

!!! info "Generated configuration file"
    After the menu, the script generates **`/etc/recoverybox/custom_config.yml`** containing Ansible variables (`extra-vars`) matching your choices.

- The script automatically runs the `ansible/Install.yml` playbook.
- The script offers to run `/usr/local/bin/generate-map` to download a specific continent/country (BRouter, TileServer).
- If `systemd-networkd` is not yet the sole network manager, the script uses `network-configurator` to:
  - Create `WAN` / `LAN` bridges
  - Rename WiFi interface to `wlanAP`
  - Link a physical interface to WAN (DHCP or static)
  - Switch to `systemd-networkd` + `systemd-resolved`

!!! warning "Reboot required"
    This step **requires a reboot** to take effect.

- Copies `VERSION` file to `/etc/recoverybox/rb_version`
- Displays message: **MANDATORY REBOOT**

---

### Configuration Only (mode `config`)

```bash
sudo ./RecoveryBox_install.sh config
```
Runs only the service configuration menu (without executing the playbook). This generates or updates `/etc/recoverybox/custom_config.yml` with your choices.

### Installation with Existing Configuration (mode `custom`)

```bash
sudo ./RecoveryBox_install.sh custom
```
The script uses the existing `/etc/recoverybox/custom_config.yml` to run the Ansible playbook without the interactive menu. This mode is useful for updates or reinstallations with the same configuration.

---

!!! note "Update detection"
    The script detects `/etc/recoverybox/rb_version` and adds the `-upgrading` suffix if it exists.

---

## Common Troubleshooting

| Symptom | Probable Cause | Resolution |
|---------|----------------|------------|
| `user is not root` | Script run without `sudo` | Re-run with `sudo` |
| `/data does not exist` | Missing mount point | `mkdir /data && mount /dev/sdX /data` |
| `This script is only for Debian based systems` | Non-Debian OS | Use Debian/Ubuntu/Devuan amd64 |
| `This script is only for amd64 architecture` | ARM/other architecture | x86_64 hardware required |
| `No wireless interface found` | No WiFi interface / missing driver | Add USB WiFi card compatible with AP mode (ath9k, ath10k, mt76, etc.) |
| `Ansible binaries are not available` | Ansible installation failed | Check `apt`, network, Debian repos |
| `community.docker is not available` | `ansible-galaxy` failed | Check Internet connection, re-run script |
| `network-configurator command not found` | Ansible didn't deploy the tool | Check Ansible playbook, re-run |
| `failed to configure network interfaces` | `systemd-networkd` not enabled | Check `systemctl status systemd-networkd` |
| `Ansible playbook execution failed` | Playbook error (Docker, network, etc.) | Re-run in debug: `ansible-playbook -vvv ...` |