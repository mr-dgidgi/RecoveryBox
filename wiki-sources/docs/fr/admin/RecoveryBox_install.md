---
title: RecoveryBox_install.sh
description: Script d'installation automatisé de la RecoveryBox sur Debian/amd64.
tags:
  - outil
  - installation
---

# RecoveryBox_install.sh

## Présentation

`RecoveryBox_install.sh` est le script d'installation principal du projet **RecoveryBox**. Il automatise le déploiement complet ainsi que la mise à jour et l'activation/désactivation des services.

Le script orchestre l'ensemble du processus :
- Vérification des prérequis système (root, architecture amd64, point de montage `/data`, interface WiFi)
- Installation d'Ansible et des collections requises
- Configuration interactive des services à activer
- Exécution du playbook Ansible (déploiement Docker, services, réseau)
- Configuration finale du réseau via `systemd-networkd`
- Redémarrage obligatoire pour appliquer la configuration

!!! warning "Exécution en root"
    Le script **doit être exécuté en root** (`sudo`). Il vérifie l'UID au démarrage et s'arrête en cas de non-conformité.

!!! warning "Redémarrage obligatoire"
    Un redémarrage complet du système est **requis** à la fin de l'installation pour activer `systemd-networkd`, le point d'accès WiFi et l'ensemble des services.

---

## Modes d'exécution

| Mode | Commande | Description |
|------|----------|-------------|
| **Installation complète (interactive)** | `sudo ./RecoveryBox_install.sh` | Lance l'installation complète avec menus interactifs |
| **Configuration uniquement** | `sudo ./RecoveryBox_install.sh config` | Affiche uniquement le menu de configuration des services (génère `/etc/recoverybox/custom_config.yml`) |
| **Installation avec config existante** | `sudo ./RecoveryBox_install.sh custom` | Utilise `/etc/recoverybox/custom_config.yml` existant (passe le menu) |

---

## Guide d'utilisation

### Installation complète (mode interactif)

```bash
sudo ./RecoveryBox_install.sh
```
- Le script propose de reconfigurer la disposition clavier via `dpkg-reconfigure keyboard-configuration`.
- ** Installation par défaut ? (oui/non) **
  - **Oui** → Tous les services sont activés avec leurs valeurs par défaut. Pas de menu détaillé.
  - **Non** → Menu détaillé de configuration service par service (voir ci-dessous).

- Chaque service peut être activé ou désactivé individuellement :

| Service | Défaut | Description |
|---------|--------|-------------|
| **Apache (serveur web)** | `true` | Active Apache + modules (PHP, etc.) |
| **RecoveryBox Library** | `true` | Bibliothèque locale (nécessite Apache) |
| **BRouter** | `true` | Routage hors-ligne (vélo, rando, voiture) |
| **Téléchargement cartes BRouter** | `true` | Télécharge les données cartographiques |
| **TileServer-GL** | `true` | Serveur de tuiles vectorielles (OSM) |
| **Téléchargement carte monde (mbtiles)** | `true` | Télécharge la carte monde pour TileServer |
| **Meshtastic** | `true` | Services Meshtastic (MQTT, web, etc.) |
| **Web Console** | `true` | Console web d'administration (ShellInABox) |
| **OpenWebRX+** | `true` | SDR web (réception radio) |
| **Kiwix (Wikipédia hors-ligne)** | `true` | Serveur Kiwix + fichiers ZIM |


!!! info "Fichier de configuration généré"
    À l'issue du menu, le script génère **`/etc/recoverybox/custom_config.yml`** contenant les variables Ansible (`extra-vars`) correspondant à vos choix.

- Le script lance automatiquement le playbook `ansible/Install.yml` :
- Le script propose de lancer `/usr/local/bin/generate-map` pour télécharger un continent/pays spécifique (BRouter, TileServer).
- Si `systemd-networkd` n'est pas encore le gestionnaire réseau unique, le script utilise l'outil `network-configurator` pour :
  - Créer les bridges `WAN` / `LAN`
  - Renommer l'interface WiFi en `wlanAP`
  - Lier une interface physique au WAN (DHCP ou statique)
 - Basculer vers `systemd-networkd` + `systemd-resolved`

!!! warning "Redémarrage requis"
    Cette étape **nécessite un redémarrage** pour prendre effet.

- Copie du fichier `VERSION` vers `/etc/recoverybox/rb_version`
- Affichage du message : **REDÉMARRAGE OBLIGATOIRE**

---

### Configuration uniquement (mode `config`)

```bash
sudo ./RecoveryBox_install.sh config
```
Lance uniquement le menu de configuration des services (sans exécuter le playbook). Ceci génère ou met à jour le fichier `/etc/recoverybox/custom_config.yml` avec vos choix.

### Installation avec configuration existante (mode `custom`)

```bash
sudo ./RecoveryBox_install.sh custom
```
Le script utilise le fichier `/etc/recoverybox/custom_config.yml` existant pour exécuter le playbook Ansible sans passer par le menu interactif. Ce mode est utile pour les mises à jour ou les réinstallations avec la même configuration.


---


!!! note "Détection de mise à jour"
    Le script détecte `/etc/recoverybox/rb_version` et ajoute le suffixe `-upgrading` s'il existe.

---

## Dépannage courant

| Symptôme | Cause probable | Résolution |
|----------|----------------|------------|
| `user is not root` | Script lancé sans `sudo` | Relancer avec `sudo` |
| `/data does not exist` | Point de montage manquant | `mkdir /data && mount /dev/sdX /data` |
| `This script is only for Debian based systems` | OS non-Debian | Utiliser Debian/Ubuntu/Devuan amd64 |
| `This script is only for amd64 architecture` | Architecture ARM/autre | Matériel x86_64 requis |
| `No wireless interface found` | Pas d'interface WiFi / pilote manquant | Ajouter carte WiFi USB compatible AP (ath9k, ath10k, mt76, etc.) |
| `Ansible binaries are not available` | Échec installation Ansible | Vérifier `apt`, réseau, dépôts Debian |
| `community.docker is not available` | Échec `ansible-galaxy` | Vérifier connexion Internet, relancer script |
| `network-configurator command not found` | Ansible n'a pas déployé l'outil | Vérifier playbook Ansible, relancer |
| `failed to configure network interfaces` | `systemd-networkd` non activé | Vérifier `systemctl status systemd-networkd` |
| `Ansible playbook execution failed` | Erreur playbook (Docker, réseau, etc.) | Relancer en debug : `ansible-playbook -vvv ...` |

