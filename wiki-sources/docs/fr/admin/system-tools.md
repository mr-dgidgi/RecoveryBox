---
title: Outils système
description: Description des outils système intégrés à la RecoveryBox (GPSD, Chrony, environnement Python, etc.)
tags:
  - outil
  - système
  - gps
  - chrony
---

# Outils système

## GPSD

Le service **gpsd** permet de gérer la communication avec le GPS et de fournir les informations de position et de temps aux applications qui en ont besoin. Il est configuré pour écouter sur le port 2947 et peut être interrogé par des clients compatibles avec le protocole gpsd.

Ce service est automatiquement installé et démarré qu'un GPS soit présent ou non sur la RecoveryBox. Le service est **configuré** pour se lancer même si aucune application ne l'**interroge**. Cela permet de s'assurer que le GPS est toujours disponible pour les applications qui en ont besoin, même si elles ne sont pas encore lancées.

### Fichier de configuration

```conf
/etc/default/gpsd
```

## Chrony

Le service **chrony** permet de gérer la synchronisation de l'heure du système. Par défaut, il utilise des serveurs NTP publics pour se synchroniser.

Dans la RecoveryBox, chrony est configuré pour utiliser le GPS comme source de temps principale et fournir l'heure exacte aux équipements connectés à la RecoveryBox.

### Fichier de configuration

```conf
/etc/chrony/000-gps.conf
```

### Environnement virtuel Python

Un environnement virtuel Python est utilisé pour isoler les dépendances des applications Python de la RecoveryBox. Cela permet d'éviter les conflits entre les différentes versions de bibliothèques et de garantir que chaque application dispose de son propre ensemble de dépendances.

Cet environnement virtuel est créé dans le répertoire `/data/recoverybox_env`. Il est utilisé par le [daemon Meshtastic](../admin/meshtastic-daemon.md) et par le script `wiki-generate.sh`. Il est disponible pour d'autres applications Python si nécessaire.

Les binaires sont disponibles dans le répertoire `/data/recoverybox_env/bin`. Ils peuvent être utilisés pour exécuter des scripts Python ou pour installer des paquets supplémentaires dans l'environnement virtuel sans avoir à l'activer.

### Activer l'environnement virtuel

```bash
source /data/recoverybox_env/bin/activate
```

### Désactiver l'environnement virtuel

```bash
deactivate
```