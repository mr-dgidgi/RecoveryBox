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
### Connaissances et informations
- **Kiwix** : Wikipédia hors ligne (en français et/ou anglais via fichiers ZIM). ([kiwix.recovery.box](http://kiwix.recovery.box))
- **Librairie** : Serveur web hébergeant une collection de documents PDF liés à la survie et à l'autonomie. ([library.recovery.box](http://library.recovery.box))
- **Wiki** : Wiki technique de la RecoveryBox (documentation des services et outils). ([wiki.recovery.box](http://wiki.recovery.box))
- **Flatnotes** : Service de prise de notes et de partage simple. ([flatnotes.recovery.box](http://flatnotes.recovery.box))

### Radio et télécommunications
- **OpenWebRX Plus** : Interface web pour recevoir et écouter les fréquences radio via RTL-SDR. ([owrx.recovery.box](http://owrx.recovery.box))
- **Meshtastic** : Client web et daemon pour les nœuds Meshtastic (réseau maillé LoRa). ([meshtastic.recovery.box](http://meshtastic.recovery.box))

### Cartographie 
- **brouter** : Une solution de cartographie fonctionnant en local et permettant de gérer des fichiers gpx ([(carto.recovery.box)](http://carto.recovery.box))

### Administration
- **shellinabox** Console d'administration disponible via le web ([console.recovery.box](http://console.recovery.box))

## Outils
La RecoveryBox intègre plusieurs outils développés dans le but de faciliter l'administration basique du système.
- **rbstatus** : Script affichant l'état des services, du GPS et du hardware
- **network-configurator** : Outils permettant de configurer les interfaces réseau et wifi
- **generate-map** : Outil permettant de télécharger et agréger des cartes du monde pour le service de cartographie
- **Meshtastic Démon** : Service permettant de récupérer les informations d'un nœud Meshtastic et de les afficher sur la carte BRouter
- **rb-update** : Script permettant de mettre à jour la RecoveryBox et ses services
- **services-manager** : Script permettant de gérer les services de la RecoveryBox
- **rb-battery** : Script de surveillance et protection batterie via MPPT Victron VE.Direct
- **rb-laptop** : Script permettant d'afficher le niveau de batterie sur la page d'accueil si le matériel est un ordinateur portable
