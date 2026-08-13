---
title: Meshtastic Web Client
description: Client web pour interagir avec les nœuds Meshtastic et visualiser le réseau maillé sur la cartographie.
tags:
  - service
  - meshtastic
  - réseau
---

# Meshtastic Web Client

## Présentation

**Meshtastic** est un projet open-source permettant d'utiliser des radios LoRa comme des nœuds de communication maillée (mesh) à basse consommation. Le réseau Meshtastic fonctionne sans infrastructure existante : chaque nœud relaie les messages des autres, formant un réseau décentralisé et résilient, idéal pour les situations d'urgence ou les environnements isolés.

La RecoveryBox intègre deux composants liés à Meshtastic :

- **Meshtastic Web Client** : interface web permettant d'interagir avec les nœuds Meshtastic connectés au réseau local (via Wi-Fi), ou directement depuis un navigateur client (via Bluetooth ou WebSerial).
- **Meshtastic Daemon** : service arrière-plan qui poll un nœud Meshtastic configuré et expose ses données (nœuds découverts, positions, status) sur la carte BRouter de la RecoveryBox.

**Meshtastic Daemon** est détaillé dans sa page dédiée **[Meshtastic Daemon](../admin/meshtastic-daemon.md)**.

Pour plus de détails sur le projet, consultez la **[documentation officielle de Meshtastic](https://meshtastic.org)** et le **[dépôt GitHub](https://github.com/meshtastic/web)**.

### Caractéristiques

| Propriété | Valeur |
| --- | --- |
| **Type** | Conteneur Docker (service systemd) + daemon Python |
| **Image** | `mrdgidgi/meshtastic-web-client` |
| **Port** | `18000` (hôte) → `80` (conteneur) |
| **Variable d'activation** | `recoverybox_enable_meshtastic` |

## Accès au service

L'interface web Meshtastic est accessible à tous les utilisateurs connectés au hotspot de la RecoveryBox.

| URL | Description |
| --- | --- |
| [http://meshtastic.recovery.box](http://meshtastic.recovery.box) | Interface web Meshtastic |

!!! info "Connexion à un nœud"
    Depuis l'interface web, vous pouvez vous connecter à un nœud Meshtastic de deux manières :
    - **Wi-Fi** : le nœud doit être connecté au réseau de la RecoveryBox (réservation DHCP automatique configurée via `recoverybox_meshtastic_node`)
    - **Bluetooth / WebSerial** : connexion directe depuis le navigateur client à un nœud à proximité

## Configuration avancée

### A. Fichiers de configuration

| Élément | Description |
| --- | --- |
| `/etc/systemd/system/meshtastic-web.service` | Unit systemd du conteneur Docker |
| `/etc/apache2/sites-available/meshtastic-web.conf` | VirtualHost Apache2 (reverse proxy) |

### B. Customisation

#### Configuration d'un nœud Meshtastic

!!! note "optionnel"
    La configuration d'un nœud Meshtastic est optionnelle. L'adresse MAC et l'adresse IP sont utilisées pour créer une réservation DHCP dans dnsmasq, garantissant que le nœud Meshtastic reçoive toujours la même adresse sur le réseau du hotspot. Le service n'est pas dépendant de cette réservation et peut fonctionner avec n'importe quel nœud Meshtastic connecté au réseau local ou directement via Bluetooth/WebSerial au poste client.

Lors de l'installation via `install.sh`, il est possible de configurer l'adresse IP et l'adresse MAC d'un nœud Meshtastic à connecter. Ces informations sont stockées dans `/etc/recoverybox/custom_config.yml` :

Vous pouvez également modifier ces valeurs manuellement dans le fichier de configuration, puis relancer le script pour appliquer les changements.

```yaml
recoverybox_meshtastic_node:
  mac: "AA:BB:CC:DD:EE:FF"
  ip: "192.168.200.101"
```

### C. Debug

```bash
# Consulter les logs du web client
journalctl -u meshtastic-web.service -f

# Vérifier que le conteneur est en cours d'exécution
docker ps | grep meshtastic
```
