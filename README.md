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

### Radio et télécommunications
- **OpenWebRX Plus** : Interface web pour recevoir et écouter les fréquences radio via RTL-SDR.
- **Pilotes RTL-SDR** : Derniers pilotes compilés pour les clés USB RTL-SDR.
- **Support des GPS** : GPSD disponible pour les services annexes

### Cartographie et outils
- **WIP**

### Infrastructure
- **Docker** : Conteneurs pour Kiwix, point d'accès et OpenWebRX Plus.

## Ajouts futurs prévus
- **Logiciel de cartographie web** : Gestionnaire de cartographie web avec support complet de la gestion des fichiers GPX
- **Fonctionnalités APRS** : Ajout de fonctionnalités APRS (Automatic Packet Reporting System) pour la transmission de données en temps réel
- **Utilitaire de gestion des services** : Interface pour gérer, démarrer, arrêter et monitorer les services
- **Utilitaire de reconfiguration réseau** : Outil de reconfiguration des interfaces réseau et du point d'accès WiFi

## Comment lancer le script
1. Montez une partition sur `/data` (ex: `mount /dev/sda1 /data`).
2. Exécutez le script en tant que root : `sudo ./recovery_box_install.sh`.
3. Choisissez la langue (anglais, français, ou les deux).
4. Le script installera automatiquement tous les composants. Cela peut prendre du temps en raison des téléchargements.

Après installation, redémarrez le système pour activer tous les services.



---

# English


## Description
**RecoveryBox** is an installation script designed to set up an offline emergency server providing access to essential resources during internet outages. It transforms an **amd64 Debian** system into a WiFi Access Point, offering local access to Wikipedia, survival PDFs, archived websites, maps, and SDR radio tools.

This project is built upon a **Debian 13** installation chain using a custom preseed. For more information on the base system configuration, visit [debian13-preseed-RB](https://github.com/mr-dgidgi/debian13-preseed-RB).

## Features & Installed Services

### Offline Resources & Web Access
* **Kiwix**: A Docker container serving Wikipedia offline (French and/or English via ZIM files).
* **Apache2**: A web server hosting survival PDFs (from trueprepper.com) and archived websites (from nopanic.fr).

### Connectivity & Networking
* **WiFi Access Point**: Powered by the [simple-hotspot](https://hub.docker.com/repository/docker/mrdgidgi/simple-hotspot/general) Docker container to create a local wireless network.
* **Network Routing**: Automatic configuration of IPv4 forwarding, iptables NAT, and routing rules.
* **GPS Time Synchronization**: Chrony is configured to provide precise system time via GPS, ensuring accuracy even without internet.

### Radio & Telecommunications
* **OpenWebRX Plus**: A web interface for receiving and monitoring radio frequencies via RTL-SDR.
* **RTL-SDR Drivers**: The latest compiled drivers for RTL-SDR USB dongles.
* **GPS Support**: GPSD is available for auxiliary location and timing services.

### Mapping & Tools
* **WIP** (Work In Progress)

### Infrastructure
* **Docker**: Containerized environment for Kiwix, the Access Point, and OpenWebRX Plus.

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

Once the installation is complete, **reboot the system** to activate all services.