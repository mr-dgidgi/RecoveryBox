---
title: Debug
description: Quick troubleshooting guide for RecoveryBox services and components.
tags:
  - tool
  - debug
---

# Debug

This guide provides troubleshooting tips to resolve the most common issues encountered with RecoveryBox services. The goal is to enable **basic debugging** without requiring advanced skills.

!!! info "Global monitoring tool"
    Before diagnosing an individual service, run the `rbstatus` command to get an overview of all services, GPS, and system status. See the dedicated page: [**rbstatus**](./rbstatus.md).

---

## Hotspot

The Wi-Fi hotspot is the main entry point to the RecoveryBox. If users cannot connect to the `recoverybox` network, no web service will be accessible.

### Service check

```bash
# Access point service status
systemctl status ap.service

# Real-time hotspot logs
journalctl -u ap.service -f

# Verify that the container is running
docker ps | grep hotspot
```

### Wi-Fi interface check

```bash
# Verify that the wlanAP interface exists
ip link show wlanAP
```

### DHCP / DNS check

```bash

# View distributed DHCP leases
docker exec -ti hotspot cat /var/lib/misc/dnsmasq.leases
```

### Common issues

| Issue | Possible cause | Solution |
| --- | --- | --- |
| The `recoverybox` network doesn't appear | Wi-Fi interface not renamed to `wlanAP` | Check with `ip link` and re-run `network-configurator` |
| Connected to network but no web access to http://recovery.box | Apache2 service unavailable | Check with `systemctl status apache2.service` |
| Connected to network but no internet access | Ethernet cable not plugged in, WAN (or wlan) interface not configured | Check interface and route status with `ip link` and `ip route` |
| No IP address assigned | No more IPs available in the DHCP pool | Check DHCP leases `docker exec -ti hotspot cat /var/lib/misc/dnsmasq.leases` and verify available range `cat /etc/ap_config/dnsmasq.conf` |

