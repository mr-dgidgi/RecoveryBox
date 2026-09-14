---
title: Filebrowser
description: File management service accessible via the browser.
tags:
  - service
  - notes
---

# Filebrowser

## Overview

Filebrowser is a file management service that allows users to browse, download, upload and organize files through an intuitive web interface. It is particularly useful for managing files stored on the RecoveryBox without needing SSH or FTP access.


## Service Access

Filebrowser is accessible to all users connected to the RecoveryBox hotspot.

| URL                                                | Description              |
| -------------------------------------------------- | ------------------------ |
| [http://filebrowser.recovery.box](http://filebrowser.recovery.box) | Web-based file management interface |

!!! info "Default credentials"
    | Field    | Value         |
    | -------- | ------------- |
    | Username | `admin`       |
    | Password | `RecAdmin1234` |

## Advanced Configuration

### A. File Locations

The configuration files are located in `/data/filebrowser`

| Path | Description |
| ------- | ----------- |
| `/data/filebrowser/database/filebrowser.db` | SQLite database |
| `/data/filebrowser/config/settings.json` | Filebrowser configuration file |
| `/data/filebrowser/custom` | Contains the files used to customize the interface |
| `/data/filebrowser/files/` | Base directory for the files managed by Filebrowser |


### B. Customization

All configuration is done through the web interface with the default `admin` user.

!!! info "Default password"
    It is strongly recommended to change the default password of the admin user.


### C. Debugging

#### Apache2
```bash
# View access logs
cat /var/log/apache2/filebrowser_access.log

# View error logs
cat /var/log/apache2/filebrowser_error.log
```

#### Service
```bash
# View Filebrowser service logs
journalctl -u filebrowser.service

# Check the status of the Filebrowser containers
docker ps -a | grep filebrowser
```