---
title: Debug
description: Guide de dépannage rapide pour les services et composants de la RecoveryBox.
tags:
  - outil
  - debug
---

# Debug

Ce guide propose des conseils de dépannage pour résoudre les problèmes les plus courants rencontrés sur les services de la RecoveryBox. L'objectif est de permettre un **debug basic** sans nécessiter de compétences avancées.

!!! info "Outil de supervision global"
    Avant de diagnostiquer un service individuel, exécutez la commande `rbstatus` pour obtenir un aperçu de l'état de l'ensemble des services, du GPS et du système. Consultez la fiche dédiée : [**rbstatus**](./rbstatus.md).

---

## Hotspot

Le hotspot Wi-Fi est le point d'entrée principal de la RecoveryBox. Si les utilisateurs ne peuvent pas se connecter au réseau `recoverybox`, aucun service web ne sera accessible.

### Vérification du service

```bash
# État du service point d'accès
systemctl status ap.service

# Logs du hotspot en temps réel
journalctl -u ap.service -f

# Vérifier que le conteneur tourne
docker ps | grep hotspot
```

### Vérification de l'interface Wi-Fi

```bash
# Vérifier que l'interface wlanAP existe
ip link show wlanAP
```

### Vérification du DHCP / DNS

```bash

# Consulter les baux DHCP distribués
docker exec -ti hotspot cat /var/lib/misc/dnsmasq.leases
```

### Résolution de problèmes courants

| Problème | Cause possible | Solution |
| --- | --- | --- |
| Le réseau `recoverybox` n'apparaît pas | Interface Wi-Fi non renommée en `wlanAP` | Vérifier avec `ip link` et relancer `network-configurator` |
| Connexion au réseau mais pas d'accès à http://recovery.box | Service Apache2 indisponible | Vérifier avec `systemctl status apache2.service` |
| Connexion au réseau mais pas d'accès à internet | câble Ethernet non branché, interface WAN (ou wlan) non configurée | Vérifier l'état des interfaces et des routes avec `ip link` et `ip route` |
| Pas d'adresse IP attribuée | Plus d'IP disponibles dans le pool DHCP | Consulter les baux DHCP `docker exec -ti hotspot cat /var/lib/misc/dnsmasq.leases` et vérifier la plage disponible `cat /etc/ap_config/dnsmasq.conf` |

