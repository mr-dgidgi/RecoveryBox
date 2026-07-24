---
title: OpenWebRX Plus
description: Browser-accessible SDR radio receiver with built-in digital and analog decoders.
tags:
  - service
  - radio
---

# OpenWebRX Plus

## Overview

**OpenWebRX** is an open-source software-defined radio (SDR) receiver accessible via a web browser. It allows multiple users to connect simultaneously to listen to, analyze, and demodulate live radio signals (I/Q) using an SDR dongle (such as an RTL-SDR) connected to the RecoveryBox.

For more details about the original project, consult the **[official OpenWebRX documentation](https://www.openwebrx.de)**.

### Plus Version

RecoveryBox integrates **OpenWebRX Plus** (OpenWebRX+), an enhanced fork of the original project. This version adds critical features for crisis management and self-reliance, including built-in decoders for digital and analog modes (DMR, P25, D-Star, NXDN, APRS, POCSAG/Pager, SSTV, weather FAX), as well as improved map management and frequency scanning.

For more details about this version, visit the **[official OpenWebRX Plus repository](https://github.com/luarvique/openwebrx-plus)**.

## Service Access

The radio reception interface is accessible to all users connected to the RecoveryBox hotspot.

| URL                                                  | Description                    |
| ---------------------------------------------------- | ------------------------------ |
| [http://recovery.box:8073/](http://recovery.box:8073/) | OpenWebRX Plus web interface   |

!!! info "Administration credentials"
    | Field       | Value         |
    | ----------- | ------------- |
    | Username    | `recoverybox` |
    | Password    | `recoverybox` |

OpenWebRX Plus administration is primarily done through its web interface.

## Advanced Configuration

### A. Configuration Files

| Item | Description |
| --- | --- |
| `/etc/systemd/system/openwebrx.service` | Systemd unit for the OpenWebRX service |
| `/etc/owrx/` | OpenWebRX configuration directory |
| `/etc/owrx/custom-leaflet.js` | Custom map configuration (mounted read-only in the container) |

### B. Customization

#### Changing the administration account

It is possible to modify the administration username and password of OpenWebRX Plus by changing the following variables in the systemd service:

```bash
OPENWEBRX_ADMIN_USER=recoverybox
OPENWEBRX_ADMIN_PASSWORD=recoverybox
```

#### Map configuration

The container is started with the following mount option:

```text
-v /etc/owrx/custom-leaflet.js:/usr/lib/python3/dist-packages/htdocs/map-leaflet.js:ro
```

This overrides the map configuration file to point to the local server.

### C. Debugging

```bash
# View OpenWebRX logs
journalctl -u openwebrx.service -f
```
