# RecoveryBox

## Description
RecoveryBox est un script d'installation qui configure un serveur de secours hors ligne pour accéder à des ressources essentielles en cas de panne d'internet. Il transforme un système Debian amd64 en point d'accès WiFi fournissant un accès local à Wikipédia, des PDFs de survie, des sites web archivés, des cartes, et des outils de radio SDR.

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