---
title: System Tools
description: System services for GPS, time synchronization, and SDR drivers on the RecoveryBox.
tags:
  - tool
  - system
---

# System Tools

## GPSD

The gpsd service manages communication with the GPS and provides position and time information to applications that need it. It is configured to listen on port 2947 and can be queried by clients compatible with the gpsd protocol.

This service is automatically installed and started whether or not a GPS is present on the RecoveryBox. The service is configured to start even if no application is querying it. This ensures that the GPS is always available for applications that need it, even if they haven't been launched yet.

### Configuration file

```
/etc/default/gpsd
```

## Chrony

The chrony service manages system time synchronization. By default, it uses public NTP servers to synchronize.

In the RecoveryBox, chrony is configured to use the GPS as the primary time source and provide accurate time to devices connected to the RecoveryBox.

### Configuration file

```
/etc/chrony/000-gps.conf
```

## RTL-SDR Driver

The RTL-SDR driver enables the use of RTL-SDR USB dongles for software-defined radio reception. The RecoveryBox includes compiled and installed RTL-SDR Blog drivers for optimal compatibility.

### Driver installation

The drivers are automatically compiled and installed during RecoveryBox installation when the OpenWebRX service is enabled. The installation process handles the following:

- Kernel module compilation for RTL-SDR
- udev rules for device detection
- Integration with OpenWebRX Plus

### Verification

```bash
# Check if the RTL-SDR device is detected
lsusb | grep RTL

# Check kernel module
lsmod | grep rtl
```
