---
title: Librairie
description: Collection de documents PDF de survie et d'autonomie, servie en local via le hotspot RecoveryBox.
tags:
  - service
  - ressources-hors-ligne
---

# Librairie

## Présentation

La **Librairie** est un serveur web statique hébergeant une collection de documents PDF liés à la survie, à l'autonomie et aux techniques de vie en plein air. Le contenu provient du dépôt Git [rb-library](https://github.com/mr-dgidgi/rb-library) et est servi localement via un VirtualHost Apache2, accessible à tous les utilisateurs connectés au hotspot de la RecoveryBox.

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

!!! note "Accès réseau"
    Le service est accessible uniquement depuis le réseau local du hotspot RecoveryBox. Le résolution DNS `library.recovery.box` est assurée par le serveur DNS local de la RecoveryBox.

---

## Configuration avancée

### A. Fichiers de configuration

Le service repose sur un unique fichier de configuration Apache2 :

| Fichier                                                    | Description                        |
| ---------------------------------------------------------- | ---------------------------------- |
| `/etc/apache2/sites-available/library.conf`                | VirtualHost Apache2 de la librairie |

**Contenu du VirtualHost :**

```apache
<VirtualHost *:80>
    ServerName library.recovery.box
    DocumentRoot /data/library

    <Location />
        Require all granted
    </Location>

    ErrorLog ${APACHE_LOG_DIR}/library.error.log
    CustomLog ${APACHE_LOG_DIR}/library.access.log combined
</VirtualHost>
```

!!! info "Variables Ansible"
    Le VirtualHost est déployé depuis le fichier source Ansible situé à :
    `ansible/roles/recoverybox/files/etc/apache2/sites-available/library.conf`

### B. Customisation

#### Ajouter des PDF personnalisés

Un répertoire dédié est disponible pour ajouter vos propres documents PDF sans modifier le contenu du dépôt upstream :

```bash
# Ajouter un PDF personnalisé
cp mon-document.pdf /data/library/PDF/custom/

# Vérifier la présence
ls -la /data/library/PDF/custom/
```

!!! warning "Persistence"
    Les fichiers ajoutés dans `/data/library/PDF/custom/` sont persistants tant que la partition `/data` est montée. En revanche, ils seront **écrasés** lors d'une mise à jour du dépôt `rb-library` si ceux-ci se trouvent à la racine du DocumentRoot. Utilisez toujours le sous-répertoire `PDF/custom/` pour vos ajouts.

Il faut ensuite exécuter le script python `library-update.py` pour mettre à jour le fichier `custom-library.json` de la librairie et inclure vos nouveaux documents :

```bash
# Exécuter le script de mise à jour
python3 /data/library/library-update.py
```

Un redémarrage du service apacheé via `services-manager` est nécessaire pour que les changements soient pris en compte.

#### Activer / Désactiver le service


Le service peut être désactivé complètement de la machine en exécutant le script d'installation `install.sh` et en choisissant une installation *custom* ou via la variable Ansible directement dans `/etc/recoverybox/custom_config.yml` :

```yaml
# Dans votre custom_config.yml
recoverybox_enable_library: false
```
!!! note "install.sh"
    Si d'autres modifications manuelles ont été effectuées dans `custom_config.yml` il est recommandé de continuer à modifier le fichier manuellement. En cas de recréation du fichier via le script d'installation, vos modifications seront écrasées.

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

# Vérifier que le contenu est disponible
curl -I -H "Host: library.recovery.box" http://127.0.0.1/

# Consulter les logs en temps réel
tail -f /var/log/apache2/library.access.log
```

#### Structure des fichiers

```
/data/library/                          # DocumentRoot (cloné depuis rb-library)
├── PDF/
│   └── custom/                         # PDFs ajoutés par l'utilisateur
├── index.html                          # Page d'accueil de la librairie
└── ...                                 # Autres documents PDF
```
