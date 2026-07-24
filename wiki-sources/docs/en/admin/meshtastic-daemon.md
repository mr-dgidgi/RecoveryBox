---
title: meshtastic-daemon
description: Daemon collecting Meshtastic node positions and displaying them on the BRouter map.
tags:
  - tool
  - meshtastic
  - cartography
---

# Meshtastic Daemon

## Overview

`meshtastic-daemon` is a Python script that connects to a Meshtastic node via TCP, retrieves position information and metrics from detected nodes, and generates a GeoJSON file used by the BRouter map to display LoRa mesh network nodes.

The daemon runs automatically every minute via a cron job and updates the file `/data/brouter/www/meshtastic_nodes.json` containing active node positions.

### Key Features

- TCP connection to Meshtastic node (using `TCPInterface`)
- Position extraction (latitude, longitude) and metrics (battery, SNR, last contact)
- Active node filtering (last heard < 7 days)
- GeoJSON file generation for BRouter map display
- Atomic file writing (using temp file + `os.replace`)

---

## How it Works

### Daemon Execution

The daemon is executed every minute by cron:

```bash
* * * * * root /data/brouter/meshtastic-daemon.py <NODE_IP>
```

The Meshtastic node IP address is passed as an argument and configured during installation via the Ansible variable `recoverybox_meshtastic_node.ip`.

### Detailed Process

1. **Connection**: The script establishes a TCP connection to the Meshtastic node
2. **Collection**: It iterates over all visible nodes (`interface.nodes`)
3. **Filtering**: Only nodes with valid coordinates and `lastHeard` < 604800 seconds (7 days) are kept
4. **GeoJSON Generation**: Each node is converted to a GeoJSON feature with its properties
5. **Atomic Writing**: The file is written to a temporary file then renamed to prevent corruption

### GeoJSON Structure

Each node is represented as a GeoJSON point with the following properties:

```json
{
  "type": "Feature",
  "geometry": {
    "type": "Point",
    "coordinates": [longitude, latitude]
  },
  "properties": {
    "name": "Node name",
    "id": "Node ID",
    "battery_level": 85,
    "snr": 9.5,
    "last_heard": "2024-01-15T10:30:00Z"
  }
}
```

---

## File Interactions

### Main Files

| File | Description |
|------|-------------|
| `/data/brouter/meshtastic-daemon.py` | Main daemon script |
| `/data/meshtastic_env/` | Python virtual environment containing the `meshtastic` package |
| `/etc/cron.d/meshtastic-daemon` | Cron configuration running the daemon every minute |
| `/data/brouter/www/meshtastic_nodes.json` | Output GeoJSON file (auto-updated) |
| `/data/brouter/www/recoverybox-mesh.js` | Client-side JavaScript for map display |
| `/data/brouter/www/mesh-node.png` | Icon for nodes displayed on the map |

### Configuration

The daemon uses the following configuration defined in `/etc/recoverybox/custom_config.yml`:

```yaml
recoverybox_meshtastic_node:
  mac: "00:00:00:00:00:00"
  ip: "192.168.200.101"
```

---

## Advanced Configuration

### Modifying the Node IP Address

To change the IP address of the Meshtastic node connected to the daemon:

1. Edit the configuration file:

```bash
nano /etc/recoverybox/custom_config.yml
```

2. Modify the `recoverybox_meshtastic_node.ip` value

3. Restart the cron service to apply changes:

```bash
systemctl restart cron.service
```

!!! info "Verification"
    You can verify the current cron configuration by checking the file `/etc/cron.d/meshtastic-daemon`.

### Modifying the Execution Frequency

To change the daemon execution frequency (default: every minute):

1. Edit the cron file:

```bash
nano /etc/cron.d/meshtastic-daemon
```

2. Modify the cron line according to your needs. For example, to execute every 5 minutes:

```bash
*/5 * * * * root /data/brouter/meshtastic-daemon.py <NODE_IP>
```

3. Save and exit. Changes will be applied automatically.

---

## Debug

### Check Cron Status

```bash
systemctl status cron.service
```

### View Cron Logs

```bash
journalctl -u cron.service -f
```

### Verify Output File

Check that the GeoJSON file is being updated:

```bash
ls -lh /data/brouter/www/meshtastic_nodes.json
cat /data/brouter/www/meshtastic_nodes.json | head -20
```

### Manual Daemon Execution

To test the daemon manually:

```bash
python3 /data/brouter/meshtastic-daemon.py 192.168.200.101
```

Replace `192.168.200.101` with your Meshtastic node's IP address.

### View Daemon Logs

The daemon does not write persistent logs. In case of errors, you can redirect output to a file:

```bash
python3 /data/brouter/meshtastic-daemon.py 192.168.200.101 > /tmp/meshtastic-debug.log 2>&1
```

### Common Issues

| Issue | Probable Cause | Solution |
|-------|----------------|----------|
| Empty JSON file | Meshtastic node unreachable | Check IP and network connectivity |
| `ModuleNotFoundError` | Python environment not configured | Reinstall daemon via Ansible |
| No nodes displayed | No active nodes in range | Verify Meshtastic nodes are powered and in range |

### Connectivity Testing

Test connection to Meshtastic node:

```bash
ping <NODE_IP>
```

Verify TCP port is accessible:

```bash
nc -zv <NODE_IP> 4403
```

---

!!! info "External Documentation"
    - [Official Meshtastic Website](https://meshtastic.org/)
    - [Meshtastic Python API Documentation](https://python.meshtastic.org/)
    - [BRouter Project](https://brouter.de/)
