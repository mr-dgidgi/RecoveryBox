# RecoveryBox

![Étoiles](https://img.shields.io/github/stars/mr-dgidgi/RecoveryBox)

![Licence](https://img.shields.io/github/license/mr-dgidgi/RecoveryBox)

![GitHub repo size](https://img.shields.io/github/repo-size/mr-dgidgi/RecoveryBox)

![GitHub language count](https://img.shields.io/github/languages/count/mr-dgidgi/RecoveryBox)

![GitHub Tag](https://img.shields.io/github/v/tag/mr-dgidgi/RecoveryBox)

![Dernier commit](https://img.shields.io/github/last-commit/mr-dgidgi/RecoveryBox)

| Pre-Release | main |
|-------------|------|
|![GitHub branch check runs](https://img.shields.io/github/check-runs/mr-dgidgi/RecoveryBox/Pre-Release)|![GitHub branch check runs](https://img.shields.io/github/check-runs/mr-dgidgi/RecoveryBox/main)|


## Description
The 4 pillars of the RecoveryBox project are:
- Resilience
- Knowledge
- Communication
- Localisation


**RecoveryBox** is an installation script that configures an offline emergency server to provide access to essential resources during internet outages. It converts an **amd64 Debian** system into a WiFi Access Point offering local access to Wikipedia, survival PDFs, archived websites, maps, and SDR radio tools.

This project is developed to rely on a **Debian 13** installation chain using a custom preseed. See [debian13-preseed-RB](https://github.com/mr-dgidgi/debian13-preseed-RB) for more details on the base system configuration.

Documentation on the website : [recoverybox.fr](https://recoverybox.fr)

## Installed and Available

### Knowledge & Information
- **Kiwix**: Docker container serving Wikipedia offline (French and/or English via ZIM files).
- **PDF Library**: Collection of survival documents available and served through [library.recovery.box](http://library.recovery.box) via the rb-library repository.
- **Wiki**: RecoveryBox technical wiki (services and tools documentation).
- **Flatnotes**: Simple note-taking and sharing service available at [http://flatnotes.recovery.box](http://flatnotes.recovery.box).

### Connectivity & Networking
- **WiFi Access Point**: Docker container [simple-hotspot](https://hub.docker.com/repository/docker/mrdgidgi/simple-hotspot/general) creating a local WiFi network.
- **Network Routing**: Automatic configuration of IPv4 forwarding, iptables NAT and routing rules.
- **GPS Time Synchronization**: Chrony configured to provide the exact time to the server via GPS.
- **network-configurator**: Tool to configure network interfaces, bridges and WiFi settings.

### Radio & Telecommunications
- **OpenWebRX Plus**: Web interface to receive and listen to radio frequencies via RTL-SDR.
- **RTL-SDR Drivers**: Latest compiled drivers for RTL-SDR USB dongles.
- **GPS Support**: GPSD available for auxiliary services.
- **Meshtastic Web**: Web client for viewing Meshtastic nodes connected to the local network or via Bluetooth/WebSerial.
- **Meshtastic daemon**: Service exposing the information of a Meshtastic node on the BRouter map.

### Mapping
- **BRouter**: Web frontend capable of calculating routes based on different profiles.
- **BRouter + GPS**: Integration of the RecoveryBox GPS position on the map if a GPS module is connected.
- **tileserver-gl**: Rendering server that serves vector or raster maps from local data, enabling fully offline operation.
- **generate_map**: Tool developed to generate local maps. It uses resources from geofabrik.de, creates MBTiles files and merges them with those already present on the machine.

### Infrastructure
- **Apache2**: Makes the various web services available.
- **Docker**: Containers for Kiwix, the access point, OpenWebRX Plus, BRouter, tileserver-gl and planetiler.
- **iptables**: Customizable iptables configuration in the iptables.sh file.
- **Web Console**: Terminal available via the web browser.
- **rbstatus**: Service and network status monitoring directly from the system console.
- **service-manager**: Utility to manage the main services of the system.
- **rb-update**: Script to update the RecoveryBox system and its components.
- **Victron battery monitoring**: Script to monitor the battery voltage and initiate a system shutdown if the voltage drops below a critical threshold.
- **rb-laptop**: Script to display the battery level on the home page if the hardware is a laptop.



## Installation
1. Mount a partition to `/data` (e.g., `mount /dev/sda1 /data`).
2. Run the script as root: `sudo ./recovery_box_install.sh`.
3. Select your preferred language (English, French, or both).
4. The script will automatically install all components. **Note:** This process may take a significant amount of time depending on download sizes.

For a complete installation with French map data, expect approximately **4 to 5 hours** with a good internet connection and an average machine.

Once the installation is complete, **reboot the system** to activate all services.

---

## Branch Operations

- `main`: latest tested version, may contain minor changes not yet included in an official release
- `Pre-Release`: latest implementations added, full installation not yet validated
- `Releases / Tag`: production versions

