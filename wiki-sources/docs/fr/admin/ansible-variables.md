---
title: Variables Ansible personnalisées
description: Documentation des variables personnalisables via /etc/recoverybox/custom_config.yml pour la RecoveryBox.
tags:
  - ansible
  - configuration
  - variables
---

# Variables Ansible personnalisées

## Présentation

Le fichier **`/etc/recoverybox/custom_config.yml`** permet de personnaliser le déploiement Ansible de la RecoveryBox sans modifier les fichiers du rôle.

Ce fichier est **géré automatiquement** par le script **[install.sh](RecoveryBox_install.md)** lors de la configuration interactive. Il est ensuite passé en `extra-vars` au playbook Ansible (`ansible/Install.yml`).

!!! note "Note"
    Vous pouvez aussi créer/modifier ce fichier manuellement avant de lancer une installation en mode `custom` (`sudo ./install.sh custom`).

---

## Structure du fichier

Le fichier doit contenir un dictionnaire YAML avec les variables à surcharger. Exemple minimal :

```yaml
# /etc/recoverybox/custom_config.yml
recoverybox_enable_kiwix: false
recoverybox_hotspot_conf:
  ssid: "mon-recoverybox"
  password: "motdepasse123"
```

---

## Liste complète des variables personnalisables

### Versions des composants

| Variable | Défaut | Description |
|----------|--------|-------------|
| `recoverybox_version_library` | `"1.1.0"` | Version de la bibliothèque RecoveryBox (GitHub releases) |
| `recoverybox_version_fonts` | `"master"` | Version des polices (branche Git) |
| `recoverybox_version_rtlsdr` | `"v1.3.6"` | Version RTL-SDR Blog (tag Git) |
| `recoverybox_version_brouter_container` | `"v1.7.9"` | Version du conteneur BRouter (Docker) |
| `recoverybox_version_brouter_web` | `"0.18.1"` | Version interface web BRouter (GitHub releases) |
| `recoverybox_version_meshtastic_web` | `"2.7.1"` | Version client web Meshtastic (Docker) |
| `recoverybox_version_kiwix` | `"3.8.2"` | Version Kiwix-serve (Docker) |
| `recoverybox_version_simple_hotspot` | `"1.0"` | Version simple-hotspot (Docker) |
| `recoverybox_version_owrx` | `"1.2.118"` | Version OpenWebRX+ (Docker) |
| `recoverybox_version_tileserver` | `"v5.6.0"` | Version TileServer-GL (Docker) |
| `recoverybox_version_planetiler` | `"0.10.2"` | Version Planetiler (Docker) |
| `recoverybox_version_flatnotes` | `"v5.5.4"` | Version du conteneur Flatnotes (Docker) |

!!! warning "Attention"
    Ne modifiez ces versions que si vous avez une raison précise (compatibilité, bug connu). Les versions listées sont testées et validées, si la version que vous souhaitez utiliser est différente, vérifiez avec `rb-update` qu'il n'y a pas une nouvelle version de RecoveryBox qui inclut cette modification.

---

### Activation/désactivation des services

| Variable | Défaut | Description |
|----------|--------|-------------|
| `recoverybox_enable_apache` | `true` | Active Apache2 (requis pour Library, Console, Kiwix web) |
| `recoverybox_enable_library` | `true` | Active la bibliothèque PDF locale (nécessite Apache) |
| `recoverybox_enable_owrx` | `true` | Active OpenWebRX+ (SDR web) |
| `recoverybox_enable_brouter` | `true` | Active BRouter (moteur de routage hors-ligne) |
| `recoverybox_enable_tileserver` | `true` | Active TileServer-GL (serveur tuiles vectorielles OSM) |
| `recoverybox_enable_console` | `true` | Active la console web d'administration (ShellInABox) |
| `recoverybox_enable_kiwix` | `true` | Active Kiwix (Wikipédia hors-ligne) |
| `recoverybox_enable_meshtastic` | `true` | Active les services Meshtastic (web client + daemon) |
| `recoverybox_enable_hotspot` | `true` | Active le point d'accès Wi-Fi (hotspot) |
| `recoverybox_enable_flatnotes` | `true` | Active le service Flatnotes (prise de notes web) |

