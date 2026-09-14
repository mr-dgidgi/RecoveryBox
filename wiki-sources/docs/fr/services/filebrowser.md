---
title: Filebrowser
description: Service de gestion de fichiers accessible via le navigateur.
tags:
  - service
  - notes
---

# Filebrowser

## Présentation

Filebrowser est un service de gestion de fichiers qui permet aux utilisateurs de naviguer, télécharger, téléverser et organiser des fichiers via une interface web intuitive. Il est particulièrement utile pour gérer les fichiers stockés sur la RecoveryBox sans avoir besoin d'un accès via SSH ou FTP.


## Accès au service

Filebrowser est accessible à tous les utilisateurs connectés au hotspot de la RecoveryBox.

| URL                                                | Description              |
| -------------------------------------------------- | ------------------------ |
| [http://filebrowser.recovery.box](http://filebrowser.recovery.box) | Interface web de gestion de fichiers |

!!! info "Identifiants par défaut"
    | Champ       | Valeur      |
    | ----------- | ----------- |
    | Utilisateur | `admin`   |
    | Mot de passe | `RecAdmin1234`  |

## Configuration avancée

### A. Emplacement des fichiers

Les fichiers de configuration se trouvent dans `/data/filebrowser`

| Chemin | Description |
| ------- | ----------- |
| `/data/filebrowser/database/filebrowser.db` | base de donnée sqlite |
| `/data/filebrowser/config/settings.json` | fichier de configuration de Filebrowser |
| `/data/filebrowser/custom` | contient les fichiers pour customiser l'interface |
| `/data/filebrowser/files/` | Dossier de base pour les fichiers gérés par Filebrowser |


### B. Customisation

L'ensemble de la configuration se fait via l'interface web avec l'utilisateur `admin` par défaut.

!!! info "mot de passe par défaut"
    Il est fortement recommandé de changer le mot de passe par défaut de l'utilisateur admin.


### C. Debug

#### Apache2
```bash
# Consulter les logs d'accès
cat /var/log/apache2/filebrowser_access.log

# Consulter les logs d'erreur
cat /var/log/apache2/filebrowser_error.log
```

#### Service
```bash
# Consulter les logs du service Filebrowser
journalctl -u filebrowser.service

# Vérifier l'état des conteneurs Filebrowser
docker ps -a | grep filebrowser
```
