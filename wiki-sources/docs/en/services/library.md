---
title: Library
description: Collection of survival and self-reliance PDF documents, served locally via the RecoveryBox hotspot.
tags:
  - service
  - offline-resources
---

# Library

## Overview

The **Library** is a web server hosting a collection of PDF documents related to survival, self-reliance, and outdoor living techniques. The content comes from the [rb-library](https://github.com/mr-dgidgi/rb-library) Git repository and is served locally through an Apache2 VirtualHost, accessible to all users connected to the RecoveryBox hotspot.
The interface includes an admin interface for managing PDF documents, adding custom files, and updating the library. It works best in combination with the filebrowser service.

!!! info "Architecture"
    Unlike most other RecoveryBox services, the Library is **not** containerized via Docker. It is a native Apache2 VirtualHost serving static files cloned from a Git repository.

### Properties

| Property                  | Value                                   |
| ------------------------- | --------------------------------------- |
| **Type**                  | Static web server (Apache2)             |
| **Content**               | Survival and self-reliance PDF documents |
| **Source**                | [mr-dgidgi/rb-library](https://github.com/mr-dgidgi/rb-library) |
| **Activation variable**   | `recoverybox_enable_library`            |


---

## Service Access

PDF documents are accessible to all users connected to the RecoveryBox hotspot.

| URL                                      | Description                           |
| ---------------------------------------- | ------------------------------------- |
| [http://library.recovery.box](http://library.recovery.box) | Direct access to the library          |
| [http://recovery.box](http://recovery.box) | RecoveryBox homepage (link to the library) |
| [http://library.recovery.box/admin.html](http://library.recovery.box/admin.html) | Library admin interface               |

The admin account is based on the RecoveryBox default user:

| Username | Default password |
| -------- | ---------------- |
| recuser  | Recovery         |

!!! note "Network access"
    The service is only accessible from the RecoveryBox hotspot local network. DNS resolution for `library.recovery.box` is handled by the RecoveryBox local DNS server.

---

## Advanced Configuration

### A. Configuration Files

The service relies on a single Apache2 configuration file:

| File                                                     | Description                          |
| -------------------------------------------------------- | ------------------------------------ |
| `/etc/apache2/sites-available/library.conf`              | Apache2 VirtualHost for the library  |

This file includes the Apache snippet specific to the library, located at:
`/data/library/backend/apache-vhost-snippet.conf`

### B. Customization

#### Adding custom PDFs

##### a. Via the web interface

Files can be added via [filebrowser](filebrowser.md). The *library* folder corresponds to the `/data/library/PDF/custom/` directory on the machine.

After adding the files, you must go to the library admin interface for the changes to be taken into account. You log in with the machine's primary user credentials (default `recuser`). The page displays a table containing all the newly detected files and lets you classify them by specifying the different tags (category, language, type).

The admin interface also allows you to create new categories, languages, and types to organize the custom PDFs. The option is available in each of the dropdown menus dedicated to the tags.

!!! info "filebrowser"
    The admin page provides direct access to the filebrowser interface if it is enabled on the machine.

##### b. Via the CLI

A dedicated directory is available for adding your own PDF documents without modifying the upstream repository content:

```bash
# Add a custom PDF
cp my-document.pdf /data/library/PDF/custom/

# Verify it is present
ls -la /data/library/PDF/custom/
```

!!! warning "Persistence"
    Files added to `/data/library/PDF/custom/` are persistent. However, they will be **overwritten** during an update of the `rb-library` repository if they are located in another parent directory. Always use the `PDF/custom/` subdirectory for your additions.

You then need to run the Python script `library-update.py` to update the library's `custom-library.json` file and include your new documents:

```bash
# Run the update script
python3 /data/library/library-update.py
```
!!! info "Terminal"
    The commands can be run directly in the Cockpit terminal.


A restart of the Apache service via `services-manager` is required for the changes to take effect.

!!! info "filebrowser"
    It is also possible to add custom PDFs via the filebrowser web interface by dropping the files into the **library** directory. It is still necessary to run the `library-update.py` script for the new files to be taken into account.


#### Enabling / Disabling the service


The service can be completely disabled from the machine by running the `install.sh` installation script and choosing a *custom* installation, or directly via the Ansible variable in `/etc/recoverybox/custom_config.yml`:

```yaml
# In your custom_config.yml
recoverybox_enable_library: false
```
!!! note "install.sh"
    If other manual modifications have been made to `custom_config.yml`, it is recommended to keep editing the file manually. If the file is recreated via the installation script, your modifications will be overwritten.

!!! warning "Apache2 dependency"
    The Library requires Apache2 to be enabled (`recoverybox_enable_apache: true`). If Apache2 is disabled, the Library is automatically disabled as well.

### C. Debugging

#### Logs

| Log           | Path                                        |
| ------------- | ------------------------------------------- |
| Errors        | `/var/log/apache2/library.error.log`        |
| Access        | `/var/log/apache2/library.access.log`       |

#### Service verification

```bash
# Check that the VirtualHost is enabled
apache2ctl -S | grep library

# View the logs in real time
tail -f /var/log/apache2/library.access.log
tail -f /var/log/apache2/library.error.log
```

#### File structure

```
/data/library/                          # DocumentRoot (cloned from rb-library)
├── backend/                            # Contains the backend code used to manage the library
│   └── admin-config.json               # Admin interface variables
│   └── apache-vhost-snippet.conf       # Apache configuration fragment for the library VirtualHost
├── PDF/
│   └── custom/                         # User-added PDFs
├── index.html                          # Library homepage
└── ...                                 # Other PDF documents
```