!!! note "Note"
    Si `recoverybox_enable_apache: false`, l'ensemble des services web sera automatiquement **désactivé** par le playbook.

!!! warning "Attention"
    Si `recoverybox_enable_hotspot: false`, le point d'accès Wi-Fi ne sera pas créé et l'ensemble des services sera inaccessible.

---

### Activation HTTPS
| Variable | Défaut | Description |
|----------|--------|-------------|
| `recoverybox_enable_https` | `false` | Active HTTPS pour tous les services web|

### Interfaces réseau

| Variable | Défaut | Description |
|----------|--------|-------------|
| `recoverybox_interface_wlanap` | `"wlanAP"` | Nom de l'interface Wi-Fi renommée pour le hotspot |
| `recoverybox_interface_wan` | `"Wan"` | Nom du bridge WAN (côté Internet) |
| `recoverybox_interface_lan` | `"Lan"` | Nom du bridge LAN (côté local + hotspot) |

---

### Configuration du Hotspot

Objet `recoverybox_hotspot_conf` avec les clés suivantes :

| Clé | Défaut | Description |
|-----|--------|-------------|
| `ssid` | `"recoverybox"` | Nom du réseau Wi-Fi (SSID) |
| `password` | `"recoverybox"` | Clé WPA2-PSK (8 à 63 caractères) |
| `mode` | `"g"` | Mode PHY : `g` (2.4 GHz), `a` (5 GHz), `acs` (auto) |
| `channel` | `"11"` | Canal Wi-Fi (ex. : `1`, `6`, `11`, `36`, `0` pour auto/ACS) |
| `auth_algs` | `"1"` | Algorithmes d'authentification (1 = Open System) |
| `wpa` | `"2"` | Version WPA (2 = WPA2) |
| `wpa_key_mgmt` | `"WPA-PSK"` | Gestion des clés |
| `wpa_pairwise` | `"TKIP CCMP"` | Chiffrement pairwise |
| `rsn_pairwise` | `"CCMP"` | Chiffrement RSN (WPA2) |
| `network` | `"192.168.200.0"` | Réseau IP du hotspot |
| `mask` | `"24"` | Masque de sous-réseau (CIDR) |
| `ip` | `"192.168.200.1"` | IP passerelle du hotspot |
| `dhcp_range_start` | `"192.168.200.100"` | Début plage DHCP |
| `dhcp_range_end` | `"192.168.200.200"` | Fin plage DHCP |

!!! warning "Important"
    L'interface Wi-Fi doit supporter le mode AP pour le canal et le mode choisis.

---

### Configuration Meshtastic (nœud externe)

Objet `recoverybox_meshtastic_node` :

| Clé | Défaut | Description |
|-----|--------|-------------|
| `mac` | `"00:00:00:00:00:00"` | Adresse MAC du nœud Meshtastic (pour réservation DHCP statique) |
| `ip` | `"192.168.200.101"` | IP fixe attribuée au nœud Meshtastic |

!!! note "Note"
    Utilisé uniquement si `recoverybox_enable_meshtastic: true` et qu'un nœud physique est connecté.

---

### Configuration OpenWebRX

Objet `recoverybox_owrx_conf` :
| Clé | Défaut | Description |
|-----|--------|-------------|
| `username` | `"recoverybox"` | Nom d'utilisateur pour l'accès à OpenWebRX |
| `password` | `"recoverybox"` | Mot de passe pour l'accès à OpenWebRX |

### Téléchargements Kiwix

Liste `recoverybox_kiwix_files` (chaque élément est un objet) :

