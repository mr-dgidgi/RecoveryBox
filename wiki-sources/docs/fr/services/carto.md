---
title: Cartographie
description: Service de cartographie locale basé sur Brouter et TileServer-GL avec génération de cartes via generate-map.
tags:
  - service
  - cartographie
---

# Cartographie

## Présentation

Le service de cartographie de la RecoveryBox est basé sur **Brouter** et **TileServer-GL**. Il fournit une interface web de consultation cartographique fonctionnant entièrement hors-ligne.

- **[Brouter](https://github.com/abrensch/brouter)** est un moteur de calcul d'itinéraire open-source, principalement conçu pour le vélo et la randonnée. Il intègre le calcul d'élévation et permet l'import, la génération et l'export de fichiers GPX.
- **[TileServer-GL](https://tileserver.readthedocs.io/en/latest/)** est un serveur de cartographie open-source qui diffuse des cartes vectorielles et matricielles (rasters) à partir de fichiers `.mbtiles`. Il s'appuie sur MapLibre/Mapbox GL pour le rendu des tuiles.

La carte locale est générée à la volée et intègre la zone choisie en haute définition sur une carte du monde en basse résolution.

!!! info "utilisation externe"
    Le tileserver peut être utilisé par d'autres applications ou services, pour afficher des cartes sans accès à internet. L'URL à utiliser est : [http://map.recovery.box/tiles/styles/liberty/{z}/{x}/{y}.png](http://map.recovery.box/tiles/styles/liberty/{z}/{x}/{y}.png)

## Accès au service

L'interface de cartographie est accessible à tous les utilisateurs connectés au hotspot de la RecoveryBox.

| URL                                            | Description                  |
| ---------------------------------------------- | ---------------------------- |
| [http://map.recovery.box](http://map.recovery.box) | Accès à l'interface cartographie |

## Configuration avancée

### A. Fichiers de configuration

| Élément | Description |
| --- | --- |
| `/data/tileserver/map.mbtiles` | Fichier principal de la carte |
| `/var/log/apache2/carto_access.log` | Logs d'accès Apache du service carto |
| `/var/log/apache2/carto_error.log` | Logs d'erreur Apache du service carto |

### B. Customisation

#### Ajout d'une zone supplémentaire via `generate-map`

L'outil `generate-map` permet de télécharger et d'intégrer de nouvelles zones cartographiques en haute définition. Il récupère les données OpenStreetMap depuis [geofabrik.de](https://download.geofabrik.de) et propose 4 niveaux de zoom : 6, 10, 12, 14.

Le script génère les tuiles automatiquement puis fusionne les nouvelles données avec celles déjà existantes. Cette opération peut prendre un temps variable selon la taille des cartes et la puissance de la machine.

!!! info "Documentation dédiée"
    Pour plus de détails sur l'utilisation de `generate-map` (procédure complète, niveaux de zoom, debug), consultez la fiche dédiée : [**generate-map**](../admin/generate-map.md)

#### Ajout de son propre fichier `.mbtiles`

Si vous possédez déjà votre fichier `.mbtiles`, celui-ci peut être installé à l'emplacement suivant :

```text
/data/tileserver/map.mbtiles
```

!!! warning "Nom du fichier"
    Le fichier doit impérativement être nommé `map.mbtiles`.

Redémarrez ensuite le service via le `service-manager` pour charger la nouvelle carte.

### C. Debug

```bash
# Consulter les logs d'accès
cat /var/log/apache2/carto_access.log

# Consulter les logs d'erreur
cat /var/log/apache2/carto_error.log
```
