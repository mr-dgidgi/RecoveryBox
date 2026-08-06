---
title: rb-battery - Battery Management via Victron MPPT
description: Documentation of the rb-battery utility for battery monitoring and protection on RecoveryBox
tags:
  - tool
  - administration
  - battery
  - victron
---

# rb-battery - Battery Management via Victron MPPT

## Overview

`rb-battery` is a command-line utility designed for RecoveryBox to monitor battery status via a Victron MPPT charge controller connected via VE.Direct protocol. It reads raw data from the `/dev/victron-mppt` device, formats it as JSON, and monitors battery voltage to trigger a clean system shutdown in case of critical voltage.

Compatible Victron controllers:
- BlueSolar / SmartSolar MPPT 75/10
- BlueSolar / SmartSolar MPPT 75/15
- BlueSolar / SmartSolar MPPT 100/15

!!! info "Architecture"
    The script is deployed via Ansible to `/usr/local/bin/rb-battery.sh` and executed periodically via a cron job.
    Automatic MPPT device detection is handled by the **find-victron** service (see dedicated section).

## find-victron Service - Automatic MPPT Detection

The `find-victron` (systemd) service handles automatic discovery of the Victron MPPT controller at boot and runtime. It creates the `/dev/victron-mppt` symlink required by `rb-battery.sh`.

### How it Works

The script `/etc/victron/find-victron-mppt.sh`:
1. Scans serial ports `/dev/ttyUSB*`
2. Configures port to **19200 baud** (VE.Direct standard)
3. Reads raw data and searches for VE.Direct markers: `PID`, `FW`, `SER#`, `V`, `CS`
4. Requires minimum **3 markers** out of 5 to validate the device
5. Creates symlink `/dev/victron-mppt` pointing to detected device
6. If no device found: waits **300 seconds (5 min)** and retries (infinite loop)
7. Removes symlink if it becomes stale (device unplugged)

### systemd Service

File: `/etc/systemd/system/find-victron.service`

```ini
[Unit]
Description=Service to find Victron MPPT 
[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/etc/victron/find-victron-mppt.sh
[Install]
WantedBy=multi-user.target
```

- **Type=oneshot** + **RemainAfterExit=true**: systemd considers service "active" while script runs (infinite loop)
- Starts automatically at boot (`WantedBy=multi-user.target`)
- Can be restarted via `systemctl restart find-victron` if MPPT is hot-plugged

### Useful Commands

```bash
# Service status
systemctl status find-victron

# Real-time logs
journalctl -u find-victron -f

# Restart detection (e.g., MPPT plugged after boot)
systemctl restart find-victron

# Verify created symlink
ls -l /dev/victron-mppt
```

### Integration with rb-battery

`rb-battery.sh` expects the `/dev/victron-mppt` device. If MPPT is not detected when cron runs:
- `rb-battery.sh` displays `No data received from VE.Direct device`
- `find-victron` continues scanning in background
- Once detected, symlink is created and next cron execution (max 1 min) works normally

!!! tip "Hot-plugging"
    If you plug the MPPT after RecoveryBox boot, either wait for next `find-victron` loop (max 5 min), or run `systemctl restart find-victron` to force immediate detection.

## Usage Guide

### Manual Execution (Single Read)

To display current battery and MPPT status:

```bash
rb-battery.sh
```

Example output:
```text
#########################################################
#################### Battery Status #####################
#########################################################
 =+= Firmware Version                       : 166 
 =+= Serial Number                          : HQ2544JW64Q 
 =+= Battery Voltage                        : 14.19 V
 =+= Battery Current                        : 0.58 A
 =+= Panel Voltage                          : 19.28 V
 =+= Panel Power                            : 9 W
 =+= Charge State                           : 4
 =+= MPPT Channel                           : 1
 =+= Off-Reason                             : 0x00000000
 =+= Error Code                             : 0
 =+= Load Output state                      : ON
 =+= Load Output Current                    : 0 
 =+= Maximum Power Today                    : 147 W
#########################################################
 =+= Error / Warning : 
 =+= None
```

### Watch Mode (Monitoring)

The `watch` mode is used by cron to continuously monitor battery voltage:

```bash
rb-battery.sh watch
```

This mode:
1. Reads MPPT data
2. Checks if battery voltage is below critical threshold (12.0V default for LiFePO4)
3. If critical: waits 10 seconds and retries (up to 3 attempts)
4. After 3 consecutive failures: triggers `low_battery_shutdown` (system poweroff)

!!! warning "System Shutdown"
    The `low_battery_shutdown` function is currently commented out in the script (line 117). To enable automatic shutdown, uncomment the `systemctl poweroff` line in the script.

## Cron Job

Automatic monitoring is configured via a cron entry in `/etc/cron.d/rb-battery`:

```cron
* * * * * root /usr/local/bin/rb-battery.sh watch
```

**Explanation:**
- Runs **every minute** (`* * * * *`)
- As **root** (required for system shutdown)
- Executes script in `watch` mode

!!! note "Frequency"
    Minute-level execution provides rapid response to voltage drops while keeping system load minimal (short serial read + JSON processing).

