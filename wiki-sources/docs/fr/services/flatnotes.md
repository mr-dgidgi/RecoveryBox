---
title: Flatnotes
description: Service de prise de notes accessible via le navigateur.
tags:
  - service
  - notes
---

# Flatnotes

## Présentation

[Flatnotes](https://github.com/dullage/flatnotes) est une application web de prise de notes qui permet aux utilisateurs de créer, modifier et organiser leurs notes directement depuis un navigateur.

Dans la RecoveryBox, Flatnotes est déployé en tant que **service systemd** derrière un reverse proxy Apache2.

3 installations sont proposées pour Flatnotes dans la RecoveryBox :
- **Open** : Flatnotes est accessible à tous les utilisateurs connectés au hotspot de la RecoveryBox, sans authentification.
- **Secure** : Flatnotes est accessible à tous les utilisateurs connectés au hotspot de la RecoveryBox, mais nécessite une authentification avec un nom d'utilisateur et un mot de passe.
- **Full** : Flatnotes est accessible en lecture à tous les utilisateurs connectés au hotspot de la RecoveryBox. Une seconde instance de Flatnotes est accessible en écriture uniquement aux utilisateurs authentifiés avec un nom d'utilisateur et un mot de passe.

## Accès au service

Flatnotes est accessible à tous les utilisateurs connectés au hotspot de la RecoveryBox.

| URL                                                | Description              |
| -------------------------------------------------- | ------------------------ |
| [http://flatnotes.recovery.box](http://flatnotes.recovery.box) | Interface web de prise de notes |
| [http://flatnotes-ro.recovery.box](http://flatnotes-ro.recovery.box) | Interface web en lecture seule (installation **Full**) |

!!! info "Identifiants par défaut"
    | Champ       | Valeur      |
    | ----------- | ----------- |
    | Utilisateur | `recadmin`   |
    | Mot de passe | `RecoveryAdmin`  |

## Configuration avancée

### A. Emplacement des fichiers

Tous les fichiers se trouvent dans le répertoire `/data/flatnotes`. Ils sont au format markdown et peuvent donc être facilement édités, lus ou transférés.

### B. Customisation

Lors de l'installation de la RecoveryBox, il est possible de choisir le type d'installation de Flatnotes (Open, Secure ou Full) et de définir les identifiants pour l'accès sécurisé.

Les variables de configuration sont stockées dans le fichier `/etc/recoverybox/custom_config.yml` et peuvent être modifiées manuellement si nécessaire.
Variables de configuration :

```yaml
recoverybox_flatnotes_open: "full" # open, secure, full
recoverybox_flatnotes_secure:
  username: "recadmin"
  password: "RecoveryAdmin"
  secret_key: "aLongRandomSeriesOfCharacters123"
```

!!! info "Sécurité"
    Il est recommandé de modifier le mot de passe par défaut pour l'accès sécurisé à Flatnotes.

La clé secrète (`secret_key`) est utilisée pour sécuriser les sessions et doit être une chaîne de caractères aléatoire et complexe de 32 caractères.

!!! warning "Sécurité"
    En modifiant la secret_key, toutes les sessions existantes seront invalidées et les utilisateurs devront se reconnecter.

### C. Debug

#### Apache2
```bash
# Consulter les logs d'accès
cat /var/log/apache2/flatnotes_access.log

# Consulter les logs d'erreur
cat /var/log/apache2/flatnotes_error.log
```

#### Service
```bash
# Consulter les logs du service Flatnotes
journalctl -u flatnotes.service
journalctl -u flatnotes-ro.service

# Vérifier l'état des conteneurs Flatnotes
docker ps -a | grep flatnotes
```
