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
RecoBox provides various tools via the web by connecting to the hotspot it hosts and accessing [http://recovery.box](http://recovery.box)

!!! info "Version"
    **Current version: {{ rb_version }}**

## Available Services
### Knowledge and Information
- **Kiwix**: Offline Wikipedia (in French and/or English via ZIM files). ([kiwix.recovery.box](http://kiwix.recovery.box))
- **Library**: Web server hosting a collection of PDF documents related to survival and self-reliance. ([library.recovery.box](http://library.recovery.box))
- **Wiki**: RecoveryBox technical wiki (services and tools documentation). ([wiki.recovery.box](http://wiki.recovery.box))
- **Flatnotes**: Simple web-based note-taking and sharing service. ([flatnotes.recovery.box](http://flatnotes.recovery.box))

### Radio and Telecommunications
- **OpenWebRX Plus**: Web interface for receiving and listening to radio frequencies via RTL-SDR. ([owrx.recovery.box](http://owrx.recovery.box))
- **Meshtastic**: Web client and daemon for Meshtastic nodes (LoRa mesh network). ([meshtastic.recovery.box](http://meshtastic.recovery.box))

### Cartography
- **BRouter**: A local cartography solution for managing GPX files ([carto.recovery.box](http://carto.recovery.box))

### Administration
- **shellinabox** Web-based administration console ([console.recovery.box](http://console.recovery.box))

## Tools
RecoveryBox integrates several tools designed to facilitate basic system administration.
- **rbstatus**: Script displaying the status of services, GPS, and hardware
- **network-configurator**: Tool for configuring network and WiFi interfaces
- **generate-map**: Tool for downloading and aggregating world maps for the cartography service
- **Meshtastic Daemon**: Service for collecting Meshtastic node information and displaying them on the BRouter map
- **rb-update**: Script for updating RecoveryBox and its services
- **services-manager**: Script for managing RecoveryBox services
- **rb-battery**: Battery monitoring and protection script via Victron MPPT VE.Direct