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

English below

## Description
**RecoveryBox** est un script d'installation qui configure un serveur de secours hors ligne pour accéder à des ressources essentielles en cas de panne d'internet. Il transforme un système Debian amd64 en point d'accès WiFi fournissant un accès local à Wikipédia, des PDFs de survie, des sites web archivés, des cartes, et des outils de radio SDR.

Ce projet est développé pour se baser sur une chaîne d'installation Debian 13 utilisant un preseed personnalisé. Consultez [debian13-preseed-RB](https://github.com/mr-dgidgi/debian13-preseed-RB) pour plus d'informations sur la configuration de base du système.

## Ce qui est installé et utilisable

### Ressources hors ligne et accès web
- **Kiwix** : Conteneur Docker servant Wikipédia hors ligne (en français et/ou anglais via fichiers ZIM).
- **Bibliothèque de PDF** : Collection de documents de survie téléchargeable et servie via la page [library.recovery.box](http://library.recovery.box) grâce au dépôt rb-library.

### Connectivité et réseau
- **Point d'accès WiFi** : Conteneur Docker [simple-hotspot](https://hub.docker.com/repository/docker/mrdgidgi/simple-hotspot/general) créant un réseau WiFi local.
- **Routage réseau** : IPv4 forwarding, iptables NAT et règles de routage automatiquement configurés.
- **Synchro du temps via GPS** : Chrony configuré pour fournir l'heure exacte au serveur via GPS.
- **network-configurator** : Outil de configuration des interfaces réseau, bridges et WiFi.

### Radio et télécommunications
- **OpenWebRX Plus** : Interface web pour recevoir et écouter les fréquences radio via RTL-SDR.
- **Pilotes RTL-SDR** : Derniers pilotes compilés pour les clés USB RTL-SDR.
- **Support des GPS** : GPSD disponible pour les services annexes.
- **Meshtastic Web** : Client web pour visualiser les nœuds Meshtastic connectés au réseau local ou via Bluetooth/WebSerial.
- **Meshtastic daemon** : Service permettant d'exposer les informations d'un nœud Meshtastic sur la cartographie BRouter.

### Cartographie 
- **brouter** : Frontend web capable de calculer des itinéraires en se basant sur différents profils.
- **brouter + GPS** : Intégration de la position GPS RecoveryBox sur la carte si un module GPS est connecté.
- **tileserver-gl** : Serveur de rendu graphique qui permet de servir des cartes au format vectoriel ou raster en utilisant des cartes locales, ce qui permet un fonctionnement complètement offline.
- **generate_map** : Outil développé pour générer les cartes locales. Il se base sur les ressources de geofabrik.de, génère les fichiers mbtiles et les fusionne à ceux déjà présents sur la machine.

### Infrastructure
- **Apache2** : Met à disposition les différents services web
- **Docker** : Conteneurs pour Kiwix, point d'accès, OpenWebRX Plus, brouter, tileserver-gl et planetiler.
- **Iptables** : Configuration iptables personnalisable dans le fichier iptables.sh.
- **Web Console** : Terminal disponible via le navigateur web.
- **rbstatus** : Supervision des services et état du réseau directement depuis la console système.
- **service-manager** : Utilitaire pour gérer les services principaux du système.

## Ajouts futurs prévus
- **Fonctionnalités APRS** : Ajout de fonctionnalités APRS (Automatic Packet Reporting System) pour la transmission de données en temps réel

## Comment lancer le script
1. Montez une partition sur `/data` (ex: `mount /dev/sda1 /data`).
2. Exécutez le script en tant que root : `sudo ./recovery_box_install.sh`.
3. Choisissez la langue (anglais, français, ou les deux).
4. Le script installera automatiquement tous les composants. Cela peut prendre du temps en raison des téléchargements.

Pour une installation complète avec une cartographie de la France, **prévoir 4 à 5h** avec une bonne connexion internet et une machine moyenne.

Après installation, redémarrez le système pour activer tous les services.

---

## Fonctionnement des branches

- `main` : dernière version testée, peut contenir des changements mineurs qui ne sont pas encore intégré à une release officielle
- `Pre-Release` : dernières implémentations ajoutées, installation complète non recettée
- `Releases / Tag` : versions de production


---

# English


## Description
**RecoveryBox** is an installation script that configures an offline emergency server to provide access to essential resources during internet outages. It converts an **amd64 Debian** system into a WiFi Access Point offering local access to Wikipedia, survival PDFs, archived websites, maps, and SDR radio tools.

This project is developed to rely on a **Debian 13** installation chain using a custom preseed. See [debian13-preseed-RB](https://github.com/mr-dgidgi/debian13-preseed-RB) for more details on the base system configuration.

## Installed and Available

### Offline Resources & Web Access
- **Kiwix**: Docker container serving Wikipedia offline (French and/or English via ZIM files).
- **PDF Library**: Collection of survival documents available and served through [library.recovery.box](http://library.recovery.box) via the rb-library repository.

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

## Roadmap & Planned Features
* **APRS Capabilities**: Integration of Automatic Packet Reporting System (APRS) for real-time data transmission.

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

