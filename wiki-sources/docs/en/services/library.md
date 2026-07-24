---
title: Library
description: Collection of survival and self-reliance PDF documents, served locally via the RecoveryBox hotspot.
tags:
  - service
  - offline-resources
---

# Library

## Overview

The **Library** is a static web server hosting a collection of PDF documents related to survival, self-reliance, and outdoor living. Content is sourced from the [rb-library](https://github.com/mr-dgidgi/rb-library) Git repository and served locally through an Apache2 VirtualHost, accessible to all users connected to the RecoveryBox hotspot.

!!! info "Architecture"
    Unlike most other RecoveryBox services, the Library is **not** containerized via Docker. It is a native Apache2 VirtualHost serving static files cloned from a Git repository.

### Properties

| Property           | Value                                    |
| ------------------ | ---------------------------------------- |
| **Type**           | Static web server (Apache2)              |
| **Content**        | Survival and self-reliance PDF documents |
| **Source**         | [mr-dgidgi/rb-library](https://github.com/mr-dgidgi/rb-library) |
| **Activation variable** | `recoverybox_enable_library`      |


---

## Service Access

PDF documents are accessible to all users connected to the RecoveryBox hotspot.

| URL                                           | Description                                  |
| --------------------------------------------- | -------------------------------------------- |
| [http://library.recovery.box](http://library.recovery.box) | Direct access to the library                 |
| [http://recovery.box](http://recovery.box) | RecoveryBox homepage (link to the library)   |

!!! note "Network access"
    The service is only accessible from the RecoveryBox hotspot local network. DNS resolution for `library.recovery.box` is handled by the RecoveryBox local DNS server.

---

## Advanced Configuration

### A. Configuration Files

The service relies on a single Apache2 configuration file:

| File                                                       | Description                      |
| ---------------------------------------------------------- | -------------------------------- |
| `/etc/apache2/sites-available/library.conf`                | Apache2 VirtualHost for the library |

**VirtualHost content:**

```apache
<VirtualHost *:80>
    ServerName library.recovery.box
    DocumentRoot /data/library

    <Location />
        Require all granted
    </Location>

    ErrorLog ${APACHE_LOG_DIR}/library.error.log
    CustomLog ${APACHE_LOG_DIR}/library.access.log combined
</VirtualHost>
```

!!! info "Ansible variables"
    The VirtualHost is deployed from the Ansible source file located at:
    `ansible/roles/recoverybox/files/etc/apache2/sites-available/library.conf`

### B. Customization

#### Adding custom PDFs

A dedicated directory is available for adding your own PDF documents without modifying the upstream repository content:

```bash
# Add a custom PDF
cp my-document.pdf /data/library/PDF/custom/

# Verify it is present
ls -la /data/library/PDF/custom/
```

!!! warning "Persistence"
    Files added to `/data/library/PDF/custom/` are persistent as long as the `/data` partition is mounted. However, they will be **overwritten** during a `rb-library` repository update if placed at the DocumentRoot level. Always use the `PDF/custom/` subdirectory for your additions.

You then need to run the `library-update.py` Python script to update the library's `custom-library.json` file and include your new documents:

```bash
# Run the update script
python3 /data/library/library-update.py
```

An Apache restart via `services-manager` is required for the changes to take effect.

#### Enabling / Disabling the service

The service can be completely disabled from the machine by running the `RecoveryBox_install.sh` installation script and choosing a *custom* installation, or directly via the Ansible variable in `/etc/recoverybox/custom_config.yml`:

```yaml
# In your custom_config.yml
recoverybox_enable_library: false
```

!!! note "RecoveryBox_install.sh"
    If other manual changes have been made to `custom_config.yml`, it is recommended to continue editing the file manually. Recreating the file via the installation script will overwrite your modifications.

!!! warning "Apache2 dependency"
    The Library requires Apache2 to be enabled (`recoverybox_enable_apache: true`). If Apache2 is disabled, the Library is automatically disabled as well.

### C. Debugging

#### Logs

| Log             | Path                                        |
| --------------- | ------------------------------------------- |
| Errors          | `/var/log/apache2/library.error.log`        |
| Access          | `/var/log/apache2/library.access.log`       |

#### Service verification

```bash
# Check that the VirtualHost is enabled
apache2ctl -S | grep library

# Check that content is available
curl -I -H "Host: library.recovery.box" http://127.0.0.1/

# View logs in real time
tail -f /var/log/apache2/library.access.log
```

#### File structure

```
/data/library/                          # DocumentRoot (cloned from rb-library)
├── PDF/
│   └── custom/                         # User-added PDFs
├── index.html                          # Library homepage
└── ...                                 # Other PDF documents
```
