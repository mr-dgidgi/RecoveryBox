# Presentation
## Why RecoveryBox?

RecoveryBox consolidates several essential resources into a single platform capable of operating entirely without Internet access:

* General knowledge (Wikipedia)
* Technical documentation
* Mapping and cartography
* Radio reception
* Local resources

It can be used:

* During prolonged Internet outages
* In isolated or off-grid environments
* During field operations
* For emergency and disaster preparedness
* As a local documentation server

The goal is to quickly deploy a self-contained, standalone knowledge base accessible from any standard web browser.
RecoveryBox provides various tools via the web by connecting to the hotspot it hosts and accessing [http://recovery.box](http://recovery.box)

## Available Services
### Offline resources and web access
- **Kiwix**: Offline Wikipedia (in French and/or English via ZIM files). ([kiwix.recovery.box](http://kiwix.recovery.box))
- **Library**: Web server hosting a collection of survival and self-reliance PDF documents. ([library.recovery.box](http://library.recovery.box))
- **MkDocs**: RecoveryBox technical wiki (services and tools documentation). ([wiki.recovery.box](http://wiki.recovery.box))

### Connectivity and networking
- **GPS Time Sync**: The server provides the exact time to connected devices via its GPS

### Radio and telecommunications
- **OpenWebRX Plus**: Web interface for receiving and listening to radio frequencies via RTL-SDR. ([owrx.recovery.box](http://owrx.recovery.box))
- **Meshtastic**: Web client and daemon for Meshtastic nodes (LoRa mesh network). ([meshtastic.recovery.box](http://meshtastic.recovery.box))

### Cartography
- **brouter**: A local cartography solution for managing GPX files. ([carto.recovery.box](http://carto.recovery.box))

### Administration
- **shellinabox**: Web-based administration console. ([console.recovery.box](http://console.recovery.box))

## Tools
RecoveryBox integrates several tools designed to facilitate basic system administration.
- **rbstatus**: Script displaying the status of services, GPS, and hardware
- **network-configurator**: Tool for configuring network and WiFi interfaces
- **generate-map**: Tool for downloading and aggregating world maps for the cartography service
- **Meshtastic Daemon**: Service for collecting Meshtastic node information and displaying them on the BRouter map

## Table of Contents
* [Quick Start](quickstart.md)
* Services
    * [Hotspot](./services/hotspot.md)
    * [Library](./services/library.md)
    * [Kiwix](./services/kiwix.md)
    * [OpenWebRX Plus](./services/owrx.md)
    * [Meshtastic](./services/meshtastic.md)
    * [Carto](./services/carto.md)
    * [Console](./services/console.md)
    * [MkDocs](./services/mkdocs.md)
* Administration
    * [Installation](./admin/install.md)
    * [Network Configuration](./admin/network.md)
    * [rbstatus](./admin/rbstatus.md)
    * [network-configurator](./admin/network-configurator.md)
    * [generate-map](./admin/generate-map.md)
    * [Meshtastic Daemon](./admin/meshtastic-daemon.md)
    * [Debug](./admin/debug.md)
