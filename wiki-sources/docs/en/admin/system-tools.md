---
title: System Tools
description: Description of system tools integrated into RecoveryBox (GPSD, Chrony, Python environment, etc.)
tags:
  - tool
  - system
  - gps
  - chrony
---

# System Tools

## GPSD

The **gpsd** service manages communication with the GPS and provides position and time information to applications that need it. It is configured to listen on port 2947 and can be queried by clients compatible with the gpsd protocol.

This service is automatically installed and started whether a GPS is present on the RecoveryBox or not. The service is **configured** to start even if no application is **querying** it. This ensures the GPS is always available for applications that need it, even if they haven't been launched yet.

### Configuration file

```conf
/etc/default/gpsd
```

## Chrony

The **chrony** service manages system time synchronization. By default, it uses public NTP servers to synchronize.

In the RecoveryBox, chrony is configured to use the GPS as the primary time source and provide accurate time to devices connected to the RecoveryBox.

### Configuration file

```conf
/etc/chrony/000-gps.conf
```

### Python Virtual Environment

A Python virtual environment is used to isolate RecoveryBox Python application dependencies. This avoids conflicts between different library versions and ensures each application has its own set of dependencies.

This virtual environment is created in the `/data/recoverybox_env` directory. It is used by the [Meshtastic daemon](../admin/meshtastic-daemon.md) and the `wiki-generate.sh` script. It is available for other Python applications if needed.

Binaries are available in the `/data/recoverybox_env/bin` directory. They can be used to run Python scripts or install additional packages in the virtual environment without activating it.

### Activate the virtual environment

```bash
source /data/recoverybox_env/bin/activate
```

### Deactivate the virtual environment

```bash
deactivate
```