!!! info "Documentation officielle"
    Le hotspot est basé sur le projet **[Simple-Hotspot](https://github.com/mr-dgidgi/Simple-Hotspot)**. Consultez la fiche service pour plus de détails : [**Hotspot**](../services/hotspot.md).

---

## Cartographie

Le service cartographie repose sur **Brouter** (moteur de routage) et **TileServer-GL** (serveur de tuiles).

### Vérification des services

```bash
# État du service BRouter
systemctl status brouter.service

# Logs Brouter
journalctl -u brouter.service

# État du service TileServer-GL
systemctl status tileserver-gl.service

# Logs TileServer-GL
journalctl -u tileserver-gl.service
```

### Vérification de la carte

```bash
# Vérifier que le fichier map.mbtiles existe
ls -lh /data/tileserver/map.mbtiles

# Vérifier que brouter répond
curl -I http://localhost:17777/

#   Vérifier que tileserver-gl répond
curl -I http://localhost:8090/
```

### Vérification Apache

```bash
# Vérifier qu'Apache2 est actif
systemctl status apache2.service

# Logs d'accès carto
cat /var/log/apache2/carto_access.log

# Logs d'erreur carto
cat /var/log/apache2/carto_error.log
```

### Résolution de problèmes courants

| Problème | Cause possible | Solution |
| --- | --- | --- |
| La carte s'affiche en blanc | Fichier `map.mbtiles` manquant ou corrompu | Générer une carte avec `generate-map` |
| Erreur "tile not found" | Tuiles non générées pour la zone demandée | Vérifier le niveau de zoom et la zone couverte |
| BRouter ne répond pas | Service non démarré | `systemctl start brouter.service` |

!!! info "Documentation officielle"
    - **[BRouter](https://github.com/abrensch/brouter)** — Moteur de calcul d'itinéraire
    - **[TileServer-GL](https://tileserver.readthedocs.io/en/latest/)** — Serveur de tuiles cartographiques
    - Fiche service : [**Cartographie**](../services/carto.md)
    - Outil de génération : [**generate-map**](./generate-map.md)

---

## Localisation GPS

La localisation de la RecoveryBox est affichée sur la carte BRouter. Son positionnement dépend du service GPS (gpsd).

### Vérification du GPS

```bash
# État du service GPS
systemctl status gpsd.service

# Vérifier les données GPS en temps réel
gpspipe -w -n 10
```

### Vérifier que la cron dédiée fonctionne

```bash
# Vérifier que le service cron ne rencontre pas d'erreur
journalctl -u cron.service

# Vérifier que le script de le fichier json est bien généré
ls -la /data/brouter/www/recoverybox.json

# Tester le script de génération du fichier JSON
bash -x /data/brouter/gps-to-json.sh
```
### Résolution de problèmes courants

| Problème | Cause possible | Solution |
| --- | --- | --- |
| Position GPS non affichée sur la carte | Aucun fix GPS | Vérifier que le GPS reçoit des données avec `gpspipe` |
| Pas de satellites détectés | Antenne GPS mal connectée ou obstruct | Placer l'antenne GPS à l'extérieur ou près d'une fenêtre |

!!! info "Documentation"
    Consultez la fiche : [**Outils système**](./system-tools.md) pour plus de détails sur gpsd et chrony.

---

## POI Meshtastic

Les points d'intérêt Meshtastic représentent les nœuds du réseau maillé LoRa sur la carte.

### Vérification du daemon Meshtastic

```bash
# Vérifier que le service cron ne rencontre pas d'erreur
journalctl -u cron.service

# Vérifier que le fichier json est bien généré
ls -la /data/brouter/www/meshtastic_nodes.json

# Tester le script de génération du fichier JSON
python3 /data/brouter/meshtastic-daemon.py
```

### Vérification du nœud Meshtastic

```bash
# Vérifier que l'IP dans le fichier de cron est bien celui du noeud Meshtastic
cat /etc/cron.d/meshtastic-daemon
cat /etc/ap_config/dnsmasq.conf | grep dhcp-host

# Vérifier que le noeud est bien visible par la RecoveryBox
ping -c 3 <IP_du_noeud_Meshtastic>
```


### Résolution de problèmes courants

| Problème | Cause possible | Solution |
| --- | --- | --- |
| Aucun nœud affiché sur la carte | Daemon non démarré ou nœud non connecté | Vérifier l'état du daemon et la connectivité du nœud |
| Le nœud Meshtastic n'est pas détecté | Réservation DHCP manquante | Vérifier la configuration MAC/IP dans `custom_config.yml` |

!!! info "Documentation officielle"
    - **[Meshtastic](https://meshtastic.org)** — Documentation officielle du projet

---

## Kiwix

Kiwix fournit l'accès hors-ligne à Wikipédia et autres ressources ZIM.

### Vérification du service

```bash
# État du service Kiwix
systemctl status kiwix.service

# Logs en temps réel
journalctl -u kiwix.service -f
```

### Vérification du conteneur

```bash
# Vérifier que le conteneur tourne
docker ps | grep kiwix

# Tester l'accès HTTP
curl -I http://localhost:8080/
```

### Vérification des fichiers ZIM

```bash
# Lister les fichiers ZIM disponibles
ls -lh /data/kiwix/
```
### Vérification Apache

```bash
# Vérifier qu'Apache2 est actif
systemctl status apache2.service

# Logs d'accès carto
cat /var/log/apache2/carto_access.log

# Logs d'erreur carto
cat /var/log/apache2/carto_error.log
```

### Résolution de problèmes courants

| Problème | Cause possible | Solution |
| --- | --- | --- |
| Page blanche ou erreur 502 | Conteneur Docker arrêté | `systemctl restart kiwix.service` |
| Aucun contenu disponible | Fichiers ZIM absents du répertoire `/data/kiwix/` | Télécharger les fichiers depuis [browse.library.kiwix.org](https://browse.library.kiwix.org/) |
| Nouveau fichier ZIM non détecté | Kiwix ne recharge pas automatiquement | Redémarrer le service après ajout d'un fichier |

!!! info "Documentation officielle"
    - **[Kiwix](https://wiki.kiwix.org)** — Documentation officielle
    - **[Kiwix-serve](https://github.com/kiwix/kiwix-serve)** — Dépôt GitHub
    - **[Bibliothèque de fichiers ZIM](https://browse.library.kiwix.org/)** — Téléchargement de contenus
    - Fiche service : [**Kiwix**](../services/kiwix.md)

---

## Console

La console web d'administration utilise ShellInABox pour fournir un accès shell via le navigateur.

### Vérification du service

```bash
# État du service ShellInABox
systemctl status shellinabox.service

# Tester l'accès HTTP
curl -I -H "Host: console.recovery.box" http://127.0.0.1:4200/
```

### Vérification des logs Apache

```bash
# Logs d'accès
cat /var/log/apache2/console_access.log

# Logs d'erreur
cat /var/log/apache2/console_error.log
```

### Résolution de problèmes courants

| Problème | Cause possible | Solution |
| --- | --- | --- |
| La console ne se charge pas | Service shellinabox arrêté | `systemctl start shellinabox.service` |
| Erreur "Connection refused" | VirtualHost Apache2 mal configuré | Vérifier `/etc/apache2/sites-available/console.conf` |
| Identifiants refusés | Mot de passe par défaut modifié | Réinitialiser avec `passwd recuser` |

!!! info "Documentation officielle"
    - **[ShellInABox](https://github.com/shellinabox/shellinabox)** — Dépôt GitHub
    - Fiche service : [**Console**](../services/console.md)

---

## Librairie

La librairie est un serveur web statique hébergeant des documents PDF de survie.

### Vérification du service Apache

```bash
# Vérifier que le VirtualHost est activé
apache2ctl -S | grep library

# Tester l'accès HTTP
curl -I -H "Host: library.recovery.box" http://127.0.0.1/
```

### Vérification des logs

```bash
# Logs d'accès
cat /var/log/apache2/library.access.log

# Logs d'erreur
cat /var/log/apache2/library.error.log
```

### Vérification du contenu

```bash
# Vérifier la présence des PDF
ls -la /data/library/PDF/
cat /data/library/library.json | jq '.pdfs[]'

# Vérifier les PDF personnalisés
ls -la /data/library/PDF/custom/
cat /data/library/custom-library.json | jq '.pdfs[]'
```

### Résolution de problèmes courants

| Problème | Cause possible | Solution |
| --- | --- | --- |
| Erreur 404 sur library.recovery.box | VirtualHost non activé | `a2ensite library.conf && systemctl reload apache2` |
| Nouveau PDF non visible | Script de mise à jour non exécuté | Lancer `python3 /data/library/library-update.py` puis redémarrer Apache |
| Page vide | Répertoire DocumentRoot incorrect | Vérifier le chemin dans `/etc/apache2/sites-available/library.conf` |

!!! info "Documentation"
    - Dépôt de la bibliothèque : [**mr-dgidgi/rb-library**](https://github.com/mr-dgidgi/rb-library)
    - Fiche service : [**Librairie**](../services/library.md)

---

## OpenWebRX

OpenWebRX Plus est le récepteur radio SDR accessible via le navigateur.

### Vérification du service

```bash
# État du service OpenWebRX
systemctl status openwebrx.service

# Logs en temps réel
journalctl -u openwebrx.service -f
```

### Vérification du matériel SDR

```bash
# Vérifier que la clé RTL-SDR est détectée
lsusb | grep RTL
# ou
dmesg | grep rtl
```

### Vérification de l'accès

```bash
# Tester l'accès HTTP (port 8073)
curl -I http://localhost:8073/
```

### Résolution de problèmes courants

| Problème | Cause possible | Solution |
| --- | --- | --- |
| Interface inaccessible | Service openwebrx arrêté | `systemctl start openwebrx.service` |
| Erreur "no SDR device" | Clé RTL-SDR non branchée ou pilote manquant | Vérifier `lsusb` et installer les pilotes RTL-SDR |
| Audio pas de son | Navigateur bloque l'autoplay audio | Autoriser l'autoplay audio pour `recovery.box:8073` |

!!! info "Documentation officielle"
    - **[OpenWebRX](https://www.openwebrx.de)** — Documentation du projet d'origine
    - **[OpenWebRX Plus](https://github.com/luarvique/openwebrx-plus)** — Fork amélioré utilisé par la RecoveryBox
    - Fiche service : [**OpenWebRX Plus**](../services/owrx.md)

---

## Réseau

La configuration réseau de la RecoveryBox est basée sur **systemd-networkd** et des **bridges réseau**.

### État général du réseau

```bash
# Afficher toutes les interfaces et bridges
network-configurator status

# Afficher la configuration réseau générée
network-configurator GetVInterfacesConfig
```

### Vérification de systemd-networkd

```bash
# État du service réseau
systemctl status systemd-networkd

# Logs réseau
journalctl -u systemd-networkd
```

### Vérification des interfaces

```bash
# Lister les interfaces réseau
ip link show

# Lister les interfaces Wi-Fi
iw dev

# Vérifier les adresses IP attribuées
ip addr show
```

### Vérification du pare-feu

```bash
# État du service iptables
systemctl status iptables

# Consulter les règles actives
iptables -nvL
iptables -t nat -nvL
```

### Vérification du routage

```bash
# Table de routage
ip route show

# Tester la connectivité Internet
ping -c 3 8.8.8.8

# Tester la résolution DNS
nslookup google.com
```

### Résolution de problèmes courants

| Problème | Cause possible | Solution |
| --- | --- | --- |
| Aucune interface visible | systemd-networkd non démarré | `systemctl restart systemd-networkd` |
| Pas de connexion Internet | Interface WAN non configurée | Utiliser `network-configurator` pour configurer l'interface |
| Les clients Wi-Fi n'ont pas d'IP | dnsmasq ne fonctionne pas | `systemctl restart ap.service` |
| Ping vers l'extérieur échoue | Règles iptables bloquantes | Vérifier `/etc/iptables/iptables.sh` et redémarrer le service |

!!! info "Documentation"
    - Fiche outil : [**network-configurator**](./network-configurator.md)
    - Fiche réseau : [**Configuration Réseau**](./network.md)
    - **[systemd-networkd — Wiki Debian](https://wiki.debian.org/SystemdNetworkd)**

---

## Docker

De nombreux services de la RecoveryBox sont conteneurisés avec Docker. En cas de problème, il est utile de vérifier l'état de Docker et des conteneurs.

### Vérification générale

```bash
# État du service Docker
systemctl status docker

# Lister tous les conteneurs en cours d'exécution
docker ps

# Lister tous les conteneurs (y compris arrêtés)
docker ps -a
```

### Logs d'un conteneur

```bash
# Logs du dernier conteneur concerné
docker logs <nom_du_conteneur>

# Logs en temps réel
docker logs -f <nom_du_conteneur>
```

### Redémarrer un conteneur

```bash
# Redémarrer via systemd (recommandé)
systemctl restart <service>.service

# Redémarrer directement le conteneur (dernier recours)
docker restart <nom_du_conteneur>
```

### Nettoyage

```bash
# Supprimer les conteneurs arrêtés
docker container prune

# Supprimer les images inutilisées
docker image prune
```

!!! warning "Important"
    Privilégiez toujours le redémarrage via `systemctl` plutôt qu'un redémarrage direct de Docker. Le service systemd gère les dépendances et les montages de volumes.

---

## Apache2

Plusieurs services (carto, console, librairie, wiki, etc.) sont servis via des VirtualHosts Apache2.

### Vérification du service

```bash
# État du service Apache2
systemctl status apache2

# Tester la configuration
apache2ctl configtest
```

### Vérification des VirtualHosts

```bash
# Lister les VirtualHosts activés
apache2ctl -S

# Lister les sites activés
ls -la /etc/apache2/sites-enabled/
```

### Logs

```bash
# Logs d'erreur globaux
tail -f /var/log/apache2/error.log

# Logs d'accès globaux
tail -f /var/log/apache2/access.log
```

### Résolution de problèmes courants

| Problème | Cause possible | Solution |
| --- | --- | --- |
| Tous les services web sont indisponibles | Apache2 arrêté | `systemctl start apache2` |
| Un seul service ne répond pas | VirtualHost désactivé | `a2ensite <service>.conf && systemctl reload apache2` |
| Erreur SSL | Certificat manquant ou expiré | Vérifier les fichiers dans `/etc/ssl/` |

---

## GPS & Synchronisation temporelle

Le GPS fournit la position et permet la synchronisation de l'heure via Chrony.

### Vérification de GPSD

```bash
# État du service GPS
systemctl status gpsd.service

# Données GPS brutes
gpspipe -w -n 5

# Vérifier la position
cgps -s
```

### Vérification de Chrony

```bash
# État du service Chrony
systemctl status chrony.service

# Sources de synchronisation
chronyc sources

# Précision de la synchronisation
chronyc tracking
```

### Résolution de problèmes courants

| Problème | Cause possible | Solution |
| --- | --- | --- |
| "No GPS device" dans rbstatus | GPS USB non détecté | Vérifier `lsusb` et les logs : `dmesg | grep tty` |
| Pas de fix GPS | Signal faible ou antenne bloquée | Déplacer l'antenne GPS vers un emplacement dégagé |
| Heure incorrecte | Chrony pas synchronisé | Vérifier `chronyc sources` et la connectivité NTP |

!!! info "Documentation"
    Consultez la fiche : [**Outils système**](./system-tools.md) pour plus de détails sur gpsd et chrony.

---

## Commandes utiles de debug

Voici un récapitulatif des commandes les plus utiles pour le dépannage quotidien :

| Commande | Description |
| --- | --- |
| `rbstatus` | Affiche l'état de tous les services, du GPS et du système |
| `systemctl status <service>` | État d'un service systemd |
| `journalctl -u <service> -f` | Logs en temps réel d'un service |
| `docker ps` | Conteneurs Docker en cours d'exécution |
| `docker logs -f <conteneur>` | Logs d'un conteneur Docker |
| `network-configurator status` | État des interfaces et bridges réseau |
| `curl -I http://localhost:<port>/` | Tester l'accès HTTP d'un service |
| `ip link show` | Lister les interfaces réseau |
| `free -h` | Mémoire disponible |
| `df -h` | Espace disque disponible |

!!! tip "Astuce"
    En cas de doute, un redémarrage complet de la RecoveryBox (`reboot`) résout souvent les problèmes temporaires liès au démarrage des services.
