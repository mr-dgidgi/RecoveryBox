---
title: MkDocs
description: Wiki technique de la RecoveryBox basé sur MkDocs Material, servant la documentation en ligne et hors-ligne.
tags:
  - service
  - documentation
---

# MkDocs

## Présentation

**[MkDocs](https://www.mkdocs.org)** est un générateur de sites statiques conçu pour la documentation technique. La RecoveryBox utilise la version **[MkDocs Material](https://squidfunk.github.io/mkdocs-material/)**, un thème riche en fonctionnalités (recherche, navigation par onglets, mode sombre, etc.).

Le site wiki est accessible à tous les utilisateurs connectés au hotspot et contient la documentation de l'ensemble des services, outils et procédures de la RecoveryBox.

Pour plus de détails sur le projet, consultez la **[documentation officielle de MkDocs](https://www.mkdocs.org)** et le **[dépôt GitHub de MkDocs Material](https://github.com/squidfunk/mkdocs-material)**.

### Caractéristiques

| Propriété | Valeur |
| --- | --- |
| **Type** | Conteneur Docker (service systemd) |
| **Image** | `squidfunk/mkdocs-material` |
| **Port** | `18001` (hôte) → `8080` (conteneur) |
| **Volume** | `/data/wiki` (hôte) → `/docs` (conteneur) |
| **Variable d'activation** | `recoverybox_enable_mkdocs` |

## Accès au service

Le wiki est accessible à tous les utilisateurs connectés au hotspot de la RecoveryBox.

| URL | Description |
| --- | --- |
| [http://wiki.recovery.box](http://wiki.recovery.box) | Wiki RecoveryBox |

!!! note "Multilangue"
    Le wiki est disponible en français et en anglais. Un sélecteur de langue est disponible dans l'interface.

## Configuration avancée

### A. Fichiers de configuration

| Élément | Description |
| --- | --- |
| `/data/wiki/mkdocs.yml` | Fichier de configuration MkDocs (site, thème, navigation) |
| `/data/wiki/docs/` | Répertoire contenant tous les fichiers Markdown du wiki |

Le fichier `mkdocs.yml` définit le nom du site, l'URL, le thème Material (palette slate, navigation par onglets) et les alternatives de langue.

### B. Customisation

#### Ajouter ou modifier des pages

Le contenu du wiki réside dans `/data/wiki/docs/`. La structure est la suivante :

```text
docs/
├── fr/           ← documentation française
├── en/           ← documentation anglaise
└── images/       ← ressources graphiques partagées
```

Pour ajouter une page, créez un fichier `.md` dans le répertoire approprié (`fr/` ou `en/`) puis ajoutez-le dans la section `nav` de `mkdocs.yml` si nécessaire.

!!! info "Rechargement à chaud"
    MkDocs Material en mode développement recharge automatiquement les modifications. En production (conteneur Docker), un redémarrage du service via le `service-manager` est nécessaire pour prendre en compte les changements de structure.

#### Personnalisation du thème

Le thème MkDocs Material peut être personnalisé via le fichier `/data/wiki/mkdocs.yml`. Paramètres principaux :

```yaml
theme:
  name: material
  features:
    - navigation.tabs
  palette:
    scheme: slate
```

Consultez la **[documentation du thème Material](https://squidfunk.github.io/mkdocs-material/)** pour les options avancées (recherche, icônes, extensions, etc.).

### C. Debug

```bash
# Consulter les logs du service
journalctl -u mkdocs.service -f

# Vérifier que le conteneur est en cours d'exécution
docker ps | grep mkdocs
```
