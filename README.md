# RecoveryBox

English below

## Description
**RecoveryBox** est un script d'installation qui configure un serveur de secours hors ligne pour accéder à des ressources essentielles en cas de panne d'internet. Il transforme un système Debian amd64 en point d'accès WiFi fournissant un accès local à Wikipédia, des PDFs de survie, des sites web archivés, des cartes, et des outils de radio SDR.

Ce projet est développé pour se baser sur une chaîne d'installation Debian 13 utilisant un preseed personnalisé. Consultez [debian13-preseed-RB](https://github.com/mr-dgidgi/debian13-preseed-RB) pour plus d'informations sur la configuration de base du système.

## Ce qui est installé et utilisable

### Ressources hors ligne et accès web
- **Kiwix** : Conteneur Docker servant Wikipédia hors ligne (en français et/ou anglais via fichiers ZIM).
- **Apache2** : Serveur web hébergeant des PDFs de survie (trueprepper.com) et archives de sites (nopanic.fr).

### Connectivité et réseau
- **Point d'accès WiFi** : Conteneur Docker [simple-hotspot](https://hub.docker.com/repository/docker/mrdgidgi/simple-hotspot/general) créant un réseau WiFi local.
- **Routage réseau** : IPv4 forwarding, iptables NAT et règles de routage automatiquement configurés.
- **Synchro du temps via GPS** : Chrony configuré pour fournir l'heure exacte au serveur via GPS
- **network-configurator** : Outil de configuration des interfaces réseau, brigdes et wifi

### Radio et télécommunications
- **OpenWebRX Plus** : Interface web pour recevoir et écouter les fréquences radio via RTL-SDR.
- **Pilotes RTL-SDR** : Derniers pilotes compilés pour les clés USB RTL-SDR.
- **Support des GPS** : GPSD disponible pour les services annexes

### Cartographie 
- **brouter** : Frontend web capable de calculer des intinéraires en se basant sur différents profiles
- **tileserver-gl** : Serveur de rendu graphique qui permet de servir des cartes au format vectoriel ou raster en utilisant des cartes locales ce qui permet un fonctionnement complètement offline.
- **generate_map** : Un outils développé pour générer les cartes locales. Il se base sur les ressource de geofabrik.de, génère les fichiers mbtiles et les fusionne à ceux déjà présent sur la machine. 

### Infrastructure
- **Docker** : Conteneurs pour Kiwix, point d'accès, OpenWebRX Plus, brouter, tileserver-gl et planetiler.
- **Iptables** : Configuration iptables personalisable dans le fichier iptables.sh
- **Web Console** : Terminal disponible via le navigateur web

## Ajouts futurs prévus
- **Fonctionnalités APRS** : Ajout de fonctionnalités APRS (Automatic Packet Reporting System) pour la transmission de données en temps réel
- **Utilitaire de gestion des services** : Interface pour gérer, démarrer, arrêter et monitorer les services

## Comment lancer le script
1. Montez une partition sur `/data` (ex: `mount /dev/sda1 /data`).
2. Exécutez le script en tant que root : `sudo ./recovery_box_install.sh`.
3. Choisissez la langue (anglais, français, ou les deux).
4. Le script installera automatiquement tous les composants. Cela peut prendre du temps en raison des téléchargements.

Pour une installation complète avec une cartographie de la France, **prévoir 4 à 5h** avec une bonne connexion internet et une machine moyenne.

Après installation, redémarrez le système pour activer tous les services.



---

# English


## Description
**RecoveryBox** is an installation script that configures an offline emergency server to provide access to essential resources during internet outages. It converts an **amd64 Debian** system into a WiFi Access Point offering local access to Wikipedia, survival PDFs, archived websites, maps, and SDR radio tools.

This project is developed to rely on a **Debian 13** installation chain using a custom preseed. See [debian13-preseed-RB](https://github.com/mr-dgidgi/debian13-preseed-RB) for more details on the base system configuration.

## Installed and Available

### Offline Resources & Web Access
* **Kiwix**: A Docker container serving Wikipedia offline (French and/or English via ZIM files).
* **Apache2**: A web server hosting survival PDFs (from trueprepper.com) and archived websites (from nopanic.fr).

### Connectivity & Networking
- **WiFi Access Point**: Docker container [simple-hotspot](https://hub.docker.com/repository/docker/mrdgidgi/simple-hotspot/general) creating a local WiFi network.
- **Network Routing**: Automatic configuration of IPv4 forwarding, iptables NAT and routing rules.
- **GPS Time Synchronization**: Chrony configured to provide precise time to the server via GPS.
- **network-configurator**: Tool to configure network interfaces, bridges and WiFi settings.

### Radio & Telecommunications
- **OpenWebRX Plus**: Web interface to receive and listen to radio frequencies via RTL-SDR.
- **RTL-SDR Drivers**: Latest compiled drivers for RTL-SDR USB dongles.
- **GPS Support**: GPSD available for auxiliary services.

### Mapping
- **BRouter**: Web frontend capable of computing routes using different profiles.
- **tileserver-gl**: Renderer serving vector or raster maps from local data for fully offline operation.
- **generate_map**: Utility to generate local maps. It relies on Geofabrik resources, creates MBTiles and merges them with maps already present on the machine.

### Infrastructure
* **Docker**: Containerized environment for Kiwix, the Access Point, OpenWebRX Plus, BRouter, tileserver-gl, and planetiler.
* **iptables**: Customizable firewall and NAT rules managed through the `iptables.sh` script.

## Roadmap & Planned Features
* **Web Mapping Software**: Web-based map manager with full GPX file support.
* **APRS Capabilities**: Integration of Automatic Packet Reporting System (APRS) for real-time data transmission.
* **Service Management Utility**: A dedicated interface to manage, start, stop, and monitor all services.
* **Network Reconfiguration Tool**: An easy-to-use utility for reconfiguring network interfaces and WiFi AP settings.

## Installation
1. Mount a partition to `/data` (e.g., `mount /dev/sda1 /data`).
2. Run the script as root: `sudo ./recovery_box_install.sh`.
3. Select your preferred language (English, French, or both).
4. The script will automatically install all components. **Note:** This process may take a significant amount of time depending on download sizes.

For a complete installation with French map data, expect approximately **4 to 5 hours** with a good internet connection and an average machine.

Once the installation is complete, **reboot the system** to activate all services.