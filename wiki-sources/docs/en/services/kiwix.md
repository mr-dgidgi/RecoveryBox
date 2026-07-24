---
title: Kiwix
description: Offline Wikipedia and other resources viewer via ZIM files.
tags:
  - service
  - offline-resources
---

# Kiwix

## Overview

**Kiwix** is free software for browsing websites offline. It works by reading compressed data files in the standard `.zim` format. Kiwix includes its own lightweight HTTP server (`kiwix-serve`) to serve content over a local network without any Internet access.

In RecoveryBox, Kiwix is deployed as a **Docker container** managed by a systemd service. It provides a web interface for browsing Wikipedia (and other content) from any device connected to the hotspot.

For more details about the project, consult the **[official Kiwix documentation](https://wiki.kiwix.org)** and the **[GitHub repository](https://github.com/kiwix/kiwix-serve)**.

### Properties

| Property                | Value                                     |
| ----------------------- | ----------------------------------------- |
| **Type**                | Docker container (systemd service)        |
| **Image**               | `ghcr.io/kiwix/kiwix-serve`              |
| **Port**                | `8080`                                    |
| **Volume**              | `/data/kiwix` (host) → `/data` (container) |
| **Activation variable** | `recoverybox_enable_kiwix`               |

---

## Service Access

The Kiwix browsing interface is accessible to all users connected to the RecoveryBox hotspot.

| URL                                             | Description                                    |
| ----------------------------------------------- | ---------------------------------------------- |
| [http://kiwix.recovery.box](http://kiwix.recovery.box) | Direct access to Kiwix                         |
| [http://recovery.box](http://recovery.box)       | RecoveryBox homepage (link to Kiwix)           |

!!! note "Network access"
    The service is only accessible from the RecoveryBox hotspot local network. DNS resolution for `kiwix.recovery.box` is handled by the local DNS server (dnsmasq) via the wildcard entry `*.recovery.box`.

---

## Default Content

RecoveryBox ships by default with a copy of **Wikipedia** in French and English in `.zim` format. Three size variants are available for each language:

| Variant       | Description                                            |
| ------------- | ------------------------------------------------------ |
| `all_mini`    | Most compact version (reduced quality)                 |
| `all_no_pic`  | Text without images (**default variant**)               |
| `all_maxi`    | Full version with images                                |

!!! info "Disk space"
    Complete Wikipedia ZIM files can weigh several gigabytes. The `all_no_pic` variant (text without images) is used by default to minimize disk usage.

---

## Advanced Configuration

### A. Configuration Files

| Item                                                     | Description                             |
| -------------------------------------------------------- | --------------------------------------- |
| `/etc/systemd/system/kiwix.service`                      | Systemd unit for the Docker container   |
| `/data/kiwix/`                                           | Directory containing `.zim` files       |

### B. Customization

#### Adding ZIM files manually

You can add new `.zim` files to enrich the available content (other Wikipedia languages, Wiktionary, Wikimed, Vikidia, etc.).

**Procedure:**

1. Download the `.zim` file of your choice from the [official Kiwix library](https://browse.library.kiwix.org/).
2. Transfer the file to the RecoveryBox (via SCP, USB, etc.) and place it in the `/data/kiwix/` directory:
   ```bash
   scp my-file.zim root@<recoverybox-ip>:/data/kiwix/
   ```
3. Restart the Kiwix service to pick up the new file via the `service-manager`

!!! warning "Restart required"
    Kiwix does not automatically detect newly added ZIM files. A service restart is **mandatory** for the content to be served.

#### Adding ZIM files via `custom_config.yml`

During installation/update via `RecoveryBox_install.sh`, by editing `/etc/recoverybox/custom_config.yml` directly, you can configure automatic downloading of ZIM files from the official Kiwix website.

**`recoverybox_kiwix_files` variable structure:**

```yaml
recoverybox_kiwix_files:
  - category: wikipedia      # Category (wikipedia, maps, etc.)
    language: french          # Content language
    enable: true              # Enable download
    arg: "all_no_pic"         # Variant: all_mini, all_no_pic, all_maxi
  - category: wikipedia
    language: english
    enable: true
    arg: "all_no_pic"
```

**Example with maps:**

```yaml
recoverybox_kiwix_files:
  - category: wikipedia
    language: french
    enable: true
    arg: "all_no_pic"
  - category: wikipedia
    language: english
    enable: true
    arg: "all_no_pic"
  - category: maps
    language: english
    enable: true
    arg: "croatia"
```

!!! info "Download source"
    Files are downloaded from `https://lb.download.kiwix.org/zim/`. The Ansible script automatically fetches the latest monthly release matching the configured pattern.

To apply the configuration after modification, relaunch the `RecoveryBox_install.sh` script.

### C. Debugging

#### Logs

```bash
# View service logs
journalctl -u kiwix.service

# View logs in real time
journalctl -u kiwix.service -f
```

#### Service verification

```bash
# Check global services status
rbstatus

# Test HTTP access
curl -I http://localhost:8080/
```
