# Présentation
## Pourquoi RecoveryBox ?

RecoveryBox regroupe dans une seule plateforme plusieurs ressources essentielles pouvant fonctionner sans accès Internet :

* connaissances générales (Wikipédia)
* documentation technique
* cartographie
* réception radio
* ressources locales

Elle peut être utilisée :

* lors d'une panne Internet prolongée
* dans un environnement isolé
* lors d'opérations de terrain
* pour la préparation aux situations d'urgence
* comme serveur documentaire local

L'objectif est de disposer rapidement d'une base de connaissances autonome accessible depuis n'importe quel navigateur web.
La RecoveryBox propose donc divers outils via le web en se connectant sur le hotspot qu'elle héberge et en accédant à [http://recovery.box](http://recovery.box)

!!! info "Version"
    **Version actuelle : {{ rb_version }}**

## Services disponibles
### Ressources hors ligne et accès web
- **Kiwix** : Wikipédia hors ligne (en français et/ou anglais via fichiers ZIM). ([kiwix.recovery.box](http://kiwix.recovery.box))
- **Librairie** : Serveur web hébergeant une collection de documents PDF liés à la survie et à l'autonomie. ([library.recovery.box](http://library.recovery.box))
- **Wiki** : Wiki technique de la RecoveryBox (documentation des services et outils). ([wiki.recovery.box](http://wiki.recovery.box))

### Connectivité et réseau
- **Synchro du temps via GPS** : le serveur fourni l'heure exacte aux équipements connecté à celui-ci grâce à son GPS

### Radio et télécommunications
- **OpenWebRX Plus** : Interface web pour recevoir et écouter les fréquences radio via RTL-SDR. ([owrx.recovery.box](http://owrx.recovery.box))
- **Meshtastic** : Client web et daemon pour les nœuds Meshtastic (réseau maillé LoRa). ([meshtastic.recovery.box](http://meshtastic.recovery.box))

### Cartographie 
- **brouter** : Une solution de cartographie fonctionnant en local et permettant de gérer des fichiers gpx ([(carto.recovery.box)](http://carto.recovery.box))

### Administration
- **shellinabox** Console d'administration disponible via le web ([console.recovery.box](http://console.recovery.box))

## Outils
La RecoveryBox intègre plusieurs outils développé dans le but de faciliter l'administration basique du système.
- **rbstatus** : Script affichant l'état des services, du GPS et du hardware
- **network-configurator** : Outils permettant de configurer les interfaces réseau et wifi
- **generate-map** : Outils permettant de télécharger et aggréger des cartes du monde pour le service de cartographie
- **Meshtastic Daemon** : Service permettant de récupérer les informations d'un nœud Meshtastic et de les afficher sur la carte BRouter

## Sommaire
* [Démarrage Rapide](quickstart.md)
* Services
    * [Hotspot](./services/hotspot.md)
    * [Librairie](./services/library.md)
    * [Kiwix](./services/kiwix.md)
    * [OpenWebRX Plus](./services/owrx.md)
    * [Meshtastic](./services/meshtastic.md)
    * [Carto](./services/carto.md)
    * [Console](./services/console.md)
    * [Flatnotes](./services/flatnotes.md)
* Administration
    * [Installation](./admin/install.md)
    * [Configuration Réseau](./admin/network.md)
    * [rbstatus](./admin/rbstatus.md)
    * [network-configurator](./admin/network-configurator.md)
    * [generate-map](./admin/generate-map.md)
    * [Daemon Meshtastic](./admin/meshtastic-daemon.md)
    * [Debug](./admin/debug.md)