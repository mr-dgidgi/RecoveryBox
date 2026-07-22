---
title: Configuration Réseau
description: Architecture réseau de la RecoveryBox, gestion des bridges, interfaces et règles iptables.
tags:
  - outil
  - réseau
---

# Configuration Réseau

## Présentation

La RecoveryBox utilise une architecture basée sur des **bridges réseau** pour gérer ses interconnexions de manière versatile. Chaque interface physique peut être associée à l'un des bridges en fonction des besoins.

La gestion des interfaces est assurée par **[systemd-networkd](https://wiki.debian.org/SystemdNetworkd)**.

## Diagramme

![Network Diagram](../../images/network-diagram.png)

## Architecture

### Bridges

| Bridge | Rôle |
| --- | --- |
| **Wan** | Regroupe les interfaces connectées à Internet (Ethernet en priorité, Wi-Fi en secours) |
| **Lan** | Regroupe les interfaces du réseau local (clients, services internes) |

### Interface Wi-Fi (wlanAP)

L'interface `wlanAP` est liée au conteneur **[simple-hotspot](https://github.com/mr-dgidgi/Simple-Hotspot)** qui assure la bridge vers l'interface **Lan**.

### Priorité WAN

La **priorité** est toujours mise sur les **interfaces Ethernet**. Même si une interface Wi-Fi sur le WAN récupère une route avec une passerelle, la priorité sera sur l'interface Ethernet tant que celle-ci est active.

## Règles iptables

Les règles iptables sont définies dans le fichier `/etc/iptables/iptables.sh`.

### Règles par défaut

| Chaîne | Règle | Description |
| --- | --- | --- |
| **INPUT** | Tout depuis Lan | Trafic autorisé depuis le réseau local |
| **INPUT** | ICMP depuis Wan | Ping autorisé depuis Internet |
| **INPUT** | SSH (port 22) depuis Wan | Connexion SSH autorisée depuis Internet |
| **INPUT** | Drop depuis Wan | Tout autre trafic WAN bloqué en entrée |
| **FORWARD** | Tout vers Wan | Trafic transmis vers Internet |
| **FORWARD** | Tout vers les conteneurs | Trafic transmis vers les conteneurs Docker |
| **NAT** | Masquerade en sortie Wan | Traduction d'adresse pour sortir sur Internet |

## Gestion des interfaces

!!! warning "Fichiers gérés"
    Toute la gestion des interfaces et de leurs règles est effectuée par le script **network-configurator**. Tous les fichiers gérés par ce script sont préfixés par le commentaire `Managed by network-configurator`. En cas de modification manuelle de ces fichiers, celles-ci peuvent être effacées lors d'une exécution du **network-configurator**.
