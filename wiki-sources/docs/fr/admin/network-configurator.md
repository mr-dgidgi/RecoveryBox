---
title: network-configurator
description: Outil de configuration réseau interactif pour systemd-networkd, gérant bridges, interfaces et firewall.
tags:
  - outil
  - réseau
---

# Network Configurator

## Présentation

`network-configurator` est un outil de configuration réseau destiné aux systèmes Linux utilisant **systemd-networkd**. Il permet de créer et modifier la configuration réseau de manière interactive ou via des commandes en ligne.

L'objectif principal est de simplifier le déploiement et la maintenance des RecoveryBox en automatisant la génération des fichiers de configuration réseau sans manipulation manuelle.

Les fonctionnalités principales sont :

- configuration d'interfaces réseau physiques ou virtuelles ;
- création de bridges ;
- association d'interfaces physiques à un bridge ;
- renommage persistant des interfaces réseau à partir de leur adresse MAC ;
- configuration des interfaces Wi-Fi en mode client ;
- ajout automatique des interfaces WAN dans la configuration du firewall ;
- affichage de l'état des interfaces et de la configuration courante.

L'outil fonctionne aussi bien via un menu interactif qu'en mode non interactif afin d'être intégré dans des scripts d'installation ou d'automatisation.

---

## Fonctionnement

Le script repose sur **systemd-networkd** et génère automatiquement les fichiers de configuration dans `/etc/systemd/network`.

L'organisation des fichiers suit la convention de priorité de systemd :

| Préfixe | Type |
|----------|------|
| `10-*.link` | renommage des interfaces |
| `20-*.netdev` | création des interfaces virtuelles (bridges) |
| `30-*.network` | configuration réseau des interfaces |

Les modifications réalisées par le configurateur ne sont appliquées qu'après un redémarrage de **systemd-networkd** (ou du système dans le cas des fichiers `.link`).

Le script possède deux modes de fonctionnement :

---

## Guide d'utilisation

### Mode interactif

Sans argument, un menu permet :

- consulter l'état des interfaces ;
- afficher la configuration actuelle ;
- configurer une interface ;
- configurer une interface Wi-Fi ;
- créer les associations bridge ↔ interfaces ;
- renommer les interfaces physiques.

Les différentes étapes guident l'utilisateur et réalisent les vérifications nécessaires avant l'écriture des fichiers.

### Mode ligne de commande

Le script peut être exécuté sans passer par l'interface interactive. Chaque action est disponible sous la forme d'une commande, ce qui permet son utilisation dans des scripts d'installation ou d'automatisation (Ansible, AWX, scripts de post-installation, etc.).

#### Syntaxe générale

```bash
network-configurator <commande> [arguments]
```

---

#### CreateBridge

Crée une interface virtuelle de type **bridge**.

**Syntaxe**

```bash
network-configurator CreateBridge <bridge>
```

**Arguments**

| Argument | Description |
|----------|-------------|
| `<bridge>` | Nom du bridge à créer. |

**Exemple**

```bash
network-configurator CreateBridge Lan
```

---

#### GetPhysicalInterfaces

Affiche toutes les interfaces réseau physiques détectées ainsi que leur état.

**Syntaxe**

```bash
network-configurator GetPhysicalInterfaces
```

Aucun argument n'est attendu.

---

#### GetVInterfacesConfig

Affiche la configuration réseau générée.

**Syntaxe**

```bash
network-configurator GetVInterfacesConfig [interface]
```

**Arguments**

| Argument | Description |
|----------|-------------|
| `interface` | *(optionnel)* Nom de l'interface à afficher. Si absent, toutes les configurations sont affichées. |

**Exemples**

```bash
network-configurator GetVInterfacesConfig
```

```bash
network-configurator GetVInterfacesConfig Wan
```

---

#### RenameInterface

Renomme une interface réseau de manière persistante à partir de son adresse MAC.

**Syntaxe**

```bash
network-configurator RenameInterface <adresse-mac> <nouveau-nom>
```

**Arguments**

| Argument | Description |
|----------|-------------|
| `<adresse-mac>` | Adresse MAC de l'interface. |
| `<nouveau-nom>` | Nouveau nom à attribuer. |

**Exemple**

```bash
network-configurator RenameInterface 00:11:22:33:44:55 Wan
```

---

#### LinkInterface

Ouvre le menu interactif permettant de rattacher ou de détacher des interfaces physiques aux bridges existants.

**Syntaxe**

```bash
network-configurator LinkInterface
```

Aucun argument.

---

#### SetInterface

Crée ou modifie directement la configuration d'une interface.

**Syntaxe**

```bash
network-configurator SetInterface \
    <interface> \
    <dhcp> \
    <adresse> \
    <gateway> \
    <dns> \
    <network-options> \
    <dhcpv4-options> \
    <ipv6acceptra-options>
```

**Arguments**

| Argument | Description |
|----------|-------------|
| `<interface>` | Nom de l'interface à configurer. |
| `<dhcp>` | `yes` ou `no`. |
| `<adresse>` | Adresse IP avec masque (`192.168.1.10/24`). Ignorée si DHCP=`yes`. |
| `<gateway>` | Passerelle par défaut. |
| `<dns>` | Liste des serveurs DNS séparés par des espaces. Utiliser `no` pour ne pas écrire de directive DNS. |
| `<network-options>` | Options supplémentaires de la section `[Network]`. Utiliser `no` si aucune. |
| `<dhcpv4-options>` | Contenu de la section `[DHCPv4]`. Utiliser `no` si aucune. |
| `<ipv6acceptra-options>` | Contenu de la section `[IPv6AcceptRA]`. Utiliser `no` si aucune. |

