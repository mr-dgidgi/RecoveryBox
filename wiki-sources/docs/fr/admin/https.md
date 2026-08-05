---
title: HTTPS
description: Options de configuration HTTPS pour la RecoveryBox
tags:
  - outil
  - installation
  - service
  - security
---

# HTTPS

## Présentation

Il est possible d'activer la navigation via HTTPS sur la RecoveryBox. Cela permet de sécuriser les échanges entre le navigateur et le serveur web, en chiffrant les données transmises.

Le HTTPS utilise un *certificat SSL/TLS* pour établir une connexion sécurisée. Ce certificat doit être approuvé par une autorité externe (CA) et être renouvelé régulièrement afin d'être considéré comme valide par les navigateurs web. Le principe même de la RecoveryBox devant fonctionner hors réseau empêche le renouvellement automatique du *certificat SSL/TLS*. La RecoveryBox utilise donc un certificat auto-signé pour le HTTPS. Cela permet d'activer le HTTPS mais les navigateurs web afficheront un avertissement de sécurité indiquant que le certificat n'est pas approuvé par une autorité externe. Il ne sera affiché que lors de la première connexion au serveur web.

!!! warning "Avertissement"
    Le message d'erreur à la première connexion aux services de la RecoveryBox est normal et **ne doit pas** être considéré comme un problème de sécurité.

Lorsque le HTTPS est activé, toutes les connexions en HTTP sont automatiquement redirigées vers le HTTPS.

!!! note "Meshtastic"
    Les équipements LoRa à base de puce ESP32 ne supportent pas le HTTPS. Afin de garder une compatibilité avec ces équipements, le HTTPS est toujours désactivé sur ce service.

## Activation du HTTPS

Le HTTPS est activé lors de l'installation/mise à jour via la [variable Ansible](ansible-variables.md) `recoverybox_enable_https`. Il est possible de l'activer ou de le désactiver à tout moment en modifiant cette variable dans `/etc/recoverybox/custom_config.yml` et en relançant le script d'installation.

## Customisation du certificat SSL/TLS

Il est possible de mettre en place son propre certificat SSL/TLS pour le HTTPS. Pour cela, il faut placer les fichiers du certificat et de la clé privée dans le répertoire `/etc/ssl/recoverybox/` avec les noms `recoverybox.crt` et `recoverybox.key`.

