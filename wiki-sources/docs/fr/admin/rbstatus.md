---
title: rbstatus
description: Script de supervision affichant l'état des services, du GPS et du système de la RecoveryBox.
tags:
  - outil
  - supervision
---

# rbstatus

## Présentation

`rbstatus` est un script de supervision qui affiche en un coup d'œil l'état de l'ensemble des services proposés par la RecoveryBox, ainsi que l'état du GPS et du système (CPU, RAM, températures).

Le script peut être appelé via la commande :

```bash
rbstatus
```

Un mode allégé est également disponible :

```bash
rbstatus light
```

!!! info "Affichage sur TTY2"
    Un cron job est configuré pour afficher `rbstatus` sur le TTY2 (écran connecté à la RecoveryBox). Si vous souhaitez afficher le résultat sur un écran il suffit de basculer sur le TTY2 avec `Ctrl+Alt+F2`. Pour revenir au TTY1 (console principale) utilisez `Ctrl+Alt+F1`.

---

## Informations remontées

!!! note "Liste dynamique"
    La liste des services affichés est **dynamique** et dépend des services activés lors de l'installation. Seuls les services activés dans `/etc/recoverybox/services.json` sont vérifiés et affichés.

### Services

| Indicateur | Description | Type de vérification |
| --- | --- | --- |
| **Internet Access** | Connectivité Internet | Ping vers Google (8.8.8.8), Cloudflare (1.1.1.1) ou Yandex (77.88.8.8) |
| **DNS Resolver** | Résolution DNS | Requête `nslookup` vers google.com, cloudflare.com ou yandex.com |
| **Time Sync** | Synchronisation temporelle | Vérifie que le service `chrony.service` est actif |
| **AccessPoint** | Point d'accès Wi-Fi | Vérifie que le service `ap.service` est actif |
| **Apache Server** | Serveur web | Vérifie que le service `apache2.service` est actif |
| **PDF Library** | Bibliothèque de documents | Requête HTTP vers `library.recovery.box` (code 200 attendu) |
| **OpenWebRX+** | Récepteur SDR | Vérifie que le service `openwebrx.service` est actif |
| **Brouter (mapping)** | Moteur de routage carto | Vérifie que le service `brouter.service` est actif |
| **TileServer (mapping)** | Serveur de tuiles | Vérifie que le service `tileserver-gl.service` est actif |
| **Web Console** | Console d'administration | Vérifie que le service `shellinabox.service` est actif |
| **Meshtastic Web Client** | Client web Meshtastic | Vérifie que le service `meshtastic-web.service` est actif |
| **MkDocs Material** | Wiki technique | Vérifie que le service `mkdocs.service` est actif |

### GPS

| Indicateur | Description |
| --- | --- |
| **GPS status** | Vérifie que le GPS reçoit des trames TPV via `gpspipe` |
| **GPS fix** | État de la localisation : **2D Lock** (lat + lon), **3D Lock** (lat + lon + alt) ou **No Fix** (pas assez de satellites) |
| **GPS Position** | Position GPS (latitude, longitude, altitude) |

### Système

| Indicateur | Description |
| --- | --- |
| **CPU Usage** | Utilisation du processeur (colorée : vert < 60%, orange < 80%, rouge ≥ 80%) |
| **RAM Usage** | Utilisation de la mémoire vive |
| **Swap Usage** | Utilisation du swap (0% par défaut avec la configuration Debian 13 préseed) |
| **Temperatures** | Températures des sondes thermiques de la machine |

---

## Détail des vérifications

### Services système (type `systemd`)

Le script vérifie pour chaque service :

1. **`systemctl is-active`** : le service est-il en cours d'exécution ?
2. **`systemctl is-enabled`** : le service est-il activé au démarrage ?

| Statut | Signification |
| --- | --- |
| `Running` | Service actif et activé |
| `Critical` | Service inactif ou en erreur |
| `Disabled` | Service activé mais pas démarré au boot |

### Services HTTP (type `http`)

Le script effectue une requête `curl -I` vers l'URL du service avec le header `Host` approprié et vérifie le code de réponse HTTP.

| Statut | Signification |
| --- | --- |
| `Running` | Code HTTP 200 reçu |
| `Critical` | Code HTTP différent de 200 ou timeout |

### Vérifications réseau (type `ping` / `dns`)

- **Ping** : envoie un paquet ICMP vers 3 serveurs (Google, Cloudflare, Yandex). Suffit qu'un seul réponde pour valider.
- **DNS** : effectue une résolution de nom vers 3 domaines. Suffit qu'un seul réussisse pour valider.

### GPS

Le script interroge `gpspipe` pendant 3 secondes et extrait la dernière trame TPV (Time-Position-Velocity). Le mode de fix détermine la précision :

| Mode | Signification |
| --- | --- |
| `3D Lock` | Longitude, latitude et altitude déterminées |
| `2D Lock` | Longitude et latitude uniquement |
| `No Fix` | Pas assez de satellites visibles |
| `No GPS device` | Aucun périphérique GPS détecté |
