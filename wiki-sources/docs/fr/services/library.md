---
title: Librairie
description: Collection de documents PDF de survie et d'autonomie, servie en local via le hotspot RecoveryBox.
tags:
  - service
  - ressources-hors-ligne
---

# Librairie

## Présentation

La **Librairie** est un serveur web hébergeant une collection de documents PDF liés à la survie, à l'autonomie et aux techniques de vie en plein air. Le contenu provient du dépôt Git [rb-library](https://github.com/mr-dgidgi/rb-library) et est servi localement via un VirtualHost Apache2, accessible à tous les utilisateurs connectés au hotspot de la RecoveryBox.
L'interface comporte une interface d'administration permettant de gérer les documents PDF, d'ajouter des fichiers personnalisés et de mettre à jour la librairie. Celle-ci fonctionne de manière optimale en combinaison avec le service filebrowser.

!!! info "Architecture"
    Contrairement à la plupart des autres services de la RecoveryBox, la Librairie n'est **pas** conteneurisée via Docker. Il s'agit d'un VirtualHost Apache2 natif servant des fichiers statiques clonés depuis un dépôt Git.

### Caractéristiques

| Propriété          | Valeur                                    |
| ------------------ | ----------------------------------------- |
| **Type**           | Serveur web statique (Apache2)            |
| **Contenu**        | Documents PDF de survie et d'autonomie    |
| **Source**         | [mr-dgidgi/rb-library](https://github.com/mr-dgidgi/rb-library) |
| **Variable d'activation** | `recoverybox_enable_library`      |


---

## Accès au service

Les documents PDF sont accessibles à tous les utilisateurs connectés au hotspot de la RecoveryBox.

| URL                                      | Description                          |
| ---------------------------------------- | ------------------------------------ |
| [http://library.recovery.box](http://library.recovery.box) | Accès direct à la librairie          |
| [http://recovery.box](http://recovery.box) | Page d'accueil RecoveryBox (lien vers la librairie) |
| [http://library.recovery.box/admin.html](http://library.recovery.box/admin.html) | Interface d'administration de la librairie |

Le compte d'administration se base sur l'utilisateur par défaut de la RecoveryBox :

| Nom d'utilisateur | Mot de passe par défaut |
| ---------------- | ---------------------- |
| recuser            | Recovery                  |

!!! note "Accès réseau"
    Le service est accessible uniquement depuis le réseau local du hotspot RecoveryBox. La résolution DNS `library.recovery.box` est assurée par le serveur DNS local de la RecoveryBox.

---

## Configuration avancée

### A. Fichiers de configuration

Le service repose sur un unique fichier de configuration Apache2 :

| Fichier                                                    | Description                        |
| ---------------------------------------------------------- | ---------------------------------- |
| `/etc/apache2/sites-available/library.conf`                | VirtualHost Apache2 de la librairie |

Ce fichier inclut le snippet Apache spécifique à la librairie situé dans :
`/data/library/backend/apache-vhost-snippet.conf`

### B. Customisation

#### Ajouter des PDF personnalisés

##### a. En interface web

L'ajout des fichiers peut se faire via [filebrowser](filebrowser.md). Le dossier *library* correspond au répertoire `/data/library/PDF/custom/` sur la machine.

Suite à l'ajout des fichiers, il faut se rendre dans l'interface d'administration de la librairie pour que les changements soient pris en compte. La connexion se fait avec les identifiants de l'utilisateur primaire de la machine (par défaut `recuser`). La page propose un tableau contenant tous les nouveaux fichiers détectés et permet de les classifier en spécifiant les différents tags (category, language, type).

L'interface d'administration permet aussi de créer de nouvelles catégories, langues et types pour organiser les PDF personnalisés. L'option est disponible dans chacun des menus déroulants dédiés aux tags.

!!! info "filebrowser"
    La page d'administration propose un accès direct à l'interface filebrowser si celui-ci est activé sur la machine.

##### b. En CLI

Un répertoire dédié est disponible pour ajouter vos propres documents PDF sans modifier le contenu du dépôt upstream :

```bash
# Ajouter un PDF personnalisé
cp mon-document.pdf /data/library/PDF/custom/

# Vérifier la présence
ls -la /data/library/PDF/custom/
```

!!! warning "Persistence"
    Les fichiers ajoutés dans `/data/library/PDF/custom/` sont persistants. En revanche, ils seront **écrasés** lors d'une mise à jour du dépôt `rb-library` si ceux-ci se trouvent dans un autre dossier parent. Utilisez toujours le sous-répertoire `PDF/custom/` pour vos ajouts.

Il faut ensuite exécuter le script Python `library-update.py` pour mettre à jour le fichier `custom-library.json` de la librairie et inclure vos nouveaux documents :

```bash
# Exécuter le script de mise à jour
python3 /data/library/library-update.py
```
!!! info "Terminal"
    Les commandes peuvent être exécutées directement dans le terminal de Cockpit.


Un redémarrage du service Apache via `services-manager` est nécessaire pour que les changements soient pris en compte.

!!! info "filebrowser"
    Il est également possible d'ajouter des PDF personnalisés via l'interface web de filebrowser en déposant les fichiers dans le répertoire **library**. Il est tout de même nécessaire d'exécuter le script `library-update.py` pour que les nouveaux fichiers soient pris en compte.


#### Activer / Désactiver le service


Le service peut être désactivé complètement de la machine en exécutant le script d'installation `install.sh` et en choisissant une installation *custom* ou via la variable Ansible directement dans `/etc/recoverybox/custom_config.yml` :

```yaml
# Dans votre custom_config.yml
recoverybox_enable_library: false
```
!!! note "install.sh"
    Si d'autres modifications manuelles ont été effectuées dans `custom_config.yml`, il est recommandé de continuer à modifier le fichier manuellement. En cas de recréation du fichier via le script d'installation, vos modifications seront écrasées.

!!! warning "Dépendance Apache2"
    La Librairie nécessite qu'Apache2 soit activé (`recoverybox_enable_apache: true`). Si Apache2 est désactivé, la Librairie est automatiquement désactivée également.

### C. Debug

#### Logs

| Log           | Chemin                                      |
| ------------- | ------------------------------------------- |
| Erreurs       | `/var/log/apache2/library.error.log`        |
| Accès         | `/var/log/apache2/library.access.log`       |

#### Vérification du service

```bash
# Vérifier que le VirtualHost est activé
apache2ctl -S | grep library

# Consulter les logs en temps réel
tail -f /var/log/apache2/library.access.log
tail -f /var/log/apache2/library.error.log
```

#### Structure des fichiers

```
/data/library/                          # DocumentRoot (cloné depuis rb-library)
├── backend/                            # Contient le code backend permettant de gérer la librairie
│   └── admin-config.json               # Variables de l'interface d'administration
│   └── apache-vhost-snippet.conf       # Fragment de configuration Apache pour le VirtualHost de la librairie
├── PDF/
│   └── custom/                         # PDFs ajoutés par l'utilisateur
├── index.html                          # Page d'accueil de la librairie
└── ...                                 # Autres documents PDF
```
