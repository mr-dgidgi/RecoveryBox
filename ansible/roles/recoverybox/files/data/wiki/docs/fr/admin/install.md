---
title: Installation avancée
description: Guide détaillé de l'installation de la RecoveryBox, prérequis, scénarios et déroulement complet.
tags:
  - outil
  - installation
---

# Installation avancée

Cette page décrit plus en détail le fonctionnement du script `recovery_box_install.sh`, ses prérequis et les différents scénarios d'installation possibles.

---

# Plateformes supportées

## Architecture

La Recovery Box est développée et testée uniquement pour les systèmes **x86_64 (amd64)**.

Les architectures **ARM** (Raspberry Pi, Orange Pi, RockPi, etc.) ne sont **pas supportées**. Le script vérifie automatiquement l'architecture au démarrage et interrompra l'installation si celle-ci n'est pas compatible.

---

## Distribution Linux

Le script est prévu pour fonctionner sous **Debian 13**.

Deux méthodes d'installation sont possibles :

### Installation recommandée

La méthode recommandée consiste à utiliser l'ISO Debian personnalisé généré à l'aide du projet **[debian13-preseed-RB](https://github.com/mr-dgidgi/debian13-preseed-RB)** (plus de détail dans [l'installation rapide](../quick-installation.md)).

Cette méthode permet :

- une installation entièrement automatisée ;
- une configuration système homogène ;
- une réduction des risques d'erreurs de configuration.

---

### Installation sur une Debian standard

Il est également possible d'installer la Recovery Box sur une installation classique de Debian 13.

Dans ce cas, il est impératif de :

- créer le répertoire `/data` ;
- installer Git ;
- cloner le dépôt RecoveryBox ;
- lancer `recovery_box_install.sh`.

Avant d'exécuter le script, **NetworkManager doit être désactivé**, car la Recovery Box utilise exclusivement **systemd-networkd** pour la gestion des interfaces réseau.

Par exemple :

```bash
systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl enable systemd-networkd
```

Le redémarrage de la machine après l'installation reste nécessaire afin d'appliquer l'ensemble de la configuration système.

---

# Environnement d'exécution

## Serveur sans interface graphique

Il s'agit de la configuration recommandée car elle permet une consommation de ressource moindre et que l'environnement graphique n'a pas de plus-value pour une utilisation standard.

---

## Environnement graphique

Le script peut théoriquement être exécuté sur une Debian disposant d'un environnement graphique (GNOME, KDE, XFCE, etc.).

Cependant, cette configuration **n'a pas été testée** et aucun support spécifique n'est prévu.

Le principal point d'attention concerne la coexistence éventuelle entre les outils graphiques de gestion réseau et **systemd-networkd**.

---

## Machine virtuelle

L'installation dans une machine virtuelle est théoriquement possible.

Cette configuration **n'a cependant pas été validée**.

Certaines fonctionnalités risquent de ne pas fonctionner correctement selon l'hyperviseur utilisé, notamment :

- les interfaces Wi-Fi USB passées à la machine virtuelle ;
- les récepteurs GPS USB ;
- les clés RTL-SDR ;
- les performances liées aux traitements cartographiques.

---

# Configuration réseau

## Plusieurs interfaces Ethernet

La Recovery Box peut être installée sur une machine disposant de plusieurs interfaces réseau.

Le script permet de renommer les interfaces afin de leur attribuer des noms explicites (`Wan`, `Lan`, etc.), indépendamment du nom attribué par Linux.

Les interfaces supplémentaires peuvent ensuite être configurées manuellement avec `network-configurator` selon les besoins.

Il n'y a aucune limitation sur le nombre d'interface réseau en dehors des limitations physiques (nombre de ports pci ou usb)

---

## Carte Wi-Fi obligatoire

La présence d'une interface Wi-Fi est **obligatoire**.

Cette interface est utilisée pour créer le point d'accès Wi-Fi de la Recovery Box.

Il peut s'agir :

- d'une carte Wi-Fi intégrée ;
- d'une clé Wi-Fi USB compatible.

Sans interface Wi-Fi, le point d'accès ne pourra pas être créé et une partie importante des fonctionnalités de la Recovery Box sera indisponible.

---

## Compatibilité des pilotes Wi-Fi

Le script installe automatiquement plusieurs firmwares et pilotes couramment utilisés sous Debian (notamment Realtek et Intel).

Malgré cela, certaines cartes Wi-Fi récentes ou plus spécifiques peuvent nécessiter l'installation de pilotes supplémentaires.

Si l'interface Wi-Fi n'apparaît pas après l'installation, il est recommandé de vérifier :

```bash
ip link
```

ou

```bash
iw dev
```

Si aucun périphérique Wi-Fi n'est détecté, il sera probablement nécessaire d'installer le pilote adapté au chipset de la carte utilisé.

Une fois le pilote installé, le script `network-configurator` pourra être utilisé pour configurer l'interface.

---

# Déroulement de l'installation

Le script réalise automatiquement les opérations suivantes :

**Actions directes du script :**

1. Vérification des prérequis (droits root, architecture amd64, présence de `/data`, système Debian, interface Wi-Fi).
2. Configuration du clavier (optionnel).
3. Installation d'Ansible et de ses dépendances (python3-docker, python3-apt, collections Galaxy).
4. Choix de la langue et de la langue des contenus.
5. Choix du mode d'installation (par défaut ou personnalisé).
6. Configuration des services *(mode personnalisé)* : activation/désactivation de chaque service, téléchargements Kiwix, nœud Meshtastic.
7. Génération du fichier `/etc/recoverybox/custom_config.yml`.
8. Exécution du playbook Ansible (voir ci-dessous).
9. Génération de cartes supplémentaires via `generate-map` *(optionnel)*.
10. Configuration des interfaces réseau si nécessaire.
11. Enregistrement de la version et demande de redémarrage.

**Tâches du playbook Ansible (exécutées automatiquement) :**

| # | Tâche | Description |
|---|-------|-------------|
| 1 | Environnement système | Installation des paquets de base (curl, git, wget, firmware, gpsd, chrony, tippecanoe, etc.) et création des répertoires. |
| 2 | Configuration réseau | Déploiement des scripts iptables, activation du routage IPv4, configuration du pare-feu. |
| 3 | Installation de Docker | Installation de Docker et de ses dépendances. |
| 4 | Configuration GPS | Configuration de GPSD et Chrony pour la synchronisation temporelle via GPS. |
| 5 | Outils de gestion | Installation de rbstatus, services-manager, network-configurator et du registry des services. |
| 6 | Installation de Kiwix | Déploiement du conteneur Docker Kiwix. |
| 7 | Téléchargement Kiwix | Téléchargement des fichiers ZIM de Wikipédia (FR/EN, selon la configuration). |
| 8 | Point d'accès Wi-Fi | Installation et configuration du hotspot **recoverybox** (simple-hotspot, hostapd, dnsmasq). |
| 9 | Apache2 | Installation et configuration du serveur web Apache2 *(conditionnel)*. |
| 10 | Bibliothèque PDF | Téléchargement des documents de survie *(conditionnel)*. |
| 11 | Console Web | Déploiement de ShellInABox *(conditionnel)*. |
| 12 | TileServer-GL | Installation du serveur de cartographie et du style Liberty *(conditionnel)*. |
| 13 | Outils cartographiques | Installation de Planetiler et de l'outil `generate-map`. |
| 14 | BRouter | Installation du moteur de calcul d'itinéraire *(conditionnel)*. |
| 15 | Données BRouter | Téléchargement des données de routage *(conditionnel)*. |
| 16 | OpenWebRX Plus | Déploiement de l'interface SDR *(conditionnel)*. |
| 17 | Pilotes RTL-SDR | Compilation et installation des pilotes RTL-SDR Blog *(conditionnel)*. |
| 18 | Meshtastic Web Client | Déploiement du client web Meshtastic *(conditionnel)*. |
| 19 | Meshtastic Daemon | Installation du daemon Python et intégration BRouter *(conditionnel)*. |
| 20 | MkDocs | Déploiement du wiki technique RecoveryBox *(conditionnel)*. |

La durée de l'installation dépend principalement des téléchargements optionnels sélectionnés.

Sans téléchargement de contenu, l'installation est généralement relativement rapide. En revanche, le téléchargement de Wikipédia ou des données cartographiques peut représenter plusieurs dizaines de gigaoctets et nécessiter plusieurs heures selon la connexion Internet.

---

# Après l'installation

À l'issue de l'installation, un **redémarrage complet** est indispensable.

Ce redémarrage permet notamment :

- l'activation de `systemd-networkd` ;
- le démarrage des différents services installés ;
- l'activation du point d'accès Wi-Fi ;
- la prise en compte de l'ensemble de la configuration système.

Une fois le système redémarré, la Recovery Box est accessible via le point d'accès Wi-Fi **recoverybox** ainsi que par les différents services Web installés.