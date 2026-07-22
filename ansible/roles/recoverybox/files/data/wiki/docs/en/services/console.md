---
title: Console
description: Web administration console based on ShellInABox, accessible via browser.
tags:
  - service
  - administration
---

# Console

## Overview

The web administration console uses **[ShellInABox](https://github.com/shellinabox/shellinabox)**, an open-source web server that emulates a VT100 terminal directly in the browser via AJAX/JavaScript. This allows accessing a command-line shell without any client plugin.

In RecoveryBox, ShellInABox is deployed as a **systemd service** behind an Apache2 reverse proxy.

## Service Access

The console is accessible to all users connected to the RecoveryBox hotspot.

| URL                                                | Description                   |
| -------------------------------------------------- | ----------------------------- |
| [http://console.recovery.box](http://console.recovery.box) | Web administration console    |

!!! info "Default credentials"
    | Field       | Value       |
    | ----------- | ----------- |
    | Username    | `recuser`   |
    | Password    | `Recovery`  |

## Advanced Configuration

### A. Configuration Files

| Item | Description |
| --- | --- |
| `/etc/default/shellinabox` | ShellInABox configuration file |
| `/etc/apache2/sites-available/console.conf` | Apache2 reverse proxy configuration |
| `/var/log/apache2/console_access.log` | Apache access logs |
| `/var/log/apache2/console_error.log` | Apache error logs |

### B. Customization

#### Modifying ShellInABox configuration

ShellInABox can be customized via its configuration file `/etc/default/shellinabox`.

#### Enabling HTTPS

It is possible to switch the console to HTTPS by modifying the `/etc/default/shellinabox` file and replacing the last line with:

```bash
SHELLINABOX_ARGS="--no-beep"
```

Enabling HTTPS requires a certificate. In the Apache2 configuration file `/etc/apache2/sites-available/console.conf`, add:

```apache
SSLEngine on
SSLCertificateFile    /etc/ssl/certs/console.recovery.box.crt
SSLCertificateKeyFile /etc/ssl/private/console.recovery.box.key
```

### C. Debugging

```bash
# View access logs
cat /var/log/apache2/console_access.log

# View error logs
cat /var/log/apache2/console_error.log
```
