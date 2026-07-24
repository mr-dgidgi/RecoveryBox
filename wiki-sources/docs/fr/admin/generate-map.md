---
title: generate-map
description: Outil de génération de cartes vectorielles MBTiles à partir des données OpenStreetMap.
tags:
  - outil
  - cartographie
---

# Generate Map

`generate-map` est un outil permettant de générer des cartes vectorielles au format **MBTiles** à partir des données **OpenStreetMap** fournies par **Geofabrik**.

Le script s'appuie sur **Planetiler** exécuté dans un conteneur Docker afin de produire des cartes optimisées pouvant être directement utilisées par **TileServer GL**.

L'objectif est de permettre la génération ou la mise à jour des cartes embarquées dans une Recovery Box sans intervention manuelle.

Les principales fonctionnalités sont :

- téléchargement automatique des données OpenStreetMap ;
- génération des fichiers `.mbtiles` via Planetiler ;
- choix de la zone géographique (continent ou pays) ;
- choix du niveau de détail de la carte (zoom maximal) ;
- fusion automatique avec une carte existante ;
- redémarrage optionnel du serveur de tuiles.

Le script est entièrement interactif et guide l'utilisateur tout au long de la génération.

---

## Fonctionnement

Le script automatise l'ensemble de la chaîne de génération des cartes.

### 1. Sélection de la zone

L'utilisateur choisit si la carte doit être générée pour :

- un continent complet ;
- un pays.

Les données sont ensuite téléchargées automatiquement depuis le dépôt **[Geofabrik](https://download.geofabrik.de/)** sous forme de fichier `.osm.pbf`.

---

### 2. Sélection du niveau de détail

Le script propose quatre niveaux de zoom correspondant au niveau maximal généré par Planetiler.

| Niveau | Zoom | Utilisation |
|---------|------|-------------|
| Overview | 6 | Vue globale, très faible encombrement |
| Tactical | 10 | Réseau routier et navigation |
| Operational | 12 | Détails urbains |
| High Precision | 14 | Bâtiments et détails complets |

Plus le niveau de zoom est élevé, plus :

- le temps de génération augmente ;
- la consommation mémoire augmente ;
- la taille finale du fichier MBTiles est importante.

Le niveau **14** peut produire un fichier plusieurs dizaines de fois plus volumineux qu'un niveau **6**.

---

### 3. Génération de la carte

Une fois les données téléchargées, Planetiler est exécuté dans un conteneur Docker.

La quantité de mémoire Java allouée est calculée automatiquement en fonction de la mémoire disponible sur la machine.

Le fichier généré est produit au format :

```text
<zone>.mbtiles
```

---

### 4. Fusion des cartes

Si aucune carte n'existe encore sur la Recovery Box :

```text
map.mbtiles
```

est créé directement.

Si une carte est déjà présente, le script fusionne automatiquement les deux fichiers à l'aide de **tile-join**.

Cette opération permet d'ajouter une nouvelle zone géographique sans régénérer les cartes existantes.

En cas d'échec de la fusion, un mécanisme de rollback restaure automatiquement la carte précédente.

---

### 5. Redémarrage du Tile Server

Une fois la génération terminée, le script propose de redémarrer automatiquement le service :

```text
tileserver-gl.service
```

afin que la nouvelle carte soit immédiatement disponible.

---

## Interactions avec les fichiers

Le script utilise plusieurs répertoires de travail.

### Répertoire de travail Planetiler

```text
/data/planetiler
```

Contient temporairement :

- les fichiers `.osm.pbf` téléchargés ;
- les fichiers temporaires de Planetiler ;
- les fichiers MBTiles avant leur installation.

Ce répertoire est automatiquement nettoyé à la fin de l'exécution.

---

### Répertoire du Tile Server

```text
/data/tileserver
```

Contient les cartes utilisées par TileServer GL.

Le fichier principal est :

```text
map.mbtiles
```

Lors d'une fusion, un fichier temporaire est créé :

```text
world.mbtiles
```

qui est supprimé après la fusion.

---

### Téléchargement des données

Les données OpenStreetMap proviennent automatiquement de :

```text
https://download.geofabrik.de/
```

Le script télécharge la dernière version disponible de la zone sélectionnée au format :

```text
<zone>-latest.osm.pbf
```

---

### Conteneur Docker

La génération est réalisée via l'image Docker officielle :

```text
ghcr.io/onthegomap/planetiler:latest
```

Le répertoire de travail est monté dans le conteneur afin de récupérer directement les fichiers générés.

---

## Debug

Plusieurs vérifications permettent de diagnostiquer un problème lors de la génération.

### Vérifier le téléchargement

S'assurer que le fichier PBF a bien été téléchargé :

```bash
ls -lh /data/planetiler/*.osm.pbf
```

---

### Vérifier Docker

Le script nécessite Docker et l'image Planetiler.

```bash
docker images
```

```bash
docker run --rm ghcr.io/onthegomap/planetiler:latest --help
```

---

### Vérifier l'espace disque

Les cartes haute résolution peuvent nécessiter plusieurs dizaines de gigaoctets.

```bash
df -h
```

---

### Vérifier la mémoire disponible

Planetiler utilise une grande quantité de mémoire vive.

```bash
free -h
```

Le script adapte automatiquement la mémoire Java disponible à partir de la mémoire physique détectée.

---

### Vérifier les cartes générées

Lister les cartes présentes :

```bash
ls -lh /data/tileserver
```

La carte active doit être :

```text
map.mbtiles
```

---

### Vérifier le service TileServer

Après la génération :

```bash
systemctl status tileserver-gl.service
```

ou

```bash
journalctl -u tileserver-gl.service
```

permettent de vérifier que le serveur a correctement chargé la nouvelle carte.

---

### Nettoyage automatique

À la fin de l'exécution (même en cas d'erreur), le script supprime automatiquement :

- les fichiers temporaires Planetiler ;
- les fichiers PBF téléchargés ;
- les sources intermédiaires ;
- les fichiers de pondération générés.

Cela permet de limiter l'espace disque utilisé après chaque génération.
### Outils

Le script utilise le **[container planetiler](https://github.com/onthegomap/planetiler)** pour générer le fichier `.mbtiles` à partir du `.pbf`

Afin de fusionner les cartes, le script utilise tile-join de **[tippecanoe](https://github.com/mapbox/tippecanoe)**