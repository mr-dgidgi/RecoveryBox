---
title: Ansible Custom Variables
description: Customizable Ansible variables for RecoveryBox via /etc/recoverybox/custom_config.yml
tags:
  - ansible
  - configuration
  - variables
---

# Ansible Custom Variables

## Overview

The file **`/etc/recoverybox/custom_config.yml`** allows customizing the Ansible deployment of RecoveryBox without modifying role files.

This file is **managed automatically** by the **[RecoveryBox_install.sh](RecoveryBox_install.md)** script during interactive configuration. It is then passed as `extra-vars` to the Ansible playbook (`ansible/Install.yml`).

> **Note**: You can also create/modify this file manually before running an installation in `custom` mode (`sudo ./RecoveryBox_install.sh custom`).

---

## File Structure

The file must contain a YAML dictionary with variables to override. Minimal example:

```yaml
# /etc/recoverybox/custom_config.yml
recoverybox_enable_kiwix: false
recoverybox_hotspot_conf:
  ssid: "my-recoverybox"
  password: "password123"
```

---

## Complete Variable Reference

### Component Versions (Docker images, binaries)

| Variable | Default | Description |
|----------|---------|-------------|
| `recoverybox_version_library` | `"1.1.0"` | RecoveryBox Library version (GitHub releases) |
| `recoverybox_version_fonts` | `"master"` | Fonts version (Git branch) |
| `recoverybox_version_rtlsdr` | `"v1.3.6"` | RTL-SDR Blog version (Git tag) |
| `recoverybox_version_brouter_container` | `"v1.7.9"` | BRouter container version (Docker) |
| `recoverybox_version_brouter_web` | `"0.18.1"` | BRouter web interface version (GitHub releases) |
| `recoverybox_version_meshtastic_web` | `"2.7.1"` | Meshtastic web client version (Docker) |
| `recoverybox_version_kiwix` | `"3.8.2"` | Kiwix-serve version (Docker) |
| `recoverybox_version_simple_hotspot` | `"1.0"` | simple-hotspot version (Docker) |
| `recoverybox_version_owrx` | `"1.2.118"` | OpenWebRX+ version (Docker) |
| `recoverybox_version_tileserver` | `"v5.6.0"` | TileServer-GL version (Docker) |
| `recoverybox_version_planetiler` | `"0.10.2"` | Planetiler version (Docker) |

!!! tip "Tip"
    Only modify these versions if you have a specific reason (compatibility, known bug). Defaults are tested and validated.

---

### Service Enable/Disable

| Variable | Default | Description |
|----------|---------|-------------|
| `recoverybox_enable_apache` | `true` | Enables Apache2 (required for Library, Console, Kiwix web) |
| `recoverybox_enable_library` | `true` | Enables local PDF library (requires Apache) |
| `recoverybox_enable_owrx` | `true` | Enables OpenWebRX+ (web SDR) |
| `recoverybox_enable_brouter` | `true` | Enables BRouter (offline routing engine) |
| `recoverybox_enable_tileserver` | `true` | Enables TileServer-GL (vector tile server) |
| `recoverybox_enable_console` | `true` | Enables web admin console (ShellInABox) |
| `recoverybox_enable_kiwix` | `true` | Enables Kiwix (offline Wikipedia) |
| `recoverybox_enable_meshtastic` | `true` | Enables Meshtastic services (MQTT, web client, daemon) |
| `recoverybox_enable_hotspot` | `true` | Enables Wi-Fi hotspot |

!!! note "Note"
    If `recoverybox_enable_apache: false`, dependent services (Library, Console) will be automatically disabled by the playbook.

!!! warning "Warning"
    If `recoverybox_enable_hotspot: false`, the Wi-Fi hotspot will not be created and all services will be inaccessible.

---

### Network Interfaces

| Variable | Default | Description |
|----------|---------|-------------|
| `recoverybox_interface_wlanap` | `"wlanAP"` | Wi-Fi interface renamed for hotspot |
| `recoverybox_interface_wan` | `"Wan"` | WAN bridge name (Internet side) |
| `recoverybox_interface_lan` | `"Lan"` | LAN bridge name (local + hotspot) |

---

### Hotspot Configuration

Object `recoverybox_hotspot_conf` with the following keys:

