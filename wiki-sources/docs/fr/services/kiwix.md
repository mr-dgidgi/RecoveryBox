---
title: Kiwix
description: Serveur de consultation hors-ligne de Wikipédia et autres ressources via des fichiers ZIM.
tags:
  - service
  - ressources-hors-ligne
---

# Kiwix

## Présentation

**Kiwix** est un logiciel libre permettant de consulter des sites web hors-ligne. Il fonctionne en lisant des fichiers de données compressés au format standard `.zim`. Kiwix intègre son propre serveur HTTP léger (`kiwix-serve`) pour distribuer ces contenus sur un réseau local sans aucun accès Internet.

Dans la RecoveryBox, Kiwix est déployé en tant que **conteneur Docker** géré par un service systemd. Il fournit une interface web de consultation de Wikipédia (et d'autres contenus) accessible depuis n'importe quel appareil connecté au hotspot.

Pour plus de détails sur le projet, consultez la **[documentation officielle de Kiwix](https://wiki.kiwix.org)** et le **[dépôt GitHub](https://github.com/kiwix/kiwix-serve)**.

### Caractéristiques

| Propriété              | Valeur                                    |
| ---------------------- | ----------------------------------------- |
| **Type**               | Conteneur Docker (service systemd)        |
| **Image**              | `ghcr.io/kiwix/kiwix-serve`              |
| **Port**               | `8080`                                    |
| **Volume**             | `/data/kiwix` (hôte) → `/data` (conteneur) |
| **Variable d'activation** | `recoverybox_enable_kiwix`           |
---

## Accès au service

L'interface de consultation Kiwix est accessible à tous les utilisateurs connectés au hotspot de la RecoveryBox.

| URL                                      | Description                          |
| ---------------------------------------- | ------------------------------------ |
| [http://kiwix.recovery.box](http://kiwix.recovery.box) | Accès direct à Kiwix                |
| [http://recovery.box](http://recovery.box) | Page d'accueil RecoveryBox (lien vers Kiwix) |

!!! note "Accès réseau"
    Le service est accessible uniquement depuis le réseau local du hotspot RecoveryBox. Le résolution DNS `kiwix.recovery.box` est assurée par le serveur DNS local (dnsmasq) via l'entrée wildcard `*.recovery.box`.

---

## Contenus inclus par défaut

La RecoveryBox embarque par défaut une copie de **Wikipédia** en français et en anglais au format `.zim`. Trois variantes de taille sont disponibles pour chaque langue :

| Variante      | Description                                      |
| ------------- | ------------------------------------------------ |
| `all_mini`    | Version la plus compacte (qualité réduite)        |
| `all_no_pic`  | Texte sans images (**variante par défaut**)       |
| `all_maxi`    | Version complète avec images                      |

!!! info "Espace disque"
    Les fichiers ZIM de Wikipédia complet peuvent peser plusieurs gigaoctets. La variante `all_no_pic` (texte sans image) est privilégiée par défaut pour limiter l'occupation disque.

---

## Configuration avancée

### A. Fichiers de configuration

| Élément                                                  | Description                            |
| -------------------------------------------------------- | -------------------------------------- |
| `/etc/systemd/system/kiwix.service`                      | Unit systemd du conteneur Docker       |
| `/data/kiwix/`                                           | Répertoire contenant les fichiers `.zim` |

### B. Customisation

#### Ajouter des fichiers ZIM manuellement

Vous pouvez ajouter de nouveaux fichiers `.zim` pour enrichir les contenus disponibles (autres langues de Wikipédia, Wiktionnaire, Wikimed, Vikidia, etc.).

**Procédure :**

1. Téléchargez le fichier `.zim` de votre choix depuis la [bibliothèque officielle Kiwix](https://browse.library.kiwix.org/).
2. Transférez le fichier sur la RecoveryBox (via SCP, USB, etc.) et placez-le dans le répertoire `/data/kiwix/` :
   ```bash
   scp mon-fichier.zim root@<ip-recoverybox>:/data/kiwix/
   ```
3. Redémarrez le service Kiwix pour prendre en compte le nouveau fichier via le `service-manager` 

!!! warning "Redémarrage requis"
    Kiwix ne détecte pas automatiquement les nouveaux fichiers ZIM ajoutés. Un redémarrage du service est **obligatoire** pour que le contenu soit servi.

#### Ajouter des fichiers ZIM via `custom_config.yml`

Lors de l'installation/mise à jour via `install.sh`, en éditant directement `/etc/recoverybox/custom_config.yml`, vous pouvez configurer le téléchargement automatique de fichiers ZIM depuis le site officiel de Kiwix.

**Structure de la variable `recoverybox_kiwix_files` :**

```yaml
recoverybox_kiwix_files:
  - category: wikipedia      # Catégorie (wikipedia, maps, etc.)
    language: french          # Langue du contenu
    enable: true              # Activer le téléchargement
    arg: "all_no_pic"         # Variante : all_mini, all_no_pic, all_maxi
  - category: wikipedia
    language: english
    enable: true
    arg: "all_no_pic"
```

**Exemple avec des cartes :**

```yaml
recoverybox_kiwix_files:
  - category: wikipedia
    language: french
    enable: true
    arg: "all_no_pic"
  - category: wikipedia
    language: english
    enable: true
    arg: "all_no_pic"
  - category: maps
    language: english
    enable: true
    arg: "croatia"
```

!!! info "Source de téléchargement"
    Les fichiers sont téléchargés depuis `https://lb.download.kiwix.org/zim/`. Le script Ansible récupère automatiquement la dernière version mensuelle disponible correspondant au pattern configuré.

Pour appliquer la configuration après modification il faut relancer le script `install.sh`.

### C. Debug

#### Logs

```bash
# Consulter les logs du service
journalctl -u kiwix.service

# Consulter les logs en temps réel
journalctl -u kiwix.service -f
```

#### Vérification du service

```bash
# Vérifier l'état global des services
rbstatus

# Tester l'accès HTTP
curl -I http://localhost:8080/
```
