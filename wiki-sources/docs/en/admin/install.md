---
title: Advanced Installation
description: Detailed guide for RecoveryBox installation, prerequisites, scenarios, and complete workflow.
tags:
  - tool
  - installation
---

# Advanced Installation

This page describes in more detail how the **[install.sh](RecoveryBox_install.md)** script works, its prerequisites, and the various possible installation scenarios.

---

# Supported Platforms

## Architecture

RecoveryBox is developed and tested exclusively for **x86_64 (amd64)** systems.

**ARM** architectures (Raspberry Pi, Orange Pi, RockPi, etc.) are **not supported**. The script automatically checks the architecture at startup and will abort the installation if it is not compatible.

---

## Linux Distribution

The script is designed to work on **Debian 13**.

Two installation methods are available:

### Recommended installation

The recommended method uses the custom Debian ISO generated with the **[debian13-preseed-RB](https://github.com/mr-dgidgi/debian13-preseed-RB)** project (more details in the [quick start guide](../quickstart.md)).

This method provides:

- a fully automated installation;
- a consistent system configuration;
- reduced risk of configuration errors.

---

### Installation on standard Debian

It is also possible to install RecoveryBox on a standard Debian 13 installation.

In this case, it is mandatory to:

- create the `/data` directory;
- install Git;
- clone the RecoveryBox repository;
- run `install.sh`.

Before running the script, **NetworkManager must be disabled**, as RecoveryBox exclusively uses **systemd-networkd** for network interface management.

For example:

```bash
systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl enable systemd-networkd
```

A system reboot after installation is still necessary to apply the full system configuration.

---

# Execution Environment

## Server without graphical interface

This is the recommended configuration as it allows lower resource consumption and the graphical environment provides no added value for standard use.

---

## Graphical environment

The script can theoretically be run on a Debian system with a graphical environment (GNOME, KDE, XFCE, etc.).

However, this configuration **has not been tested** and no specific support is provided.

The main concern is the potential coexistence between graphical network management tools and **systemd-networkd**.

---

## Virtual machine

Installation in a virtual machine is theoretically possible.

However, this configuration **has not been validated**.

Some features may not work correctly depending on the hypervisor used, notably:

- USB Wi-Fi interfaces passed to the virtual machine;
- USB GPS receivers;
- RTL-SDR keys;
- performance related to cartography processing.

---

# Network Configuration

## Multiple Ethernet interfaces

RecoveryBox can be installed on a machine with multiple network interfaces.

The script allows renaming interfaces to assign them explicit names (`Wan`, `Lan`, etc.), independently of the name assigned by Linux.

Additional interfaces can then be manually configured with `network-configurator` as needed.

There is no limitation on the number of network interfaces beyond physical limitations (number of PCI or USB ports)

---

## Mandatory Wi-Fi card

The presence of a Wi-Fi interface is **mandatory**.

This interface is used to create the RecoveryBox Wi-Fi access point.

It can be:

- an integrated Wi-Fi card;
- a compatible USB Wi-Fi key.

Without a Wi-Fi interface, the access point cannot be created and a significant portion of RecoveryBox functionality will be unavailable.

---

## Wi-Fi driver compatibility

The script automatically installs several firmwares and drivers commonly used on Debian (notably Realtek and Intel).

Despite this, some recent or more specific Wi-Fi cards may require additional driver installation.

If the Wi-Fi interface does not appear after installation, it is recommended to check:

```bash
ip link
```

or

```bash
iw dev
```

If no Wi-Fi device is detected, it will likely be necessary to install the driver matching the card's chipset.

Once the driver is installed, the `network-configurator` script can be used to configure the interface.

---

# Installation Workflow

The main steps are described on the dedicated **[install.sh](RecoveryBox_install.md)** page.

Installation duration depends mainly on the optional downloads selected. Without content downloads, installation is generally relatively quick. However, downloading Wikipedia or cartographic data can represent several tens of gigabytes and require several hours depending on the Internet connection.

Furthermore, generating detailed maps during installation can be very long depending on the machine power and the number of tiles to generate.

---

# After Installation

When the installation is complete, a **full reboot** is essential.

This reboot notably allows:

- enabling `systemd-networkd`;
- starting the installed services;
- enabling the Wi-Fi access point;
- applying the full system configuration.

Once the system has rebooted, RecoveryBox is accessible via the **recoverybox** Wi-Fi access point and through the installed web services.

---

## See Also

- **[install.sh](RecoveryBox_install.md)** — Complete documentation of the main installation script (modes, configuration, troubleshooting)
- **[rb-update](rb-update.md)** — Automated RecoveryBox update script