**Exemple DHCP**

```bash
network-configurator SetInterface Wan yes "" "" "1.1.1.1 9.9.9.9" no no no
```

**Exemple IP statique**

```bash
network-configurator SetInterface \
    Lan \
    no \
    192.168.10.1/24 \
    192.168.10.254 \
    "1.1.1.1 9.9.9.9" \
    no \
    no \
    no
```

---

#### MenuSetInterface

Lance le menu interactif de configuration d'une interface.

**Syntaxe**

```bash
network-configurator MenuSetInterface <interface>
```

**Arguments**

| Argument | Description |
|----------|-------------|
| `<interface>` | Interface à configurer. |

---

#### MenuRenameInterface

Lance le menu interactif de renommage des interfaces.

**Syntaxe**

```bash
network-configurator MenuRenameInterface [nom]
```

Si un nom est fourni, celui-ci est proposé automatiquement comme nouveau nom.

---

#### MenuSetVlan

Configure une interface Wi-Fi en mode client.

**Syntaxe**

```bash
network-configurator MenuSetVlan
```

L'assistant demande ensuite :

- le SSID ;
- le mot de passe ;
- puis configure automatiquement `wpa_supplicant`.

---

#### ApplyChanges

Propose le redémarrage de `systemd-networkd` afin d'appliquer les modifications.

**Syntaxe**

```bash
network-configurator ApplyChanges
```

---

#### status

Affiche l'état actuel :

- des bridges ;
- des interfaces physiques ;
- des interfaces associées aux bridges.

**Syntaxe**

```bash
network-configurator status
```

---

#### help

Affiche l'aide intégrée.

**Syntaxe**

```bash
network-configurator help
```

---

## Fichiers de configuration

Le configurateur modifie plusieurs fichiers système.

### Configuration systemd-networkd

Tous les fichiers sont créés dans :

```text
/etc/systemd/network/
```

### Interfaces renommées

```text
10-<interface>.link
```

Contient :

- l'adresse MAC de l'interface ;
- le nouveau nom attribué.

Exemple :

```ini
[Match]
MACAddress=00:11:22:33:44:55

[Link]
Name=Wan
```

---

### Bridges

```text
20-<bridge>.netdev
```

Déclare les interfaces virtuelles de type bridge.

---

### Configuration réseau

```text
30-<interface>.network
```

Décrit :

- DHCP ou IP statique ;
- DNS ;
- passerelle ;
- options avancées systemd-networkd ;
- rattachement éventuel à un bridge.

---

### Configuration Wi-Fi

Les interfaces Wi-Fi utilisent :

```text
/etc/wpa_supplicant/wpa_supplicant-<interface>.conf
```

Le configurateur ajoute automatiquement les réseaux sélectionnés via `wpa_cli`.

---

### Configuration du firewall

Lorsque l'utilisateur indique qu'une interface est une interface WAN, le script modifie automatiquement :

```text
/etc/iptables/iptables.sh
```

afin d'ajouter cette interface à la variable `WAN`.

Le service `iptables` est ensuite redémarré.

---

### Sauvegardes

Avant toute modification, le configurateur crée automatiquement une sauvegarde des fichiers existants :

```text
<fichier>.bak
```

Ces sauvegardes permettent une restauration manuelle en cas de problème.

---

## Debug

Plusieurs commandes permettent de vérifier le fonctionnement du configurateur.

### Vérifier les interfaces

```bash
network-configurator status
```

Affiche :

- les bridges ;
- les interfaces physiques ;
- les interfaces reliées à chaque bridge.

---

### Vérifier la configuration générée

```bash
network-configurator GetVInterfacesConfig
```

ou

```bash
cat /etc/systemd/network/*.network
```

---

### Vérifier la prise en compte par systemd-networkd

```bash
systemctl status systemd-networkd
```


---

### Recharger la configuration

Le configurateur peut redémarrer automatiquement `systemd-networkd`, mais il est également possible de le faire manuellement :

```bash
systemctl restart systemd-networkd
```

---

### Vérifier le renommage des interfaces

Les fichiers `.link` sont pris en compte par systemd-networkd.

---

### Vérifier la configuration Wi-Fi

```bash
wpa_cli -i <interface> status
```

ou

```bash
systemctl status wpa_supplicant@<interface>
```

---

### Vérifier la configuration du firewall

Après ajout d'une interface WAN :

```bash
grep WAN= /etc/iptables/iptables.sh
```

puis :

```bash
systemctl status iptables
```

afin de confirmer que la configuration a bien été rechargée.

---

### Journaux utiles

En cas de problème, les journaux suivants sont particulièrement utiles :

```bash
journalctl -u systemd-networkd
```

```bash
journalctl -u wpa_supplicant@<interface>
```

```bash
journalctl -u iptables
```

Ils permettent de diagnostiquer les erreurs de configuration ou d'application des paramètres réseau.