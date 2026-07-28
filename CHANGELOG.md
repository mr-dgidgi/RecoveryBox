# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.4.2] - 2026-07-28

### Added

### Fixed

### Changed
- `rb-library` updated to version 1.1.0 with UI matching the RecoveryBox theme.

## [1.4.1] - 2026-07-27

### Added
- `rb-update.sh` script added to check for updates and manage the update process for RecoveryBox.
- `create-tag.yml` workflow added to automate version tagging on the `main` branch.

### Fixed
- Bug in dnsmasq configuration where the `conf-dir` directive was incorrectly pointing to `/etc/ap_config/dnsmasq.d` instead of `/etc/conf/dnsmasq.d/` causing incapability to start the service.


### Changed

## [1.4.0] - 2026-07-26

### Added
- CI workflow `shellcheck`, `ansible-lint` and `ansible-deply-test` created and managed by `push-test.yml` and `release-test.yml`
- CI workflow `deploy-wiki` created to upload the wiki to [https://recoverybox.fr](https://recoverybox.fr)
- Ansible-playbook is now used for the installation
- Wiki service added to the RecoveryBox at `http://recovery.box/wiki`
- `Wiki_generator.sh` script added to generate the wiki from the `wiki-sources` folder

### Fixed


### Changed
- `recovery_box_install.sh` renamed `RecoveryBox_install.sh` for name consistency
 - Total rework on the installer behaviour. Most of the actions are now handled by Ansible and the file is easier to maintain
  - `RecoveryBox_install.sh` can generate a custom_config.yml file
  - `RecoveryBox_install.sh` can read a custom_config.yml file manually generated
  - You can choose which service you want to activate or deactivate during the installation
  - You can rerun `RecoveryBox_install.sh` to activate or deactivate services
  - You can rerun `RecoveryBox_install.sh` to update the services
  - The network configuration is now at the end of the installation script and is run only if the system isn't running on systemd-networkd only.
- `services-manager` reworked to list dynamicaly the services activated
- More variables added in `recoverybox_hotspot_conf` to customize the hotspot
- `services.json` contain the version of each service
- `ap_start.sh` modified to aggregate `hostapd_base.conf` and `hostapd_extra.conf`
- `dnsmasq.conf` modified to include configuration files in the `dnsmasq.d/` folder
- `hostapd.conf` renamed to `hostapd_base.conf`

## [1.3.0] - 2026-07-12

### Added
- `service-manager` added
- `brouter` : The RecoveryBox GPS position in now displayer if a GPS module is connected
- `mestastic-web` : Meshtastic web client no use nodes connected to the recoverybox hotspot or on the client device in bluetooth or webserial
- `meshtastic-daemon` : service connecting to a meshtastic node on the hotspot and showing the node that it detect on brouter map 
- `library-update.py`: tool to register new PDF for the [library](http://library.recovery.box)

### Fixed
- `network-configurator` - Command `MenuSetVlan` renamed `MenuSetWlan`
- `rbstatus`: The commande don't block if there is no gps
- `rbstatus`: the script don't crash anymore if a temp sensor file is not available
- Wan routing : the traffic switch automatically to wifi WAN if the ethernet port is disconected
- `network-configurator` : bug with the renaming of all interface "wlanAP" during installation is fixed
- DNS issue during installation due to the activation of systemd-resolve is fixed

### Changes
- `rbstatus`: 3s Timeout added on DNS check for a quicker execution
- `rbstatus`: **disabled** services are no more displayed as **critical**
- `frpdf` and `enpdf` replaced by rb-library
- `network-configurator` : server restart no more needed after interface name change


## [1.2.0] - 2026-06-09
### Added
- `network-configurator`: tool to configure network interfaces, bridges and WiFi settings.
- `Web Console`: shellinabox added 
- Add cron to display `rbstatus` on TTY1
- firmware `firmware-iwlwifi` for AX210 wifi card

### Fixed
- Fixes to `rbstatus` monitoring script :
  - Service status methode
  - GPS status
- Add cleanup to Tileserver in `generate_map.sh`

### Changed
- Rework of the network behavior: 
  - Adding bridge interfaces for LAN and WAN
  - link wlanAP to LAN bridge
  - Link network interface to WAN
  - Route priority on WAN bridge
  - WAN Access through wlan available
- Rework iptables :
  - Auto generate rules for WAN interface (icmp + ssh)
- Homepage http://recovery.box updated


## [1.1.0] - 2026-05-03
### Added
- Monitoring script `rbstatus.sh` for service health checks and status reporting.
- jq added to default tools
- `tileserver-gl` service added for offline map serving.
- Custom `tileserver-gl` config, style and sprite assets for offline map rendering.
- `brouter` service added for routing.
- Apache proxy/site configuration added for `brouter` and `tileserver-gl` access.
- `generate_map.sh` created to manage map importation.
- OWRX updated to use `tileserver-gl` tiles with custom Leaflet settings.

### Changed
- Updated project structure asset structure, and OWRX configuration.
- `recovery_box_install.sh` reviewed, for the new features and is more interactive
- `index.html` updated to include map.recovery.box

## [1.0.0] - 2026-04-25
### Added
- Complete rewrite and migration from Raspberry Pi architecture to x86_64.
- Updated installation and configuration scripts for Debian 13/x86_64 environments.
- Consolidated services and assets for RecoveryBox with new architecture support.

### Changed
- Reworked project structure to support x86_64 hardware.
- Improved setup documentation and configuration defaults.

### Removed
- Raspberry Pi specific setup and configuration files.
