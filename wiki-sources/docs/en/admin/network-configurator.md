---
title: network-configurator
description: Interactive network configuration tool for systemd-networkd, managing bridges, interfaces, and firewall.
tags:
  - tool
  - network
---

# Network Configurator

## Overview

`network-configurator` is a network configuration tool for Linux systems using **systemd-networkd**. It allows creating and modifying network configuration interactively or via command-line commands.

The main goal is to simplify RecoveryBox deployment and maintenance by automating network configuration file generation without manual manipulation.

Key features include:

- configuration of physical or virtual network interfaces;
- bridge creation;
- linking physical interfaces to a bridge;
- persistent network interface renaming based on MAC address;
- Wi-Fi interface configuration in client mode;
- automatic addition of WAN interfaces to the firewall configuration;
- display of interface status and current configuration.

The tool works both via an interactive menu and in non-interactive mode for integration into installation or automation scripts.

---

## How it works

The script relies on **systemd-networkd** and automatically generates configuration files in `/etc/systemd/network`.

File organization follows systemd's priority convention:

| Prefix | Type |
|--------|------|
| `10-*.link` | interface renaming |
| `20-*.netdev` | virtual interface creation (bridges) |
| `30-*.network` | interface network configuration |

Changes made by the configurator are only applied after restarting **systemd-networkd** (or the system for `.link` files).

The script has two operating modes:

---

## Usage Guide

### Interactive mode

Without arguments, a menu allows:

- viewing interface status;
- displaying current configuration;
- configuring an interface;
- configuring a Wi-Fi interface;
- creating bridge ↔ interface associations;
- renaming physical interfaces.

The different steps guide the user and perform necessary checks before writing files.

### Command-line mode

The script can be run without going through the interactive interface. Each action is available as a command, enabling use in installation or automation scripts (Ansible, AWX, post-installation scripts, etc.).

#### General syntax

```bash
network-configurator <command> [arguments]
```

---

#### CreateBridge

Creates a virtual interface of type **bridge**.

**Syntax**

```bash
network-configurator CreateBridge <bridge>
```

**Arguments**

| Argument | Description |
|----------|-------------|
| `<bridge>` | Name of the bridge to create. |

**Example**

```bash
network-configurator CreateBridge Lan
```

---

#### GetPhysicalInterfaces

Displays all detected physical network interfaces and their status.

**Syntax**

```bash
network-configurator GetPhysicalInterfaces
```

No arguments expected.

---

#### GetVInterfacesConfig

Displays the generated network configuration.

**Syntax**

```bash
network-configurator GetVInterfacesConfig [interface]
```

**Arguments**

| Argument | Description |
|----------|-------------|
| `interface` | *(optional)* Name of the interface to display. If absent, all configurations are displayed. |

**Examples**

```bash
network-configurator GetVInterfacesConfig
```

```bash
network-configurator GetVInterfacesConfig Wan
```

---

#### RenameInterface

Permanently renames a network interface based on its MAC address.

**Syntax**

```bash
network-configurator RenameInterface <mac-address> <new-name>
```

**Arguments**

| Argument | Description |
|----------|-------------|
| `<mac-address>` | MAC address of the interface. |
| `<new-name>` | New name to assign. |

**Example**

```bash
network-configurator RenameInterface 00:11:22:33:44:55 Wan
```

---

#### LinkInterface

Opens the interactive menu for linking or unlinking physical interfaces to existing bridges.

**Syntax**

```bash
network-configurator LinkInterface
```

No arguments.

---

#### SetInterface

Creates or directly modifies an interface configuration.

**Syntax**

```bash
network-configurator SetInterface \
    <interface> \
    <dhcp> \
    <address> \
    <gateway> \
    <dns> \
    <network-options> \
    <dhcpv4-options> \
    <ipv6acceptra-options>
```

**Arguments**

| Argument | Description |
|----------|-------------|
| `<interface>` | Name of the interface to configure. |
| `<dhcp>` | `yes` or `no`. |
| `<address>` | IP address with mask (`192.168.1.10/24`). Ignored if DHCP=`yes`. |
| `<gateway>` | Default gateway. |
| `<dns>` | Space-separated list of DNS servers. Use `no` to skip DNS directive. |
| `<network-options>` | Additional options for the `[Network]` section. Use `no` if none. |
| `<dhcpv4-options>` | Content of the `[DHCPv4]` section. Use `no` if none. |
| `<ipv6acceptra-options>` | Content of the `[IPv6AcceptRA]` section. Use `no` if none. |

