---
title: rb-battery - Gestion de la batterie via MPPT Victron
description: Documentation de l'utilitaire rb-battery pour la surveillance et la protection de la batterie sur RecoveryBox
tags:
  - outil
  - administration
  - batterie
  - victron
---

# rb-battery - Gestion de la batterie via MPPT Victron

## Présentation

`rb-battery` est un utilitaire en ligne de commande conçu pour la RecoveryBox afin de surveiller l'état de la batterie via un contrôleur de charge MPPT Victron connecté en VE.Direct. Il lit les données brutes du périphérique `/dev/victron-mppt`, les formate en JSON et surveille la tension de la batterie pour déclencher un arrêt propre du système en cas de tension critique.

L'outil est compatible avec les contrôleurs Victron suivants :
- BlueSolar / SmartSolar MPPT 75/10
- BlueSolar / SmartSolar MPPT 75/15
- BlueSolar / SmartSolar MPPT 100/15

!!! info "Architecture"
    Le script est déployé via Ansible dans `/usr/local/bin/rb-battery.sh` et exécuté périodiquement via une tâche cron.
    La détection automatique du périphérique MPPT est gérée par le service **find-victron** (voir section dédiée).

## Service find-victron - Détection automatique du MPPT

Le service `find-victron` (systemd) assure la découverte automatique du contrôleur MPPT Victron au démarrage et en runtime. Il crée le lien symbolique `/dev/victron-mppt` requis par `rb-battery.sh`.

### Commandes utiles

```bash
# Statut du service
systemctl status find-victron

# Logs en temps réel
journalctl -u find-victron -f

# Vérifier le lien créé
ls -l /dev/victron-mppt
```

### Intégration avec rb-battery

`rb-battery.sh` attend le device `/dev/victron-mppt`. Si le MPPT n'est pas détecté au moment où la cron s'exécute :
- `rb-battery.sh` affiche `No data received from VE.Direct device`
- `find-victron` continue de scanner en arrière-plan
- Dès détection, le lien est créé et la prochaine exécution de la cron (max 1 min) fonctionnera normalement

!!! tip "Branchement à chaud"
    Si vous branchez le MPPT après le démarrage de la RecoveryBox, soit attendez la prochaine boucle de `find-victron` (max 5 min), soit lancez `systemctl restart find-victron` pour forcer la détection immédiate.

## Guide d'utilisation

### Exécution manuelle (lecture unique)

Pour afficher l'état actuel de la batterie et du MPPT :

```bash
rb-battery.sh
```

Sortie exemple :
```text
#########################################################
#################### Battery Status #####################
#########################################################
 =+= Firmware Version                       : 166 
 =+= Serial Number                          : HQ2544JW64Q 
 =+= Battery Voltage                        : 14.19 V
 =+= Battery Current                        : 0.58 A
 =+= Panel Voltage                          : 19.28 V
 =+= Panel Power                            : 9 W
 =+= Charge State                           : 4
 =+= MPPT Channel                           : 1
 =+= Off-Reason                             : 0x00000000
 =+= Error Code                             : 0
 =+= Load Output state                      : ON
 =+= Load Output Current                    : 0 
 =+= Maximum Power Today                    : 147 W
#########################################################
 =+= Error / Warning : 
 =+= None
```

### Mode surveillance (watch)

Le mode `watch` est utilisé par la cron pour surveiller en continu la tension de la batterie :

```bash
rb-battery.sh watch
```

