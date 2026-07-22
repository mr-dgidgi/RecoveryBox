---
title: Wi-Fi Hotspot
description: Autonomous Wi-Fi access point based on simple-hotspot, hostapd and dnsmasq.
tags:
  - service
  - network
---

# Wi-Fi Hotspot

## Overview

RecoveryBox integrates a Wi-Fi access point allowing users to connect directly to the machine without any external network infrastructure.

The access point is fully containerized and based on the **[simple-hotspot](https://github.com/mr-dgidgi/Simple-Hotspot)** project, running in a Docker container. This container bundles the various services required for an autonomous access point:

- **hostapd** for creating the Wi-Fi network;
- **dnsmasq** for the DHCP and DNS server;
- routing handled by the host system via systemd-networkd and IPtables.

The service starts automatically at RecoveryBox boot. Users access all services simply by connecting to the Wi-Fi network.

### How it works

#### Wi-Fi Interface

During installation, a Wi-Fi interface is automatically renamed to `wlanAP`. This interface is exclusively reserved for the access point. The `wpa_supplicant` service is disabled on this interface so it can be used in Access Point mode by hostapd.

#### Network Bridge

The `wlanAP` interface is automatically attached to the **Lan** network bridge. As a result, all Wi-Fi clients end up on the same network as any equipment connected to the LAN bridge. The bridge is created by `network-configurator` during installation.

#### IP Address Assignment

IP addresses are automatically distributed by **dnsmasq**. Clients receive an IP address, the gateway, and DNS servers. No manual configuration is required on the client side.

#### Internet Access

When the **Wan** interface has an Internet connection, the IPtables service automatically sets up NAT to share this connection with Wi-Fi clients. The behavior is then similar to a home router.

## Service Access

The hotspot Wi-Fi network is available immediately at RecoveryBox startup.

| Network | Description |
| --- | --- |
| `recoverybox` (default) | Access point Wi-Fi network |

## Advanced Configuration

### A. Configuration Files

| Item | Description |
| --- | --- |
| `/etc/ap_config/hostapd.conf` | Access point configuration (SSID, channel, WPA2 password) |
| `/etc/ap_config/dnsmasq.conf` | DHCP/DNS server configuration |
| `/etc/ap_config/ap_start.sh` | Startup script executed before launching the Docker container |

### B. Customization

#### Modifying the Wi-Fi network

!!! warning "Centralized configuration"
    The hotspot Wi-Fi configuration files are managed by the `RecoveryBox_install.sh` script. Any manual modification of these files will be overwritten during an update or reinstallation. To customize the hotspot, it is recommended to use the `recoverybox_hotspot_conf` variables in the `/etc/recoverybox/custom_config.yml` file.

The file `/etc/ap_config/hostapd.conf` allows modifying:

- the network name (SSID);
- the Wi-Fi channel;
- the band used (2.4 GHz or 5 GHz depending on hardware);
- the WPA2 password;
- the country (`country_code`);
- radio performance settings.

#### Modifying the DHCP server

The file `/etc/ap_config/dnsmasq.conf` allows modifying:

- the range of distributed IP addresses;
- DNS servers;
- DHCP lease duration;
- various DHCP options.

!!! info "Restart required"
    Any configuration change requires restarting the service via the `service-manager`.

#### Configuration via custom_config.yml

Here is an example of configuration to customize the Wi-Fi hotspot in the `/etc/recoverybox/custom_config.yml` file:

```yaml
recoverybox_hotspot_conf:
  ssid: "recoverybox" # Hostapd
  password: "my_password" # Hostapd
  mode: "g" # Hostapd - 2.4GHz: g or b (legacy), 5GHz/6GHz: a, acs if supported by the card
  channel: "11" # Hostapd - 2.4GHz: 1/7/11, 5GHz: 36-165, 6GHz: 1-233, 0 or acs if supported by the card
  auth_algs: "1" # Hostapd
  wpa: "2" # Hostapd
  wpa_key_mgmt: "WPA-PSK" # Hostapd
  wpa_pairwise: "TKIP CCMP" # Hostapd
  rsn_pairwise: "CCMP" # Hostapd
  network: "192.168.4.0" # DNSmasq
  mask: "24" # DNSmasq
  ip: "192.168.4.1" # DNSmasq
  dhcp_range_start: "192.168.4.100" # DNSmasq
  dhcp_range_end: "192.168.4.200" # DNSmasq
```

### C. Debugging

```bash
# View hotspot logs
journalctl -u ap.service -f
```
