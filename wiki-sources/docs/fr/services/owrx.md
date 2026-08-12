---
title: OpenWebRX Plus
description: Récepteur radio SDR accessible via le navigateur, avec décodeurs numériques et analogiques intégrés.
tags:
  - service
  - radio
---

# OpenWebRX Plus

## Présentation

**OpenWebRX** est un récepteur radio défini par logiciel (SDR) open-source accessible via un navigateur web. Il permet à plusieurs utilisateurs de se connecter simultanément pour écouter, analyser et démoduler des signaux radio (I/Q) en direct à l'aide d'un dongle SDR (comme un RTL-SDR) connecté à la RecoveryBox.

Pour plus de détails sur le projet d'origine, consultez la **[documentation officielle d'OpenWebRX](https://www.openwebrx.de)**.

### Version Plus

La RecoveryBox intègre la version **OpenWebRX Plus** (OpenWebRX+), un fork amélioré du projet initial. Cette version ajoute des fonctionnalités critiques pour la gestion de crise et l'autonomie, notamment des décodeurs intégrés pour les modes numériques et analogiques (DMR, P25, D-Star, NXDN, APRS, POCSAG/Pager, SSTV, météo FAX, LORA, Meshtastic, Meshcore), ainsi qu'une meilleure gestion des cartes et du balayage des fréquences.

Pour consulter les spécificités de cette version, visitez le **[dépôt officiel OpenWebRX Plus](https://github.com/luarvique/openwebrx-plus)**.

## Accès au service

L'interface de réception radio est accessible à tous les utilisateurs connectés au hotspot de la RecoveryBox.

| URL                                                  | Description                    |
| ---------------------------------------------------- | ------------------------------ |
| [http://recovery.box:8073/](http://recovery.box:8073/) | Interface web OpenWebRX Plus   |

!!! info "Identifiants d'administration"
    | Champ       | Valeur        |
    | ----------- | ------------- |
    | Utilisateur | `recoverybox` |
    | Mot de passe | `recoverybox` |

L'administration d'OpenWebRX Plus se fait principalement via son interface web.

!!! warning "Démarrage du service"
    Le service OpenWebRX Plus ne démarre que si une clé SDR compatible est détectée sur le système. Si aucun périphérique SDR n'est présent, le service restera stoppé.
    Si la clé est connectée après le démarrage de la RecoveryBox, le service démarrera automatiquement.

!!! info "Compatibilité matérielle"
    L'intégration actuelle d'OpenWebRX Plus est compatible avec les périphériques SDR suivants :
    - RTL-SDR
    - Airspy
    - HackRF
    - LimeSDR
    - SDRplay
    - FunCube
    - PlutoSDR

## Configuration avancée

### A. Fichiers de configuration

| Élément | Description |
| --- | --- |
| `/etc/systemd/system/openwebrx.service` | Unit systemd du service OpenWebRX |
| `/etc/owrx/` | Répertoire de configuration d'OpenWebRX |
| `/etc/owrx/custom-leaflet.js` | Configuration personnalisée de la carte (montée en lecture seule dans le conteneur) |

### B. Customisation

#### Modification du compte d'administration

Il est possible de modifier l'utilisateur et le mot de passe d'administration d'OpenWebRX Plus en modifiant les variables suivantes dans le service systemd :

```bash
OPENWEBRX_ADMIN_USER=recoverybox
OPENWEBRX_ADMIN_PASSWORD=recoverybox
```

#### Configuration de la carte

Le conteneur est démarré avec l'option de montage suivante :

```text
-v /etc/owrx/custom-leaflet.js:/usr/lib/python3/dist-packages/htdocs/map-leaflet.js:ro
```

Cela surcharge le fichier de configuration gérant les cartes afin de pointer vers le serveur local.

### C. Debug

```bash
# Consulter les logs d'OpenWebRX
journalctl -u openwebrx.service -f
```