Ce mode :
1. Lit les données du MPPT
2. Vérifie si la tension batterie est inférieure au seuil critique (12.0V par défaut pour LiFePO4)
3. Si critique : attend 10 secondes et réessaie (jusqu'à 3 tentatives)
4. Après 3 échecs consécutifs : déclenche `low_battery_shutdown` (arrêt système)

## Tâche Cron

La surveillance automatique est configurée via une entrée cron dans `/etc/cron.d/rb-battery` :

```cron
* * * * * root /usr/local/bin/rb-battery.sh watch
```

**Explication :**
- Exécution **toutes les minutes** (`* * * * *`)
- En tant que **root** (nécessaire pour l'arrêt système)
- Lance le script en mode `watch`

!!! note "Fréquence"
    L'exécution minutée permet une réactivité rapide en cas de chute de tension, tout en limitant la charge système (lecture série courte + traitement JSON).

## Informations fournies (JSON de sortie)

Le script génère un fichier JSON `/data/www/vedirect.json` contenant toutes les métriques lues. Structure :

```json
{
    "Values": [
        { "id": "FW", "name": "Firmware Version", "value": 166, "unit": "" },
        { "id": "SERIAL", "name": "Serial Number", "value": "HQ2544JW64Q", "unit": "" },
        { "id": "V", "name": "Battery Voltage", "value": 14190, "unit": "mV" },
        { "id": "I", "name": "Battery Current", "value": 580, "unit": "mA" },
        { "id": "VPV", "name": "Panel Voltage", "value": 19280, "unit": "mV" },
        { "id": "PPV", "name": "Panel Power", "value": 9, "unit": "W" },
        { "id": "CS", "name": "Charge State", "value": 4, "unit": "" },
        { "id": "MPPT", "name": "MPPT Channel", "value": 1, "unit": "" },
        { "id": "OR", "name": "Off-Reason", "value": "0x00000000", "unit": "" },
        { "id": "ERR", "name": "Error Code", "value": 0, "unit": "" },
        { "id": "LOAD", "name": "Load Output state", "value": "ON", "unit": "" },
        { "id": "IL", "name": "Load Output Current", "value": 0, "unit": "" },
        { "id": "H21", "name": "Maximum Power Today", "value": 147, "unit": "W" }
    ],
    "Timestamp": 1722945600,
    "ErrorMessage": ""
}
```

### Détail des champs

| ID | Nom | Unité | Description |
|----|-----|-------|-------------|
| `FW` | Firmware Version | - | Version du firmware du MPPT |
| `SERIAL` | Serial Number | - | Numéro de série du périphérique |
| `V` | Battery Voltage | mV | Tension batterie (millivolts) |
| `I` | Battery Current | mA | Courant batterie (milliampères) |
| `VPV` | Panel Voltage | mV | Tension panneau solaire (millivolts) |
| `PPV` | Panel Power | W | Puissance panneau (watts) |
| `CS` | Charge State | - | État de charge : `0=Off`, `2=Fault`, `3=Bulk`, `4=Absorption`, `5=Float` |
| `MPPT` | MPPT Channel | - | État MPPT : `0=Off`, `1=Limited`, `2=Active` |
| `OR` | Off-Reason | - | Raison d'arrêt (hexadécimal) |
| `ERR` | Error Code | - | Code d'erreur (voir tableau ci-dessous) |
| `LOAD` | Load Output state | - | État sortie charge : `ON` / `OFF` |
| `IL` | Load Output Current | mA | Courant sortie charge (milliampères) |
| `H21` | Maximum Power Today | W | Puissance max aujourd'hui |

### Codes d'erreur Victron (champ `ERR`)

| Code | Signification |
|------|---------------|
| `0` | Aucune erreur |
| `2` | Tension batterie trop élevée |
| `17` | Température chargeur trop élevée |
| `18` | Surintensité chargeur |
| `19` | Courant chargeur inversé |
| `20` | Limite de temps Bulk dépassée |
| `21` | Problème capteur de courant |
| `26` | Bornes surchauffées |
| `28` | Problème convertisseur |
| `33` | Tension entrée PV trop élevée |
| `34` | Surintensité entrée PV |
| `38` | Arrêt entrée PV (surtension) |
| `116` | Données calibration usine perdues |
| `117` | Firmware invalide/incompatible |
| `119` | Données de réglages perdues |

## Seuils de tension (LiFePO4)

Le script utilise deux seuils fixes définis en tête de script :

| Seuil | Valeur | Action |
|-------|--------|--------|
| `VOLTAGE_WARNING` | 12.4 V (12400 mV) | Avertissement affiché (jaune) |
| `VOLTAGE_CRITICAL` | 12.0 V (12000 mV) | Déclenchement tentative d'arrêt (rouge) |

!!! tip "Personnalisation"
    Pour adapter les seuils à une autre chimie de batterie (ex: plomb), modifier les variables `VOLTAGE_WARNING` et `VOLTAGE_CRITICAL` dans `/usr/local/bin/rb-battery.sh`.

## Fichiers concernés

| Fichier | Rôle |
|---------|------|
| `/usr/local/bin/rb-battery.sh` | Script principal (géré par Ansible) |
| `/etc/cron.d/rb-battery` | Planification cron (géré par Ansible) |
| `/data/www/vedirect.json` | Fichier de sortie JSON (temporaire) |
| `/dev/victron-mppt` | Périphérique série VE.Direct (symlink udev) |

## Dépannage basique

| Problème | Cause probable | Solution |
|----------|----------------|----------|
| `No data received from VE.Direct device` | MPPT non connecté / mauvais device | Vérifier `/dev/victron-mppt` et câblage USB/VE.Direct |
| Tension affichée à 0 | Communication série HS | Redémarrer le MPPT, vérifier le port série |
| `Error Code` non nul | Voir tableau codes d'erreur | Consulter la doc Victron pour le code correspondant |
| Cron ne s'exécute pas | Service cron arrêté | `systemctl status cron` / `systemctl restart cron` |
