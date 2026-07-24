---
title: Meshtastic Web Client
description: Web client for interacting with Meshtastic nodes and visualizing the mesh network on the cartography.
tags:
  - service
  - meshtastic
  - network
---

# Meshtastic Web Client

## Overview

**Meshtastic** is an open-source project that uses LoRa radios as low-power mesh communication nodes. The Meshtastic network operates without existing infrastructure: each node relays messages from others, forming a decentralized and resilient network, ideal for emergency situations or isolated environments.

RecoveryBox integrates two Meshtastic-related components:

- **Meshtastic Web Client**: web interface for interacting with Meshtastic nodes connected to the local network (via Wi-Fi), or directly from a client browser (via Bluetooth or WebSerial).
- **Meshtastic Daemon**: background service that polls a configured Meshtastic node and exposes its data (discovered nodes, positions, status) on the RecoveryBox BRouter map.

**Meshtastic Daemon** is detailed on its dedicated page **[Meshtastic Daemon](../admin/meshtastic-daemon.md)**.

For more details about the project, consult the **[official Meshtastic documentation](https://meshtastic.org)** and the **[GitHub repository](https://github.com/meshtastic/web)**.

### Properties

| Property | Value |
| --- | --- |
| **Type** | Docker container (systemd service) + Python daemon |
| **Image** | `mrdgidgi/meshtastic-web-client` |
| **Port** | `18000` (host) → `80` (container) |
| **Activation variable** | `recoverybox_enable_meshtastic` |

## Service Access

The Meshtastic web interface is accessible to all users connected to the RecoveryBox hotspot.

| URL | Description |
| --- | --- |
| [http://meshtastic.recovery.box](http://meshtastic.recovery.box) | Meshtastic web interface |

!!! info "Connecting to a node"
    From the web interface, you can connect to a Meshtastic node in two ways:
    - **Wi-Fi**: the node must be connected to the RecoveryBox network (automatic DHCP reservation configured via `recoverybox_meshtastic_node`)
    - **Bluetooth / WebSerial**: direct connection from the client browser to a nearby node

## Advanced Configuration

### A. Configuration Files

| Item | Description |
| --- | --- |
| `/etc/systemd/system/meshtastic-web.service` | Systemd unit for the Docker container |
| `/etc/apache2/sites-available/meshtastic-web.conf` | Apache2 VirtualHost (reverse proxy) |

### B. Customization

#### Meshtastic node configuration

!!! note "Optional"
    Configuring a Meshtastic node is optional. The MAC address and IP address are used to create a DHCP reservation in dnsmasq, ensuring the Meshtastic node always receives the same address on the hotspot network. The service does not depend on this reservation and can work with any Meshtastic node connected to the local network or directly via Bluetooth/WebSerial on the client machine.

During installation via `RecoveryBox_install.sh`, it is possible to configure the IP address and MAC address of a Meshtastic node to connect. These values are stored in `/etc/recoverybox/custom_config.yml`:

You can also manually modify these values in the configuration file, then relaunch the script to apply the changes.

```yaml
recoverybox_meshtastic_node:
  mac: "AA:BB:CC:DD:EE:FF"
  ip: "192.168.200.101"
```

### C. Debugging

```bash
# View web client logs
journalctl -u meshtastic-web.service -f

# Verify the container is running
docker ps | grep meshtastic
```
