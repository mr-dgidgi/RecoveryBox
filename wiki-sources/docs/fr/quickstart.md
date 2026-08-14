---
title: Installation rapide
description: Guide d'installation rapide de la RecoveryBox, de la préparation de la clé USB au premier démarrage.
tags:
  - guide
  - installation
---

# Installation rapide

## Prérequis

### Nécessaire

- Un PC sous Linux ou Windows avec WSL activé (pour générer la clé USB d'installation).
- Un ordinateur d'architecture **x86_64** équipé d'au moins un port Ethernet et d'une carte (ou clé USB) Wi-Fi qui servira de RecoveryBox.
- Un écran connecté à la RecoveryBox pour le suivi de l'installation.

### Optionnel

- Un récepteur GPS USB.
- Une clé SDR compatible RTL-SDR.

---

# Étapes d'installation

## 1. Préparation du support d'installation

!!! warning "Attention"
    Ces étapes doivent être réalisées dans WSL ou sur un système Linux. L'utilisation de Windows seul n'est pas supportée.
    Cette étape est à réaliser sur un ordinateur **différent** de celui qui sera utilisé comme RecoveryBox. L'ordinateur cible doit être démarré sur la clé USB générée.

1. Téléchargez la dernière release de [debian-13-preseed-RB](https://github.com/mr-dgidgi/debian13-preseed-RB/releases/latest).
2. Utilisez [Rufus](https://rufus.ie/) ou [Raspberry Pi Imager](https://www.raspberrypi.com/software/) pour créer une clé USB bootable à partir de l'image ISO présente dans le fichier zip.

---

## 2. Installation du système

1. Connectez le câble réseau sur le port Ethernet de la future RecoveryBox.
2. Démarrez la machine sur la clé USB.
3. Patientez jusqu'à la fin complète de l'installation automatisée de Debian.
4. Connectez les périphériques matériels :
   - clé Wi-Fi (si aucune carte Wi-Fi interne n'est présente) ;
   - récepteur GPS USB *(optionnel)* ;
   - clé RTL-SDR *(optionnel)*.

---

## 3. Installation de la Recovery Box

1. Connectez-vous :

```text
Utilisateur : recuser
Mot de passe : Recovery
```

2. Passez en administrateur :

```bash
sudo su -
```

Mot de passe :

```text
Recovery
```

3. Créez le répertoire destiné aux données :

```bash
mkdir /data
```

4. Clonez le dépôt du projet :

```bash
git clone --branch {{ rb_version }} https://github.com/mr-dgidgi/RecoveryBox.git
```

5. Lancez le programme d'installation :

```bash
cd RecoveryBox
bash install.sh
```

---

## 4. Déroulement de l'installation

Le script d'installation réalise automatiquement les opérations suivantes, combinant les actions directes du script et celles exécutées par le playbook Ansible qu'il invoque :

### Phase 1 — Vérifications et prérequis (script)

| Étape | Description |
|-------|-------------|
| Vérification des prérequis | Vérifie les droits administrateur, l'architecture amd64, la présence du répertoire `/data` et du système Debian. |
| Vérification du matériel | Contrôle la présence d'une interface Wi-Fi pour le point d'accès. |
| Choix du clavier | Propose de reconfigurer la disposition du clavier (optionnel). |
| Installation d'Ansible | Installe Ansible, python3-docker, python3-apt et les collections Galaxy (community.docker). |

### Phase 2 — Configuration interactive (script)

| Étape | Description |
|-------|-------------|
| Choix de la langue | Sélectionne la langue des contenus installés (Français, Anglais ou les deux). |
| Mode d'installation | Choix entre installation par défaut ou personnalisée. |
| Configuration des services | *(mode personnalisé)* Permet d'activer ou de désactiver chaque service individuellement (Apache, Bibliothèque, BRouter, TileServer, Meshtastic, Console, OpenWebRX, Kiwix). |
| Téléchargements Kiwix | *(mode personnalisé)* Configure le téléchargement de Wikipédia FR/EN et la taille souhaitée (all_mini, all_no_pic, all_maxi). |
| Configuration du nœud Meshtastic | *(mode personnalisé)* Définit l'adresse IP et MAC d'un nœud Meshtastic (optionnel). |
| Activation du HTTPS | *(mode personnalisé)* Permet d'activer le HTTPS pour tous les services web. |
| Génération du fichier de config | Écrit le fichier `/etc/recoverybox/custom_config.yml` avec les choix effectués. |

### Phase 3 — Playbook Ansible (automatique)

| Étape | Description |
|-------|-------------|
| **Environnement système** | Installe les paquets de base (curl, git, wget, firmware Realtek/IWLWifi, gpsd, chrony, tippecanoe, etc.) et crée les répertoires système. |
| **Configuration réseau** | Déploie les scripts iptables, active le routage IPv4 et configure le pare-feu. |
| **Installation de Docker** | Installe Docker et ses dépendances. |
| **Configuration GPS** | Configure GPSD et Chrony pour la synchronisation temporelle via GPS. |
| **Outils de gestion** | Installe rbstatus, le services-manager, network-configurator et le fichier de registry des services. |
| **Installation de Kiwix** | Déploie le conteneur Docker Kiwix (serveur de contenus Wikipédia hors ligne). |
| **Téléchargement Kiwix** | Télécharge les fichiers ZIM de Wikipédia selon la configuration (FR/EN, taille choisie). |
| **Point d'accès Wi-Fi** | Installe et configure le hotspot **recoverybox** (simple-hotspot, hostapd, dnsmasq). |
| **Apache2** | Installe et configure le serveur web Apache2 avec les VirtualHosts des services. |
| **Bibliothèque PDF** | Télécharge les documents de survie correspondant à la langue choisie. |
| **Console Web** | Déploie ShellInABox pour l'administration distante. |
| **TileServer-GL** | Installe le serveur de cartographie et le style cartographique Liberty. |
| **Outils cartographiques** | Installe Planetiler (conteneur Docker) et l'outil `generate-map`. |
| **BRouter** | Installe le moteur de calcul d'itinéraire et télécharge les données de routage. |
| **OpenWebRX Plus** | Déploie l'interface SDR accessible depuis le navigateur. |
| **Pilotes RTL-SDR** | Compile et installe les derniers pilotes RTL-SDR Blog. |
| **Meshtastic Web Client** | Déploie le client web Meshtastic (conteneur Docker). |
| **Meshtastic Daemon** | Installe le daemon Python et l'intégration cartographique BRouter. |
| **MkDocs** | Déploie le wiki technique RecoveryBox (conteneur Docker MkDocs Material). |

### Phase 4 — Finalisation (script)

| Étape | Description |
|-------|-------------|
| Génération de cartes | Propose le téléchargement de cartes supplémentaires (continent/pays) via `generate-map`. |
| Configuration réseau | Vérifie et configure les interfaces réseau si nécessaire (renommage, bridges, systemd-networkd). |
| Enregistrement de la version | Copie le fichier de version dans `/etc/recoverybox/`. |
| Redémarrage | Demande le redémarrage de la machine afin d'appliquer l'ensemble des modifications. |

---

## 5. Premier démarrage

Une fois l'installation terminée :

1. Redémarrez la RecoveryBox.
2. Connectez un ordinateur ou un smartphone au point d'accès Wi-Fi :

```text
SSID : recoverybox
Mot de passe : recoverybox
```

3. Ouvrez un navigateur et accédez à :

```text
http://recovery.box
```

La RecoveryBox est maintenant opérationnelle.
