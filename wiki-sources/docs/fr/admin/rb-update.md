---
title: rb-update
description: Script de mise à jour automatisée de la RecoveryBox via GitHub.
tags:
  - outil
  - mise-à-jour
---

# rb-update

## Présentation

`rb-update` est un script utilitaire qui automatise la mise à jour de la **RecoveryBox** en vérifiant la dernière version disponible sur GitHub, en la téléchargeant et en relançant le script d'installation.

Il est installé par Ansible sous `/usr/local/bin/rb-update.sh`.

!!! warning "Exécution en root"
    Le script **doit être exécuté en root** (`sudo rb-update.sh`). Il ne vérifie pas l'UID explicitement mais les opérations `apt`, `git` et l'appel à `RecoveryBox_install.sh` nécessitent les privilèges root.

!!! warning "Redémarrage possible"
    Selon les mises à jour appliquées (noyau, systemd-networkd, Docker, etc.), un **redémarrage peut être nécessaire** à l'issue de la mise à jour.

---

## Modes d'exécution

| Mode | Commande | Description |
|------|----------|-------------|
| **Mise à jour majeure (défaut)** | `sudo rb-update.sh` | Vérifie la dernière *release* GitHub (tag `latest`) |
| **Mise à jour mineure** | `sudo rb-update.sh --minor` | Vérifie le dernier tag de la branche `1.x`. Permet d'obtenir les derniers patchs |
| **Mise à jour complète système + RB** | `sudo rb-update.sh --full` | Met à jour les paquets Debian (`apt upgrade`) **puis** RecoveryBox |
| **Mineure + complète** | `sudo rb-update.sh --minor --full` | Combine `--minor` et `--full` |

!!! note "Note"
    Les options `--minor` et `--full` sont cumulatives et peuvent être combinées dans n'importe quel ordre.

---

## Guide d'utilisation

### Mise à jour standard (version majeure)

```bash
sudo rb-update.sh
```

1. Le script lit la version actuelle dans `/etc/recoverybox/rb_version`
2. Interroge l'API GitHub pour récupérer le dernier tag `latest`
3. Si une nouvelle version est disponible, demande confirmation (`Y/N`)
4. Télécharge le code source (git fetch/reset/checkout ou clone si absent)
5. Lance `RecoveryBox_install.sh` (mode interactif ou `custom` selon la présence de `/etc/recoverybox/custom_config.yml`)

### Mise à jour mineure (correctifs 1.x)

```bash
sudo rb-update.sh --minor
```

Identique au mode standard mais cible le dernier tag `1.x` au lieu du `latest`. Utile pour rester sur une branche stable.

### Mise à jour complète (système + RecoveryBox)

```bash
sudo rb-update.sh --full
```

Ajoute une étape `apt-get update && apt-get upgrade -y` **avant** la mise à jour RecoveryBox. Recommandé pour appliquer les correctifs de sécurité Debian.

---

## Fonctionnement détaillé

### 1. Vérification de version (`Check_Update`)

- Lit `/etc/recoverybox/rb_version` (version installée)
- Requête GitHub API :
  - Mode `major` (défaut) : `GET /repos/mr-dgidgi/recoverybox/releases/latest`
  - Mode `minor` : `GET /repos/mr-dgidgi/recoverybox/tags` → filtre tag `1.` le plus récent
- Compare les versions (chaîne de caractères)
- Affiche la version actuelle et la version disponible

### 2. Téléchargement (`Download_Update`)

- Répertoire cible : `/root/RecoveryBox`
- Si le dossier existe : `git fetch --all && git reset --hard && git checkout <tag>`
- Sinon : `git clone --depth 1 --branch <tag> https://github.com/mr-dgidgi/recoverybox.git /root/RecoveryBox`

### 3. Mise à jour système optionnelle (`Update_System`)

- Si `--full` : `apt-get update -y && apt-get upgrade -y`
- Échoue si `apt` retourne une erreur (sortie du script)

### 4. Application de la mise à jour (`Update_RecoveryBox`)

- Exécute `bash /root/RecoveryBox/RecoveryBox_install.sh`
- Le script d'installation détecte `/etc/recoverybox/rb_version` existant et ajoute le suffixe `-upgrading`
- Relance le playbook Ansible avec la configuration existante ou interactive

---

## Dépannage courant

| Symptôme | Cause probable | Résolution |
|----------|----------------|------------|
| `Current Recovery Box version: 0.0.0` | Fichier `rb_version` absent ou vide | Réinstaller ou créer le fichier manuellement |
| `curl` retourne vide / timeout | Pas d'accès Internet / API GitHub bloquée | Vérifier connexion, DNS, pare-feu |
| `git checkout` échoue | Tag inexistant / repo corrompu | Supprimer `/root/RecoveryBox` et relancer |
| `apt-get upgrade` échoue (mode `--full`) | Conflit paquets / verrou dpkg | `dpkg --configure -a && apt --fix-broken install` puis relancer |
| `RecoveryBox_install.sh` non trouvé | Clone raté / mauvais tag | Vérifier `/root/RecoveryBox`, supprimer et relancer |
| Le script ne propose pas de mise à jour | Version déjà à jour | Comportement normal, rien à faire |
| Échec dans le playbook Ansible | Erreur Docker, réseau, config | Voir documentation **[Debug](debug.md)** ou **[RecoveryBox_install.sh](RecoveryBox_install.md)** |

---

## Fichiers concernés

| Fichier | Rôle |
|---------|------|
| `/usr/local/bin/rb-update.sh` | Script principal (géré par Ansible) |
| `/etc/recoverybox/rb_version` | Version installée (écrit par `RecoveryBox_install.sh`) |
| `/etc/recoverybox/custom_config.yml` | Configuration utilisateur (rejouée à la mise à jour) |
| `/root/RecoveryBox/` | Clone Git du dépôt (source de mise à jour) |
