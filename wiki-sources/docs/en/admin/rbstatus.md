---
title: rbstatus
description: Monitoring script displaying the status of services, GPS, and system on the RecoveryBox.
tags:
  - tool
  - monitoring
---

# rbstatus

## Overview

`rbstatus` is a monitoring script that provides a quick overview of all RecoveryBox services, as well as GPS and system status (CPU, RAM, temperatures).

The script can be called via the command:

```bash
rbstatus
```

A lightweight mode is also available:

```bash
rbstatus light
```

!!! info "TTY2 display"
    A cron job is configured to display `rbstatus` on TTY2 (screen connected to the RecoveryBox). To display the output on a screen, simply switch to TTY2 with `Ctrl+Alt+F2`. To return to TTY1 (main console), use `Ctrl+Alt+F1`.

---

## Reported information

!!! note "Dynamic list"
    The list of displayed services is **dynamic** and depends on the services enabled during installation. Only services enabled in `/etc/recoverybox/services.json` are checked and displayed.

### Services

| Indicator | Description | Check type |
| --- | --- | --- |
| **Internet Access** | Internet connectivity | Ping to Google (8.8.8.8), Cloudflare (1.1.1.1) or Yandex (77.88.8.8) |
| **DNS Resolver** | DNS resolution | `nslookup` query to google.com, cloudflare.com or yandex.com |
| **Time Sync** | Time synchronization | Checks that `chrony.service` is active |
| **AccessPoint** | Wi-Fi access point | Checks that `ap.service` is active |
| **Apache Server** | Web server | Checks that `apache2.service` is active |
| **PDF Library** | Document library | HTTP request to `library.recovery.box` (expected code 200) |
| **OpenWebRX+** | SDR receiver | Checks that `openwebrx.service` is active |
| **Brouter (mapping)** | Routing engine | Checks that `brouter.service` is active |
| **TileServer (mapping)** | Tile server | Checks that `tileserver-gl.service` is active |
| **Web Console** | Administration console | Checks that `shellinabox.service` is active |
| **Meshtastic Web Client** | Meshtastic web client | Checks that `meshtastic-web.service` is active |
| **MkDocs Material** | Technical wiki | Checks that `mkdocs.service` is active |

### GPS

| Indicator | Description |
| --- | --- |
| **GPS status** | Checks that the GPS receives TPV frames via `gpspipe` |
| **GPS fix** | Location status: **2D Lock** (lat + lon), **3D Lock** (lat + lon + alt) or **No Fix** (not enough satellites) |
| **GPS Position** | GPS position (latitude, longitude, altitude) |

### System

| Indicator | Description |
| --- | --- |
| **CPU Usage** | Processor usage (color-coded: green < 60%, orange < 80%, red ≥ 80%) |
| **RAM Usage** | Memory usage |
| **Swap Usage** | Swap usage (0% by default with the Debian 13 preseed configuration) |
| **Temperatures** | Machine thermal sensor temperatures |

---

## Check details

### System services (type `systemd`)

For each service, the script checks:

1. **`systemctl is-active`**: is the service running?
2. **`systemctl is-enabled`**: is the service enabled at boot?

| Status | Meaning |
| --- | --- |
| `Running` | Service active and enabled |
| `Critical` | Service inactive or in error |
| `Disabled` | Service enabled but not started at boot |

### HTTP services (type `http`)

The script performs a `curl -I` request to the service URL with the appropriate `Host` header and checks the HTTP response code.

| Status | Meaning |
| --- | --- |
| `Running` | HTTP code 200 received |
| `Critical` | HTTP code other than 200 or timeout |

### Network checks (type `ping` / `dns`)

- **Ping**: sends an ICMP packet to 3 servers (Google, Cloudflare, Yandex). Only one needs to respond to pass.
- **DNS**: performs a name resolution to 3 domains. Only one needs to succeed to pass.

### GPS

The script queries `gpspipe` for 3 seconds and extracts the latest TPV frame (Time-Position-Velocity). The fix mode determines accuracy:

| Mode | Meaning |
| --- | --- |
| `3D Lock` | Longitude, latitude, and altitude determined |
| `2D Lock` | Longitude and latitude only |
| `No Fix` | Not enough visible satellites |
| `No GPS device` | No GPS device detected |