**DHCP Example**

```bash
network-configurator SetInterface Wan yes "" "" "1.1.1.1 9.9.9.9" no no no
```

**Static IP Example**

```bash
network-configurator SetInterface \
    Lan \
    no \
    192.168.10.1/24 \
    192.168.10.254 \
    "1.1.1.1 9.9.9.9" \
    no \
    no \
    no
```

---

#### MenuSetInterface

Launches the interactive interface configuration menu.

**Syntax**

```bash
network-configurator MenuSetInterface <interface>
```

**Arguments**

| Argument | Description |
|----------|-------------|
| `<interface>` | Interface to configure. |

---

#### MenuRenameInterface

Launches the interactive interface renaming menu.

**Syntax**

```bash
network-configurator MenuRenameInterface [name]
```

If a name is provided, it is automatically suggested as the new name.

---

#### MenuSetVlan

Configures a Wi-Fi interface in client mode.

**Syntax**

```bash
network-configurator MenuSetVlan
```

The wizard then asks for:

- the SSID;
- the password;
- then automatically configures `wpa_supplicant`.

---

#### ApplyChanges

Proposes restarting `systemd-networkd` to apply changes.

**Syntax**

```bash
network-configurator ApplyChanges
```

---

#### status

Displays the current status of:

- bridges;
- physical interfaces;
- interfaces linked to each bridge.

**Syntax**

```bash
network-configurator status
```

---

#### help

Displays the built-in help.

**Syntax**

```bash
network-configurator help
```

---

## Configuration Files

The configurator modifies several system files.

### systemd-networkd configuration

All files are created in:

```text
/etc/systemd/network/
```

### Renamed interfaces

```text
10-<interface>.link
```

Contains:

- the interface MAC address;
- the new assigned name.

Example:

```ini
[Match]
MACAddress=00:11:22:33:44:55

[Link]
Name=Wan
```

---

### Bridges

```text
20-<bridge>.netdev
```

Declares virtual bridge interfaces.

---

### Network configuration

```text
30-<interface>.network
```

Describes:

- DHCP or static IP;
- DNS;
- gateway;
- advanced systemd-networkd options;
- optional bridge attachment.

---

### Wi-Fi configuration

Wi-Fi interfaces use:

```text
/etc/wpa_supplicant/wpa_supplicant-<interface>.conf
```

The configurator automatically adds selected networks via `wpa_cli`.

---

### Firewall configuration

When the user indicates that an interface is a WAN interface, the script automatically modifies:

```text
/etc/iptables/iptables.sh
```

to add this interface to the `WAN` variable.

The `iptables` service is then restarted.

---

### Backups

Before any modification, the configurator automatically creates a backup of existing files:

```text
<file>.bak
```

These backups allow manual restoration in case of problems.

---

## Debugging

Several commands allow verifying the configurator's operation.

### Check interfaces

```bash
network-configurator status
```

Displays:

- bridges;
- physical interfaces;
- interfaces linked to each bridge.

---

### Check generated configuration

```bash
network-configurator GetVInterfacesConfig
```

or

```bash
cat /etc/systemd/network/*.network
```

---

### Check systemd-networkd status

```bash
systemctl status systemd-networkd
```

---

### Reload configuration

The configurator can automatically restart `systemd-networkd`, but it is also possible to do it manually:

```bash
systemctl restart systemd-networkd
```

---

### Check interface renaming

`.link` files are applied by systemd-networkd.

---

### Check Wi-Fi configuration

```bash
wpa_cli -i <interface> status
```

or

```bash
systemctl status wpa_supplicant@<interface>
```

---

### Check firewall configuration

After adding a WAN interface:

```bash
grep WAN= /etc/iptables/iptables.sh
```

then:

```bash
systemctl status iptables
```

to confirm that the configuration has been reloaded.

---

### Useful logs

In case of problems, the following logs are particularly useful:

```bash
journalctl -u systemd-networkd
```

```bash
journalctl -u wpa_supplicant@<interface>
```

```bash
journalctl -u iptables
```

They help diagnose network configuration or application errors.
