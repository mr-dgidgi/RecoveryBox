---
title: Flatnotes
description: Browser-based note-taking service.
tags:
  - service
  - notes
---

# Flatnotes

## Overview

[Flatnotes](https://github.com/dullage/flatnotes) is a web-based note-taking application that allows users to create, edit, and organize their notes directly from a browser.

In RecoveryBox, Flatnotes is deployed as a **systemd service** behind an Apache2 reverse proxy.

Three installation modes are **available** for Flatnotes in RecoveryBox:
- **Open**: Flatnotes is accessible to all users connected to the RecoveryBox hotspot, without authentication.
- **Secure**: Flatnotes is accessible to all users connected to the RecoveryBox hotspot, but requires authentication with a username and password.
- **Full**: Flatnotes is accessible in read-only mode to all users connected to the RecoveryBox hotspot. A second Flatnotes instance is accessible in write mode only to authenticated users with a username and password.

## Service Access

Flatnotes is accessible to all users connected to the RecoveryBox hotspot.

| URL | Description |
| --- | --- |
| [http://flatnotes.recovery.box](http://flatnotes.recovery.box) | Web note-taking interface |
| [http://flatnotes-ro.recovery.box](http://flatnotes-ro.recovery.box) | Read-only web interface (**Full** installation) |

!!! info "Default Credentials"
    | Field | Value |
    | ----- | ----- |
    | Username | `recadmin` |
    | Password | `RecoveryAdmin` |

## Advanced Configuration

### A. File Location

All files **are stored** in the `/data/flatnotes` directory. They are in markdown format and can therefore be easily edited, read, or transferred.

### B. Customization

During RecoveryBox installation, you can choose the Flatnotes installation type (Open, Secure, or Full) and define credentials for secure access.

Configuration variables are stored in `/etc/recoverybox/custom_config.yml` and can be modified manually if needed.
Configuration variables:

```yaml
recoverybox_flatnotes_open: "full" # open, secure, full
recoverybox_flatnotes_secure:
  username: "recadmin"
  password: "RecoveryAdmin"
  secret_key: "aLongRandomSeriesOfCharacters123"
```

!!! info "Security"
    It is recommended to change the default password for secure Flatnotes access.

The **secret key** (`secret_key`) is used to secure sessions and must be a random, complex string of at least 32 characters.

!!! warning "Security"
    Changing the `secret_key` will invalidate all existing sessions and users will need to log in again.

### C. Debug

#### Apache2
```bash
# View access logs
cat /var/log/apache2/flatnotes_access.log

# View error logs
cat /var/log/apache2/flatnotes_error.log
```

#### Service
```bash
# View Flatnotes service logs
journalctl -u flatnotes.service
journalctl -u flatnotes-ro.service

# Check Flatnotes container status
docker ps -a | grep flatnotes
```