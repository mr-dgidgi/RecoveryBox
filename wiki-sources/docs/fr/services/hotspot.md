---
title: Hotspot Wi-Fi
description: Point d'accès Wi-Fi autonome basé sur simple-hotspot, hostapd et dnsmasq.
tags:
  - service
  - réseau
---

# Hotspot Wi-Fi

## Présentation

La RecoveryBox intègre un point d'accès Wi-Fi permettant aux utilisateurs de se connecter directement à la machine sans infrastructure réseau externe.

Le point d'accès est entièrement conteneurisé et s'appuie sur le projet **[simple-hotspot](https://github.com/mr-dgidgi/Simple-Hotspot)**, exécuté dans un conteneur Docker. Ce conteneur regroupe les différents services nécessaires au fonctionnement d'un point d'accès autonome :

- **hostapd** pour la création du réseau Wi-Fi ;
- **dnsmasq** pour le serveur DHCP et DNS ;
- le routage assuré par le système hôte via systemd-networkd et IPtables.

Le service est démarré automatiquement au lancement de la RecoveryBox. Les utilisateurs accèdent à l'ensemble des services simplement en se connectant au réseau Wi-Fi.

### Fonctionnement

#### Interface Wi-Fi

Lors de l'installation, une interface Wi-Fi est renommée automatiquement en `wlanAP`. Cette interface est exclusivement réservée au point d'accès. Le service `wpa_supplicant` est désactivé sur cette interface afin qu'elle puisse être utilisée en mode Access Point par hostapd.

#### Bridge réseau

L'interface `wlanAP` est automatiquement rattachée au bridge réseau **Lan**. Ainsi, tous les clients Wi-Fi se retrouvent sur le même réseau que les éventuels équipements connectés au bridge LAN. Le bridge est créé par `network-configurator` pendant l'installation.

#### Attribution des adresses IP

Les adresses IP sont distribuées automatiquement par **dnsmasq**. Les clients reçoivent une adresse IP, la passerelle et les serveurs DNS. Aucune configuration manuelle n'est nécessaire côté client.

#### Accès Internet

Lorsque l'interface **Wan** dispose d'une connexion Internet, le service IPtables met automatiquement en place le NAT afin de partager cette connexion avec les clients Wi-Fi. Le fonctionnement est alors similaire à celui d'un routeur domestique.

## Accès au service

Le réseau Wi-Fi du hotspot est disponible immédiatement au démarrage de la RecoveryBox.

| Réseau | Description |
| --- | --- |
| `recoverybox` (par défaut) | Réseau Wi-Fi du point d'accès |

## Configuration avancée

### A. Fichiers de configuration

| Élément | Description |
| --- | --- |
| `/etc/ap_config/hostapd.conf` | Configuration du point d'accès (SSID, canal, mot de passe WPA2) |
| `/etc/ap_config/dnsmasq.conf` | Configuration du serveur DHCP/DNS |
| `/etc/ap_config/ap_start.sh` | Script de démarrage exécuté avant le lancement du conteneur Docker |

### B. Customisation

#### Modification du réseau Wi-Fi

!!! warning "configuration centralisée"
    Les fichiers de configuration du hotspot Wi-Fi sont gérés par le script `RecoveryBox_install.sh`. Toute modification manuelle de ces fichiers sera écrasée lors d'une mise à jour ou d'une réinstallation. Pour personnaliser le hotspot, il est recommandé d'utiliser les variables `recoverybox_hotspot_conf` dans le fichier `/etc/recoverybox/custom_config.yml`.

Le fichier `/etc/ap_config/hostapd.conf` permet de modifier :

- le nom du réseau (SSID) ;
- le canal Wi-Fi ;
- la bande utilisée (2,4 GHz ou 5 GHz selon le matériel) ;
- le mot de passe WPA2 ;
- le pays (`country_code`) ;
- les performances radio.

Lors du lancement du service, le script `ap_start.sh` fusionne le fichier `hostapd_base.conf` avec un second fichier `hostapd_extra.conf`. Ce dernier est destiné à contenir des options supplémentaires non gérées par Ansible. Il est possible de créer ce fichier pour ajouter des options avancées à hostapd.

#### Modification du serveur DHCP

Le fichier `/etc/ap_config/dnsmasq.conf` permet de modifier :

- la plage d'adresses IP distribuées ;
- les serveurs DNS ;
- la durée des baux DHCP ;
- différentes options DHCP.

Toute modification non gérée par Ansible sera écrasée en cas de réinstallation. Pour personnaliser le serveur DHCP, en ajoutant des options non gérées par Ansible, il est nécessaire de créer un second fichier de configuration dans le répertoire `/etc/ap_config/dnsmasq.d/`. Ce fichier sera automatiquement inclus par dnsmasq.

!!! info "Redémarrage requis"
    Toute modification de la configuration nécessite le redémarrage du service via le `service-manager`.

#### Modification via le custom_config.yml

Voici un exemple de configuration pour personnaliser le hotspot Wi-Fi dans le fichier `/etc/recoverybox/custom_config.yml` :

```yaml
recoverybox_hotspot_conf:
  ssid: "recoverybox" # Hostapd
  password: "my_password" # Hostapd
  mode: "g" # Hostapd - 2.4GHz : g ou b (legacy), 5GHz/6GHz : a, acs si pris en charge par la carte
  channel: "11" # Hostapd - 2.4GHz : 1/7/11, 5GHz : 36-165, 6GHz : 1-233, 0 ou acs si pris en charge par la carte
  auth_algs: "1" # Hostapd
  wpa: "2" # Hostapd
  wpa_key_mgmt: "WPA-PSK" # Hostapd
  wpa_pairwise: "TKIP CCMP" # Hostapd
  rsn_pairwise: "CCMP" # Hostapd
  network: "192.168.4.0" # DNSmasq
  mask: "24" # DNSmasq
  ip: "192.168.4.1" # DNSmasq
  dhcp_range_start: "192.168.4.100" # DNSmasq
  dhcp_range_end: "192.168.4.200" # DNSmasq
```
#### Point d'accès 5 GHz

!!! warning "Point d'accès 5/6 GHz"
    Les cartes Wi-Fi Intel équipées de la fonction LAR (Location Aware Regulatory) sont incapable d'être activées sur les bandes 5 GHz et 6 GHz en tant que point d'accès.

Le hotspot Wi-Fi peut fonctionner sur les bandes 2,4 GHz, 5 GHz et 6 GHz selon le matériel. Cependant, certaines cartes Wi-Fi peuvent ne pas supporter toutes les bandes. N'ayant pas encore trouvé de solution fiable et universelle pour activer le point d'accès sur les bandes 5 GHz et 6 GHz, il est recommandé de rester sur la bande 2,4 GHz pour garantir la compatibilité avec tous les matériels.

Cependant, su vous souhaite tester d'activer hotspot en 5 / 6 GHz, en plus de selectionner le mode et le canal dans le fichier `custom_config.yml`, il est nécessaire de créer un fichier `hostapd_extra.conf` dans le répertoire `/etc/ap_config/` avec les options suivantes :


```conf
country_code= # FR for france, US for United States, etc.
driver=nl80211
ieee80211d=1
ieee80211h=1
ieee80211n=1           # Recommandé pour débloquer le 5GHz N
ieee80211ac=1          # Recommandé pour le 5GHz AC
```

Une modification du fichier `ap_start.sh` est également nécessaire pour activer le mode 5 GHz. Cette modification sera **écrasée* lors d'une mise à jour ou d'une réinstallation. Ces lignes sont à ajouter juste avant `docker rm -f hotspot 2>/dev/null`

```bash
iw reg set FR
iw dev wlanAP scan > /dev/null 2>&1 || true
sleep 1
```

### C. Debug

```bash
# Consulter les logs du hotspot
journalctl -u ap.service -f
```