| Key | Default | Description |
|-----|---------|-------------|
| `ssid` | `"recoverybox"` | Wi-Fi network name (SSID) |
| `password` | `"recoverybox"` | WPA2-PSK passphrase (8-63 chars) |
| `mode` | `"g"` | PHY mode: `g` (2.4 GHz), `a` (5 GHz), `acs` (auto) |
| `channel` | `"11"` | Wi-Fi channel (e.g., `1`, `6`, `11`, `36`, `0` for auto/ACS) |
| `auth_algs` | `"1"` | Authentication algorithms (1 = Open System) |
| `wpa` | `"2"` | WPA version (2 = WPA2) |
| `wpa_key_mgmt` | `"WPA-PSK"` | Key management |
| `wpa_pairwise` | `"TKIP CCMP"` | Pairwise cipher |
| `rsn_pairwise` | `"CCMP"` | RSN cipher (WPA2) |
| `network` | `"192.168.200.0"` | Hotspot network address |
| `mask` | `"24"` | Subnet mask (CIDR) |
| `ip` | `"192.168.200.1"` | Gateway IP for hotspot |
| `dhcp_range_start` | `"192.168.200.100"` | DHCP range start |
| `dhcp_range_end` | `"192.168.200.200"` | DHCP range end |

!!! important "Important"
    The Wi-Fi interface must support AP mode for the selected channel and mode.

---

### Meshtastic Node (External)

Object `recoverybox_meshtastic_node`:

| Key | Default | Description |
|-----|---------|-------------|
| `mac` | `"00:00:00:00:00:00"` | Meshtastic node MAC (for static DHCP lease) |
| `ip` | `"192.168.200.101"` | Fixed IP assigned to Meshtastic node |

> Only used if `recoverybox_enable_meshtastic: true` and a physical node is connected.

---

### Kiwix Downloads

List `recoverybox_kiwix_files` (each element is an object):

| Key | Description |
|-----|-------------|
| `category` | Category: `wikipedia`, `maps`, `wikivoyage`, `ted`, `stackexchange`, etc. |
| `language` | ISO 639-1 language code: `fr`, `en`, `es`, `de`, etc. |
| `enable` | `true`/`false` to enable this download |
| `arg` | Variant: `all_mini`, `all_nopic`, `all_maxi` (see [download.kiwix.org](https://lb.download.kiwix.org/zim/)) |

Example:
```yaml
recoverybox_kiwix_files:
  - category: wikipedia
    language: fr
    enable: true
    arg: "all_nopic"
  - category: wikipedia
    language: en
    enable: true
    arg: "all_nopic"
  - category: maps
    language: en
    enable: false
    arg: "france"
```

---

### Map Downloads

| Variable | Default | Description |
|----------|---------|-------------|
| `recoverybox_download_brouter` | `true` | Downloads BRouter segments (bike/hike/car routing) |
| `recoverybox_download_mbtiles` | `true` | Downloads `world.mbtiles` for TileServer-GL (world map) |

!!! warning "Warning"
    These downloads can be several GB. Disable (`false`) if bandwidth or disk space is limited and they are already downloaded.

---

## Complete Example

```yaml
# /etc/recoverybox/custom_config.yml
# Custom configuration example

# Versions (optional - keep defaults unless needed)
# recoverybox_version_brouter_container: "v1.7.9"

# Services: disable Kiwix and OpenWebRX to save space
recoverybox_enable_kiwix: false
recoverybox_enable_owrx: false

# Custom hotspot
recoverybox_hotspot_conf:
  ssid: "RecoveryBox-MySite"
  password: "SecurePass123!"
  mode: "g"
  channel: "6"
  network: "10.0.0.0"
  mask: "24"
  ip: "10.0.0.1"
  dhcp_range_start: "10.0.0.50"
  dhcp_range_end: "10.0.0.150"

# Meshtastic node connected via USB/Ethernet
recoverybox_meshtastic_node:
  mac: "aa:bb:cc:dd:ee:ff"
  ip: "10.0.0.10"

# Kiwix: only French Wikipedia without images
recoverybox_kiwix_files:
  - category: wikipedia
    language: fr
    enable: true
    arg: "all_nopic"

# No map downloads (limited bandwidth)
recoverybox_download_brouter: false
recoverybox_download_mbtiles: false
```

---

## Usage with RecoveryBox_install.sh

### Generate the file (interactive mode)

```bash
sudo ./RecoveryBox_install.sh config
```
→ Runs only the configuration menu and writes `/etc/recoverybox/custom_config.yml`

### Install with existing config

```bash
sudo ./RecoveryBox_install.sh custom
```
→ Uses existing file, skips menu, runs Ansible playbook directly

### Full install (generate + apply)

```bash
sudo ./RecoveryBox_install.sh
```
→ Runs configuration menu (unless defaults accepted), then runs playbook with generated config

---

## Best Practices

1. **Do NOT modify** role files (`ansible/roles/recoverybox/defaults/main.yml`) — they are managed by Git/Ansible and will be overwritten.
2. **Use ONLY** `/etc/recoverybox/custom_config.yml` for your overrides.
3. **Validate YAML syntax** before running installation:
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('/etc/recoverybox/custom_config.yml'))"
   ```

---