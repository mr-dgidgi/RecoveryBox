---
title: Installation avancée
description: Guide détaillé de l'installation de la RecoveryBox, prérequis, scénarios et déroulement complet.
tags:
  - outil
  - installation
---

# Installation avancée

Cette page décrit plus en détail l'installation de la solution **RecoveryBox**, ses prérequis et les différents scénarios d'installation possibles.

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

La méthode recommandée consiste à utiliser l'ISO Debian personnalisé généré à l'aide du projet **[debian13-preseed-RB](https://github.com/mr-dgidgi/debian13-preseed-RB)** (plus de détail dans [l'installation rapide](../quickstart.md)).

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
|- lancer `install.sh`.

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

La RecoveryBox peut être installée sur une machine disposant de plusieurs interfaces réseau.

Le script permet de renommer les interfaces afin de leur attribuer des noms explicites (`Wan`, `Lan`, etc.), indépendamment du nom attribué par Linux.

Les interfaces supplémentaires peuvent ensuite être configurées manuellement avec `network-configurator` selon les besoins.

Il n'y a aucune limitation sur le nombre d'interfaces réseau en dehors des limites physiques (nombre de ports PCI ou USB)

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

Les étapes principales sont décrites sur la page dédiée de **[install.sh](RecoveryBox_install.md)**.

La durée de l'installation dépend principalement des téléchargements optionnels sélectionnés.Sans téléchargement de contenu, l'installation est généralement relativement rapide. En revanche, le téléchargement de Wikipédia ou des données cartographiques peut représenter plusieurs dizaines de gigaoctets et nécessiter plusieurs heures selon la connexion Internet.

Par ailleurs, la génération des cartes détaillées pendant l'installation peut être très longue selon la puissance de la machine et le nombre de tuiles à générer.

---

# Après l'installation

À l'issue de l'installation, un **redémarrage complet** est indispensable.

Ce redémarrage permet notamment :

- l'activation de `systemd-networkd` ;
- le démarrage des différents services installés ;
- l'activation du point d'accès Wi-Fi ;
- la prise en compte de l'ensemble de la configuration système.

Une fois le système redémarré, la Recovery Box est accessible via le point d'accès Wi-Fi **recoverybox** ainsi que par les différents services Web installés.

---

## Voir aussi

- **[install.sh](RecoveryBox_install.md)** — Documentation complète du script d'installation principal (modes, configuration, dépannage)
- **[rb-update](rb-update.md)** — Script de mise à jour automatisée de la RecoveryBox