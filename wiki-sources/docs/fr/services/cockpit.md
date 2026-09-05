---
title: Cockpit
description: Console web d'administration basée sur Cockpit, accessible via le navigateur.
tags:
  - service
  - administration
---

# Cockpit

## Présentation

Cockpit est une console d'administration web conçue pour simplifier la gestion des machines de manière graphique. Elle offre une interface utilisateur-friendly pour surveiller l'état du système, gérer les services et configurer divers aspects du système. Une console est aussi accessible sur on interface dans le menu outils.

!!! note "premier accès"
    Au premier accès, une erreur de certificat peut apparaître car Cockpit utilise un certificat HTTPS autosigné. Les utilisateurs doivent accepter le risque ou ajouter une exception dans leur navigateur.

## Accès au service

- **URL** : `https://cockpit.recovery.box`
- **Utilisateur / Mot de passe** : Les mêmes identifiants que pour la connexion à la machine.
- **Certificat** : Le certificat est autosigné ; il est nécessaire d'accepter l'avertissement du navigateur pour accéder à l'interface.

Il est possible de gérer des services depuis cette interface web, ce qui permet de démarrer, arrêter ou redémarrer les services sans avoir à utiliser la ligne de commande. Tous les services de la machine peuvent être administrés de cette manière. Il est donc **fortement déconseillé** d'utiliser cette fonctionnalité sans une **bonne compréhension** des services et de leurs dépendances. Nous recommandons l'utilisation de la commande `services-manager` qui ne gère que les services purement lié à la solution RecoveryBox.

Lors de la connexion à l'interface Cockpit, l'utilisateur est en **mode restreint**. Il est donc nécessaire de passer en mode **Administrateur** pour accéder à toutes les fonctionnalités.

## Configuration avancée

### A. Fichiers de configuration

Cockpit utilise sa configuration de base. Aucun fichier de configuration custom n'a été créé.
On peut trouver son certificat autosigné dans le dossier `/etc/cockpit/ws-certs.d/`.

### B. Débogage

#### Service
```bash
# Consulter les logs du service Cockpit
journalctl -u cockpit.service
```

### Logs Apache

Les logs du proxy web Apache, utilisé par Cockpit, sont disponibles dans le répertoire `/var/log/apache2/`.
```bash
less +G /var/log/apache2/cockpit_error.log
less +G /var/log/apache2/cockpit_access.log
```