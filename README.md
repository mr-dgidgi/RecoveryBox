# RecoveryBox

## Description
RecoveryBox est un script d'installation qui configure un serveur de secours hors ligne pour accéder à des ressources essentielles en cas de panne d'internet. Il transforme un système Debian amd64 en point d'accès WiFi fournissant un accès local à Wikipédia, des PDFs de survie, des sites web archivés, des cartes, et des outils de radio SDR.

## Ce qui est installé
- **Kiwix** : Conteneur Docker servant Wikipédia hors ligne (en français et/ou anglais via fichiers ZIM).
- **Point d'accès WiFi** : Conteneur Docker simple-pi-hotspot créant un réseau WiFi local.
- **OpenWebRX Plus** : Interface web pour recevoir et écouter les fréquences radio via RTL-SDR.
- **Apache2** : Serveur web hébergeant des PDFs de survie (trueprepper.com) et archives de sites (nopanic.fr).
- **GPXSee** : Outil de visualisation de cartes et fichiers GPX.
- **Pilotes RTL-SDR** : Derniers pilotes compilés pour les clés USB RTL-SDR.
- **Docker** : Conteneurs pour Kiwix, point d'accès et OpenWebRX Plus.
- **Routage réseau** : IPv4 forwarding, iptables NAT et règles de routage automatiquement configurés.

## Comment lancer le script
1. Montez une partition sur `/data` (ex: `mount /dev/sda1 /data`).
2. Exécutez le script en tant que root : `sudo ./recovery_box_install.sh`.
3. Choisissez la langue (anglais, français, ou les deux).
4. Le script installera automatiquement tous les composants. Cela peut prendre du temps en raison des téléchargements.

Après installation, redémarrez le système pour activer tous les services.