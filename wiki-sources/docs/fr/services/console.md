---
title: Console
description: Console web d'administration basée sur ShellInABox, accessible via le navigateur.
tags:
  - service
  - administration
---

# Console

## Présentation

La console web d'administration utilise **[ShellInABox](https://github.com/shellinabox/shellinabox)**, un serveur web open-source qui émule un terminal VT100 directement dans un navigateur via AJAX/JavaScript. Cela permet d'accéder à un shell en ligne de commande sans aucun plugin client.

Dans la RecoveryBox, ShellInABox est déployé en tant que **service systemd** derrière un reverse proxy Apache2.

## Accès au service

La console est accessible à tous les utilisateurs connectés au hotspot de la RecoveryBox.

| URL                                                | Description              |
| -------------------------------------------------- | ------------------------ |
| [http://console.recovery.box](http://console.recovery.box) | Console web d'administration |

!!! info "Identifiants par défaut"
    | Champ       | Valeur      |
    | ----------- | ----------- |
    | Utilisateur | `recuser`   |
    | Mot de passe | `Recovery`  |

## Configuration avancée

### A. Fichiers de configuration

| Élément | Description |
| --- | --- |
| `/etc/default/shellinabox` | Fichier de configuration de ShellInABox |
| `/etc/apache2/sites-available/console.conf` | Configuration Apache2 du reverse proxy |
| `/var/log/apache2/console_access.log` | Logs d'accès Apache |
| `/var/log/apache2/console_error.log` | Logs d'erreur Apache |

### B. Customisation

#### Modification de la configuration ShellInABox

ShellInABox peut être customisé via son fichier de configuration `/etc/default/shellinabox`.

#### Activation du HTTPS

Il est possible de passer la console en HTTPS en modifiant le fichier `/etc/default/shellinabox` et en remplaçant la dernière ligne par :

```bash
SHELLINABOX_ARGS="--no-beep"
```

L'activation du HTTPS nécessite l'utilisation d'un certificat. Dans le fichier de conf Apache2 `/etc/apache2/sites-available/console.conf`, ajoutez :

```apache
SSLEngine on
SSLCertificateFile    /etc/ssl/certs/console.recovery.box.crt
SSLCertificateKeyFile /etc/ssl/private/console.recovery.box.key
```

### C. Debug

```bash
# Consulter les logs d'accès
cat /var/log/apache2/console_access.log

# Consulter les logs d'erreur
cat /var/log/apache2/console_error.log
```