!!! info "Official documentation"
    The hotspot is based on the **[Simple-Hotspot](https://github.com/mr-dgidgi/Simple-Hotspot)** project. See the service page for details: [**Hotspot**](../services/hotspot.md).

---

## Cartography

The cartography service relies on **Brouter** (routing engine) and **TileServer-GL** (tile server).

### Service check

```bash
# BRouter service status
systemctl status brouter.service

# BRouter logs
journalctl -u brouter.service

# TileServer-GL service status
systemctl status tileserver-gl.service

# TileServer-GL logs
journalctl -u tileserver-gl.service
```

### Map check

```bash
# Verify that map.mbtiles exists
ls -lh /data/tileserver/map.mbtiles

# Verify that brouter responds
curl -I http://localhost:17777/

#   Verify that tileserver-gl responds
curl -I http://localhost:8090/
```

### Apache check

```bash
# Verify that Apache2 is active
systemctl status apache2.service

# Carto access logs
cat /var/log/apache2/carto_access.log

# Carto error logs
cat /var/log/apache2/carto_error.log
```

### Common issues

| Issue | Possible cause | Solution |
| --- | --- | --- |
| Map displays blank | `map.mbtiles` file missing or corrupted | Generate a map with `generate-map` |
| "tile not found" error | Tiles not generated for the requested area | Check the zoom level and covered area |
| BRouter not responding | Service not started | `systemctl start brouter.service` |

!!! info "Official documentation"
    - **[BRouter](https://github.com/abrensch/brouter)** — Routing engine
    - **[TileServer-GL](https://tileserver.readthedocs.io/en/latest/)** — Map tile server
    - Service page: [**Cartography**](../services/carto.md)
    - Generation tool: [**generate-map**](./generate-map.md)

---

## GPS Location

The RecoveryBox location is displayed on the BRouter map. Its positioning depends on the GPS service (gpsd).

### GPS check

```bash
# GPS service status
systemctl status gpsd.service

# View GPS data in real time
gpspipe -w -n 10
```

### Verify that the dedicated cron is working

```bash
# Verify that the cron service has no errors
journalctl -u cron.service

# Verify that the JSON file is properly generated
ls -la /data/brouter/www/recoverybox.json

# Test the JSON file generation script
bash -x /data/brouter/gps-to-json.sh
```

### Common issues

| Issue | Possible cause | Solution |
| --- | --- | --- |
| GPS position not displayed on map | No GPS fix | Check that GPS receives data with `gpspipe` |
| No satellites detected | GPS antenna poorly connected or obstructed | Place the GPS antenna outside or near a window |

!!! info "Documentation"
    See the page: [**System Tools**](./system-tools.md) for more details on gpsd and chrony.

---

## Meshtastic POIs

Meshtastic points of interest represent LoRa mesh network nodes on the map.

### Meshtastic daemon check

```bash
# Verify that the cron service has no errors
journalctl -u cron.service

# Verify that the JSON file is properly generated
ls -la /data/brouter/www/meshtastic_nodes.json

# Test the JSON file generation script
python3 /data/brouter/meshtastic-daemon.py
```

### Meshtastic node check

```bash
# Verify that the IP in the cron file matches the Meshtastic node IP
cat /etc/cron.d/meshtastic-daemon
cat /etc/ap_config/dnsmasq.conf | grep dhcp-host

# Verify that the node is visible from the RecoveryBox
ping -c 3 <Meshtastic_node_IP>
```

### Common issues

| Issue | Possible cause | Solution |
| --- | --- | --- |
| No nodes displayed on map | Daemon not running or node not connected | Check daemon status and node connectivity |
| Meshtastic node not detected | DHCP reservation missing | Check MAC/IP configuration in `custom_config.yml` |

!!! info "Official documentation"
    - **[Meshtastic](https://meshtastic.org)** — Official project documentation
    - **[Meshtastic Web](https://github.com/meshtastic/web)** — Web client GitHub repository
    - Service page: [**Meshtastic Web Client**](../services/meshtastic.md)

---

## Kiwix

Kiwix provides offline access to Wikipedia and other ZIM resources.

### Service check

```bash
# Kiwix service status
systemctl status kiwix.service

# Real-time logs
journalctl -u kiwix.service -f
```

### Container check

```bash
# Verify that the container is running
docker ps | grep kiwix

# Test HTTP access
curl -I http://localhost:8080/
```

### ZIM files check

```bash
# List available ZIM files
ls -lh /data/kiwix/
```

### Apache check

```bash
# Verify that Apache2 is active
systemctl status apache2.service

# Carto access logs
cat /var/log/apache2/carto_access.log

# Carto error logs
cat /var/log/apache2/carto_error.log
```

### Common issues

| Issue | Possible cause | Solution |
| --- | --- | --- |
| Blank page or 502 error | Docker container stopped | `systemctl restart kiwix.service` |
| No content available | ZIM files missing from `/data/kiwix/` | Download files from [browse.library.kiwix.org](https://browse.library.kiwix.org/) |
| New ZIM file not detected | Kiwix doesn't auto-reload | Restart the service after adding a file |

!!! info "Official documentation"
    - **[Kiwix](https://wiki.kiwix.org)** — Official documentation
    - **[Kiwix-serve](https://github.com/kiwix/kiwix-serve)** — GitHub repository
    - **[ZIM file library](https://browse.library.kiwix.org/)** — Content downloads
    - Service page: [**Kiwix**](../services/kiwix.md)

---

## Console

The web administration console uses ShellInABox to provide shell access via the browser.

### Service check

```bash
# ShellInABox service status
systemctl status shellinabox.service

# Test HTTP access
curl -I -H "Host: console.recovery.box" http://127.0.0.1:4200/
```

### Apache logs check

```bash
# Access logs
cat /var/log/apache2/console_access.log

# Error logs
cat /var/log/apache2/console_error.log
```

### Common issues

| Issue | Possible cause | Solution |
| --- | --- | --- |
| Console doesn't load | shellinabox service stopped | `systemctl start shellinabox.service` |
| "Connection refused" error | Apache2 VirtualHost misconfigured | Check `/etc/apache2/sites-available/console.conf` |
| Credentials rejected | Default password modified | Reset with `passwd recuser` |

!!! info "Official documentation"
    - **[ShellInABox](https://github.com/shellinabox/shellinabox)** — GitHub repository
    - Service page: [**Console**](../services/console.md)

---

## Library

The library is a static web server hosting survival PDF documents.

### Apache service check

```bash
# Verify that the VirtualHost is enabled
apache2ctl -S | grep library

# Test HTTP access
curl -I -H "Host: library.recovery.box" http://127.0.0.1/
```

### Logs check

```bash
# Access logs
cat /var/log/apache2/library.access.log

# Error logs
cat /var/log/apache2/library.error.log
```

### Content check

```bash
# Verify PDF presence
ls -la /data/library/PDF/
cat /data/library/library.json | jq '.pdfs[]'

# Check custom PDFs
ls -la /data/library/PDF/custom/
cat /data/library/custom-library.json | jq '.pdfs[]'
```

### Common issues

| Issue | Possible cause | Solution |
| --- | --- | --- |
| 404 error on library.recovery.box | VirtualHost not enabled | `a2ensite library.conf && systemctl reload apache2` |
| New PDF not visible | Update script not run | Run `python3 /data/library/library-update.py` then restart Apache |
| Empty page | Incorrect DocumentRoot path | Check the path in `/etc/apache2/sites-available/library.conf` |

!!! info "Documentation"
    - Library repository: [**mr-dgidgi/rb-library**](https://github.com/mr-dgidgi/rb-library)
    - Service page: [**Library**](../services/library.md)

---

## OpenWebRX

OpenWebRX Plus is the SDR radio receiver accessible via the browser.

### Service check

```bash
# OpenWebRX service status
systemctl status openwebrx.service

# Real-time logs
journalctl -u openwebrx.service -f
```

### SDR hardware check

```bash
# Verify that the RTL-SDR dongle is detected
lsusb | grep RTL
# or
dmesg | grep rtl
```

### Access check

```bash
# Test HTTP access (port 8073)
curl -I http://localhost:8073/
```

### Common issues

| Issue | Possible cause | Solution |
| --- | --- | --- |
| Interface inaccessible | openwebrx service stopped | `systemctl start openwebrx.service` |
| "no SDR device" error | RTL-SDR dongle not plugged in or driver missing | Check `lsusb` and install RTL-SDR drivers |
| No audio | Browser blocks audio autoplay | Allow audio autoplay for `recovery.box:8073` |

!!! info "Official documentation"
    - **[OpenWebRX](https://www.openwebrx.de)** — Original project documentation
    - **[OpenWebRX Plus](https://github.com/luarvique/openwebrx-plus)** — Enhanced fork used by RecoveryBox
    - Service page: [**OpenWebRX Plus**](../services/owrx.md)

---

## Network

The RecoveryBox network configuration is based on **systemd-networkd** and **network bridges**.

### General network status

```bash
# Display all interfaces and bridges
network-configurator status

# Display generated network configuration
network-configurator GetVInterfacesConfig
```

### systemd-networkd check

```bash
# Network service status
systemctl status systemd-networkd

# Network logs
journalctl -u systemd-networkd
```

### Interface check

```bash
# List network interfaces
ip link show

# List Wi-Fi interfaces
iw dev

# Check assigned IP addresses
ip addr show
```

### Firewall check

```bash
# iptables service status
systemctl status iptables

# View active rules
iptables -nvL
iptables -t nat -nvL
```

### Routing check

```bash
# Routing table
ip route show

# Test Internet connectivity
ping -c 3 8.8.8.8

# Test DNS resolution
nslookup google.com
```

### Common issues

| Issue | Possible cause | Solution |
| --- | --- | --- |
| No interfaces visible | systemd-networkd not started | `systemctl restart systemd-networkd` |
| No Internet access | WAN interface not configured | Use `network-configurator` to configure the interface |
| Wi-Fi clients have no IP | dnsmasq not working | `systemctl restart ap.service` |
| Ping to outside fails | Blocking iptables rules | Check `/etc/iptables/iptables.sh` and restart the service |

!!! info "Documentation"
    - Tool page: [**network-configurator**](./network-configurator.md)
    - Network page: [**Network Configuration**](./network.md)
    - **[systemd-networkd — Debian Wiki](https://wiki.debian.org/SystemdNetworkd)**

---

## Docker

Many RecoveryBox services are containerized with Docker. When issues arise, it's useful to check Docker and container status.

### General check

```bash
# Docker service status
systemctl status docker

# List running containers
docker ps

# List all containers (including stopped)
docker ps -a
```

### Container logs

```bash
# Logs of the last concerned container
docker logs <container_name>

# Real-time logs
docker logs -f <container_name>
```

### Restart a container

```bash
# Restart via systemd (recommended)
systemctl restart <service>.service

# Direct container restart (last resort)
docker restart <container_name>
```

### Cleanup

```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune
```

!!! warning "Important"
    Always prefer restarting via `systemctl` rather than directly restarting Docker. The systemd service manages dependencies and volume mounts.

---

## Apache2

Several services (cartography, console, library, wiki, etc.) are served through Apache2 VirtualHosts.

### Service check

```bash
# Apache2 service status
systemctl status apache2

# Test configuration
apache2ctl configtest
```

### VirtualHost check

```bash
# List enabled VirtualHosts
apache2ctl -S

# List enabled sites
ls -la /etc/apache2/sites-enabled/
```

### Logs

```bash
# Global error logs
tail -f /var/log/apache2/error.log

# Global access logs
tail -f /var/log/apache2/access.log
```

### Common issues

| Issue | Possible cause | Solution |
| --- | --- | --- |
| All web services unavailable | Apache2 stopped | `systemctl start apache2` |
| Single service not responding | VirtualHost disabled | `a2ensite <service>.conf && systemctl reload apache2` |
| SSL error | Certificate missing or expired | Check files in `/etc/ssl/` |

---

## GPS & Time Synchronization

The GPS provides position and enables time synchronization via Chrony.

### GPSD check

```bash
# GPS service status
systemctl status gpsd.service

# Raw GPS data
gpspipe -w -n 5

# Check position
cgps -s
```

### Chrony check

```bash
# Chrony service status
systemctl status chrony.service

# Synchronization sources
chronyc sources

# Synchronization accuracy
chronyc tracking
```

### Common issues

| Issue | Possible cause | Solution |
| --- | --- | --- |
| "No GPS device" in rbstatus | USB GPS not detected | Check `lsusb` and logs: `dmesg | grep tty` |
| No GPS fix | Weak signal or obstructed antenna | Move GPS antenna to an unobstructed location |
| Incorrect time | Chrony not synchronized | Check `chronyc sources` and NTP connectivity |

!!! info "Documentation"
    See the page: [**System Tools**](./system-tools.md) for more details on gpsd and chrony.

---

## Useful Debug Commands

Here is a summary of the most useful commands for everyday troubleshooting:

| Command | Description |
| --- | --- |
| `rbstatus` | Display status of all services, GPS, and system |
| `systemctl status <service>` | Status of a systemd service |
| `journalctl -u <service> -f` | Real-time logs of a service |
| `docker ps` | Running Docker containers |
| `docker logs -f <container>` | Logs of a Docker container |
| `network-configurator status` | Interface and network bridge status |
| `curl -I http://localhost:<port>/` | Test HTTP access to a service |
| `ip link show` | List network interfaces |
| `free -h` | Available memory |
| `df -h` | Available disk space |

!!! tip "Tip"
    When in doubt, a full reboot of the RecoveryBox (`reboot`) often resolves temporary issues related to service startup.
