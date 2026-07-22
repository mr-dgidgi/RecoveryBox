---
title: Quick Start
description: Quick installation guide for RecoveryBox, from USB key preparation to first boot.
tags:
  - guide
  - installation
---

# Quick Start

## Prerequisites

### Required

- A PC running Linux or Windows with WSL enabled (to generate the installation USB key).
- An **x86_64** computer with at least one Ethernet port and a Wi-Fi card (or USB key) that will serve as the RecoveryBox.
- A screen connected to the RecoveryBox for monitoring the installation.

### Optional

- A USB GPS receiver.
- An RTL-SDR compatible USB key.

---

# Installation Steps

## 1. Preparing the installation media

!!! warning "Important"
    These steps must be performed in WSL or on a Linux system. Using Windows alone is not supported.
    This step must be performed on a **different** computer from the one that will be used as RecoveryBox. The target computer must boot from the generated USB key.

1. Download the [debian-13-preseed-RB](https://github.com/mr-dgidgi/debian13-preseed-RB) repository.
2. Download the latest **Debian 13 Netinst** image from https://www.debian.org/download and place it in the `debian13-preseed-RB` folder.
3. Generate the custom installation image:

```bash
./make-preseed-iso.sh debian-13.X.X-amd64-netinst.iso
```

4. Create a bootable USB key from the file:

```text
preseed-debian-13.X.X-amd64-netinst.iso
```

---

## 2. System installation

1. Connect the network cable to the Ethernet port of the future RecoveryBox.
2. Boot the machine from the USB key.
3. Wait until the automated Debian installation is fully complete.
4. Connect the hardware peripherals:
   - Wi-Fi key (if no internal Wi-Fi card is present);
   - USB GPS receiver *(optional)*;
   - RTL-SDR key *(optional)*.

---

## 3. RecoveryBox installation

1. Log in:

```text
Username: recuser
Password: Recovery
```

2. Switch to administrator:

```bash
sudo su -
```

Password:

```text
Recovery
```

3. Create the data directory:

```bash
mkdir /data
```

4. Clone the project repository:

```bash
git clone https://github.com/mr-dgidgi/RecoveryBox.git
```

5. Launch the installation script:

```bash
cd RecoveryBox
bash RecoveryBox_install.sh
```

---

## 4. Installation process

The installation script automatically performs the following operations, combining the script's direct actions with those executed by the Ansible playbook it invokes:

### Phase 1 — Checks and prerequisites (script)

| Step | Description |
|------|-------------|
| Prerequisites check | Verifies administrator rights, amd64 architecture, presence of the `/data` directory, and Debian system. |
| Hardware check | Checks for a Wi-Fi interface for the access point. |
| Keyboard layout | Offers to reconfigure the keyboard layout (optional). |
| Ansible installation | Installs Ansible, python3-docker, python3-apt, and Galaxy collections (community.docker). |

### Phase 2 — Interactive configuration (script)

| Step | Description |
|------|-------------|
| Language selection | Selects the language for installed content (French, English, or both). |
| Installation mode | Choice between default or custom installation. |
| Service configuration | *(custom mode)* Allows enabling or disabling each service individually (Apache, Library, BRouter, TileServer, Meshtastic, Console, OpenWebRX, Kiwix). |
| Kiwix downloads | *(custom mode)* Configures Wikipedia FR/EN download and desired size (all_mini, all_no_pic, all_maxi). |
| Meshtastic node configuration | *(custom mode)* Sets the IP address and MAC of a Meshtastic node (optional). |
| Config file generation | Writes the `/etc/recoverybox/custom_config.yml` file with the selected options. |

### Phase 3 — Ansible playbook (automatic)

| Step | Description |
|------|-------------|
| **System environment** | Installs base packages (curl, git, wget, Realtek/IWLWifi firmware, gpsd, chrony, tippecanoe, etc.) and creates system directories. |
| **Network configuration** | Deploys iptables scripts, enables IPv4 routing, and configures the firewall. |
| **Docker installation** | Installs Docker and its dependencies. |
| **GPS configuration** | Configures GPSD and Chrony for time synchronization via GPS. |
| **Management tools** | Installs rbstatus, services-manager, network-configurator, and the service registry file. |
| **Kiwix installation** | Deploys the Kiwix Docker container (offline Wikipedia content server). |
| **Kiwix download** | Downloads Wikipedia ZIM files according to configuration (FR/EN, chosen size). |
| **Wi-Fi access point** | Installs and configures the **recoverybox** hotspot (simple-hotspot, hostapd, dnsmasq). |
| **Apache2** | Installs and configures the Apache2 web server with service VirtualHosts. |
| **PDF Library** | Downloads survival documents matching the selected language. |
| **Web Console** | Deploys ShellInABox for remote administration. |
| **TileServer-GL** | Installs the cartography server and the Liberty map style. |
| **Mapping tools** | Installs Planetiler (Docker container) and the `generate-map` tool. |
| **BRouter** | Installs the routing engine and downloads routing data. |
| **OpenWebRX Plus** | Deploys the browser-accessible SDR interface. |
| **RTL-SDR drivers** | Compiles and installs the latest RTL-SDR Blog drivers. |
| **Meshtastic Web Client** | Deploys the Meshtastic web client (Docker container). |
| **Meshtastic Daemon** | Installs the Python daemon and BRouter cartography integration. |
| **MkDocs** | Deploys the RecoveryBox technical wiki (MkDocs Material Docker container). |

### Phase 4 — Finalization (script)

| Step | Description |
|------|-------------|
| Map generation | Offers to download additional maps (continent/country) via `generate-map`. |
| Network configuration | Checks and configures network interfaces if needed (renaming, bridges, systemd-networkd). |
| Version recording | Copies the version file to `/etc/recoverybox/`. |
| Reboot | Requests a system reboot to apply all changes. |

---

## 5. First boot

Once the installation is complete:

1. Reboot the RecoveryBox.
2. Connect a computer or smartphone to the Wi-Fi access point:

```text
SSID: recoverybox
Password: recoverybox
```

3. Open a browser and navigate to:

```text
http://recovery.box
```

The RecoveryBox is now operational.