| Clé | Description |
|-----|-------------|
| `category` | Catégorie : `wikipedia`, `maps`, `wikivoyage`, `ted`, `stackexchange`, etc. |
| `language` | Code langue ISO 639-1 : `fr`, `en`, `es`, `de`, etc. |
| `enable` | `true`/`false` pour activer ce téléchargement |
| `arg` | Variante : `all_mini`, `all_nopic`, `all_maxi` (voir [download.kiwix.org](https://lb.download.kiwix.org/zim/)) |

Exemple :
```yaml
recoverybox_kiwix_files:
  - category: wikipedia
    language: fr
    enable: true
    arg: "all_nopic"
  - category: wikipedia
    language: en
    enable: true
    arg: "all_nopic"
  - category: maps
    language: en
    enable: false
    arg: "france"
```

---

### Téléchargements cartographiques

| Variable | Défaut | Description |
|----------|--------|-------------|
| `recoverybox_download_brouter` | `true` | Télécharge les segments BRouter (routing vélo/rando/voiture) |
| `recoverybox_download_mbtiles` | `true` | Télécharge `world.mbtiles` pour TileServer-GL (carte monde) |

!!! warning "Attention"
    Ces téléchargements peuvent représenter plusieurs Go. Désactivez (`false`) si bande passante ou espace disque limité et que ceux-ci sont déjà téléchargés.

---

### Configuration Flatnotes

| Variable | Défaut | Description |
|----------|--------|-------------|
| `recoverybox_flatnotes_open` | `"full"` | Type d'installation Flatnotes : `open`, `secure`, `full` |
| `recoverybox_flatnotes_secure` | objet | Configuration pour l'installation sécurisée de Flatnotes (nom d'utilisateur, mot de passe, clé secrète) |
| `recoverybox_flatnotes_secure.username` | `"recadmin"` | Nom d'utilisateur pour l'accès sécurisé |
| `recoverybox_flatnotes_secure.password` | `"RecoveryAdmin"` | Mot de passe pour l'accès sécurisé |
| `recoverybox_flatnotes_secure.secret_key` | `"aLongRandomSeriesOfCharacters123"` | Clé secrète pour la session sécurisée |


## Exemple complet

```yaml
# /etc/recoverybox/custom_config.yml
# Exemple de configuration personnalisée

# Versions (optionnel - gardez les défauts sauf besoin spécifique)
# recoverybox_version_brouter_container: "v1.7.9"

# Services : on désactive Kiwix et OpenWebRX pour gagner de la place
recoverybox_enable_kiwix: false
recoverybox_enable_owrx: false

# Hotspot personnalisé
recoverybox_hotspot_conf:
  ssid: "RecoveryBox-MonSite"
  password: "PassSecurise123!"
  mode: "g"
  channel: "6"
  network: "10.0.0.0"
  mask: "24"
  ip: "10.0.0.1"
  dhcp_range_start: "10.0.0.50"
  dhcp_range_end: "10.0.0.150"

# Nœud Meshtastic connecté en USB/Ethernet
recoverybox_meshtastic_node:
  mac: "aa:bb:cc:dd:ee:ff"
  ip: "10.0.0.10"

# Kiwix : seulement Wikipédia FR sans images
recoverybox_kiwix_files:
  - category: wikipedia
    language: fr
    enable: true
    arg: "all_nopic"

# Pas de téléchargement cartes (bande passante limitée)
recoverybox_download_brouter: false
recoverybox_download_mbtiles: false

# Activation HTTPS pour tous les services web
recoverybox_enable_https: true
```

---

## Utilisation avec install.sh

### Générer le fichier (mode interactif)

```bash
sudo ./install.sh config
```
→ Lance uniquement le menu de configuration et écrit `/etc/recoverybox/custom_config.yml`

### Installation avec config existante

```bash
sudo ./install.sh custom
```
→ Utilise le fichier existant, saute le menu, lance directement le playbook Ansible

### Installation complète (génère + applique)

```bash
sudo ./install.sh
```
→ Menu interactif → écrit `custom_config.yml` → lance Ansible

---

## Bonnes pratiques

1. **Ne modifiez pas** les fichiers du rôle (`ansible/roles/recoverybox/defaults/main.yml`) — ils sont gérés par Git/Ansible et seront écrasés.
2. **Utilisez uniquement** `/etc/recoverybox/custom_config.yml` pour vos surcharges.
3. **Validez la syntaxe YAML** avant de lancer l'installation :
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('/etc/recoverybox/custom_config.yml'))"
   ```

---