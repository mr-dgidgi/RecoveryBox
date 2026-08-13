---
title: rb-update
description: Automated RecoveryBox update script via GitHub.
tags:
  - tool
  - update
---

# rb-update

## Overview

`rb-update` is a utility script that automates **RecoveryBox** updates by checking the latest version available on GitHub, downloading it, and re-running the installation script.

It is deployed by Ansible to `/usr/local/bin/rb-update.sh`.

!!! warning "Root execution required"
    The script **must be run as root** (`sudo rb-update.sh`). It does not explicitly check UID but `apt`, `git`, and the `install.sh` call all require root privileges.

!!! warning "Reboot may be required"
    Depending on applied updates (kernel, systemd-networkd, Docker, etc.), a **reboot may be necessary** after the update completes.

---

## Execution Modes

| Mode | Command | Description |
|------|---------|-------------|
| **Major update (default)** | `sudo rb-update.sh` | Checks latest GitHub *release* (`latest` tag) |
| **Minor update** | `sudo rb-update.sh --minor` | Checks latest `1.x` branch tag. Gets latest patches |
| **Full system + RB update** | `sudo rb-update.sh --full` | Updates Debian packages (`apt upgrade`) **then** RecoveryBox |
| **Minor + full** | `sudo rb-update.sh --minor --full` | Combines `--minor` and `--full` |

!!! note "Note"
    Options `--minor` and `--full` are cumulative and can be combined in any order.

---

## Usage Guide

### Standard Update (Major Version)

```bash
sudo rb-update.sh
```

1. Reads current version from `/etc/recoverybox/rb_version`
2. Queries GitHub API for latest `latest` release tag
3. If a newer version is available, prompts for confirmation (`Y/N`)
4. Downloads source code (git fetch/reset/checkout or clone if missing)
5. Runs `install.sh` (interactive or `custom` mode depending on `/etc/recoverybox/custom_config.yml` presence)

### Minor Update (1.x Patch Releases)

```bash
sudo rb-update.sh --minor
```

Same as standard mode but targets the latest `1.x` tag instead of `latest`. Useful for staying on a stable branch.

### Full Update (System + RecoveryBox)

```bash
sudo rb-update.sh --full
```

Adds an `apt-get update && apt-get upgrade -y` step **before** the RecoveryBox update. Recommended to apply Debian security patches.

---

## Detailed Workflow

### 1. Version Check (`Check_Update`)

- Reads `/etc/recoverybox/rb_version` (installed version)
- GitHub API request:
  - `major` mode (default): `GET /repos/mr-dgidgi/recoverybox/releases/latest`
  - `minor` mode: `GET /repos/mr-dgidgi/recoverybox/tags` → filters latest `1.` tag
- Compares versions (string comparison)
- Displays current and available versions

### 2. Download (`Download_Update`)

- Target directory: `/root/RecoveryBox`
- If directory exists: `git fetch --all && git reset --hard && git checkout <tag>`
- Otherwise: `git clone --depth 1 --branch <tag> https://github.com/mr-dgidgi/recoverybox.git /root/RecoveryBox`

### 3. Optional System Update (`Update_System`)

- If `--full`: `apt-get update -y && apt-get upgrade -y`
- Exits on `apt` failure

### 4. Apply Update (`Update_RecoveryBox`)

- Executes `bash /root/RecoveryBox/install.sh`
- Install script detects existing `/etc/recoverybox/rb_version` and appends `-upgrading` suffix
- Re-runs Ansible playbook with existing or interactive configuration

---

## Common Troubleshooting

| Symptom | Probable Cause | Resolution |
|---------|----------------|------------|
| `Current Recovery Box version: 0.0.0` | `rb_version` file missing or empty | Reinstall or create file manually |
| `curl` returns empty / timeout | No Internet / GitHub API blocked | Check connectivity, DNS, firewall |
| `git checkout` fails | Tag doesn't exist / repo corrupted | Remove `/root/RecoveryBox` and re-run |
| `apt-get upgrade` fails (`--full`) | Package conflict / dpkg lock | `dpkg --configure -a && apt --fix-broken install` then retry |
| `install.sh` not found | Failed clone / wrong tag | Check `/root/RecoveryBox`, delete and retry |
| Script says no update available | Already at latest version | Normal behavior, nothing to do |
| Ansible playbook fails | Docker, network, config error | See **[Debug](debug.md)** or **[install.sh](RecoveryBox_install.md)** documentation |

---

## Related Files

| File | Purpose |
|------|---------|
| `/usr/local/bin/rb-update.sh` | Main script (managed by Ansible) |
| `/etc/recoverybox/rb_version` | Installed version (written by `install.sh`) |
| `/etc/recoverybox/custom_config.yml` | User config (re-applied on update) |
| `/root/RecoveryBox/` | Git clone of repository (update source) |