## Output Information (JSON Output)

The script generates a JSON file `/tmp/vedirect.json` containing all read metrics. Structure:

```json
{
    "Values": [
        { "id": "FW", "name": "Firmware Version", "value": 166, "unit": "" },
        { "id": "SERIAL", "name": "Serial Number", "value": "HQ2544JW64Q", "unit": "" },
        { "id": "V", "name": "Battery Voltage", "value": 14190, "unit": "mV" },
        { "id": "I", "name": "Battery Current", "value": 580, "unit": "mA" },
        { "id": "VPV", "name": "Panel Voltage", "value": 19280, "unit": "mV" },
        { "id": "PPV", "name": "Panel Power", "value": 9, "unit": "W" },
        { "id": "CS", "name": "Charge State", "value": 4, "unit": "" },
        { "id": "MPPT", "name": "MPPT Channel", "value": 1, "unit": "" },
        { "id": "OR", "name": "Off-Reason", "value": "0x00000000", "unit": "" },
        { "id": "ERR", "name": "Error Code", "value": 0, "unit": "" },
        { "id": "LOAD", "name": "Load Output state", "value": "ON", "unit": "" },
        { "id": "IL", "name": "Load Output Current", "value": 0, "unit": "" },
        { "id": "H21", "name": "Maximum Power Today", "value": 147, "unit": "W" }
    ],
    "Timestamp": 1722945600,
    "ErrorMessage": ""
}
```

### Field Details

| ID | Name | Unit | Description |
|----|------|------|-------------|
| `FW` | Firmware Version | - | MPPT firmware version |
| `SERIAL` | Serial Number | - | Device serial number |
| `V` | Battery Voltage | mV | Battery voltage (millivolts) |
| `I` | Battery Current | mA | Battery current (milliamperes) |
| `VPV` | Panel Voltage | mV | Solar panel voltage (millivolts) |
| `PPV` | Panel Power | W | Panel power (watts) |
| `CS` | Charge State | - | Charge state: `0=Off`, `2=Fault`, `3=Bulk`, `4=Absorption`, `5=Float` |
| `MPPT` | MPPT Channel | - | MPPT state: `0=Off`, `1=Limited`, `2=Active` |
| `OR` | Off-Reason | - | Off reason (hexadecimal) |
| `ERR` | Error Code | - | Error code (see table below) |
| `LOAD` | Load Output state | - | Load output state: `ON` / `OFF` |
| `IL` | Load Output Current | mA | Load output current (milliamperes) |
| `H21` | Maximum Power Today | W | Maximum power today |

### Victron Error Codes (ERR field)

| Code | Meaning |
|------|---------|
| `0` | No error |
| `2` | Battery voltage too high |
| `17` | Charger temperature too high |
| `18` | Charger over current |
| `19` | Charger current reversed |
| `20` | Bulk time limit exceeded |
| `21` | Current sensor issue |
| `26` | Terminals overheated |
| `28` | Converter issue |
| `33` | PV input voltage too high |
| `34` | PV input over current |
| `38` | PV input shutdown (overvoltage) |
| `116` | Factory calibration data lost |
| `117` | Invalid/incompatible firmware |
| `119` | Settings data lost |

## Voltage Thresholds (LiFePO4)

The script uses two fixed thresholds defined at the top of the script:

| Threshold | Value | Action |
|-----------|-------|--------|
| `VOLTAGE_WARNING` | 12.4 V (12400 mV) | Warning displayed (yellow) |
| `VOLTAGE_CRITICAL` | 12.0 V (12000 mV) | Triggers shutdown attempt (red) |

!!! tip "Customization"
    To adapt thresholds for different battery chemistry (e.g., lead-acid), modify `VOLTAGE_WARNING` and `VOLTAGE_CRITICAL` variables in `/usr/local/bin/rb-battery.sh`.

## Relevant Files

| File | Role |
|------|------|
| `/usr/local/bin/rb-battery.sh` | Main script (managed by Ansible) |
| `/etc/cron.d/rb-battery` | Cron scheduling (managed by Ansible) |
| `/tmp/vedirect.json` | JSON output file (temporary) |
| `/dev/victron-mppt` | VE.Direct serial device (udev symlink) |

## Basic Troubleshooting

| Issue | Probable Cause | Solution |
|-------|----------------|----------|
| `No data received from VE.Direct device` | MPPT not connected / wrong device | Check `/dev/victron-mppt` and USB/VE.Direct wiring |
| Voltage shows 0 | Serial communication failure | Restart MPPT, check serial port |
| Non-zero `Error Code` | See error codes table | Consult Victron documentation for the specific code |
| Cron not executing | Cron service stopped | `systemctl status cron` / `systemctl restart cron` |

## Ansible Integration

Deployment is managed by the `recoverybox` role:
- Script template in `roles/recoverybox/files/usr/local/bin/rb-battery.sh`
- Cron template in `roles/recoverybox/files/etc/cron.d/rb-battery`
- Thresholds are hardcoded in script (no dedicated Ansible variable yet)