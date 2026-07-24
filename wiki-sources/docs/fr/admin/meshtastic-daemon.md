---
title: meshtastic-daemon
description: Daemon collectant les positions des nœuds Meshtastic et les affichant sur la carte BRouter.
tags:
  - outil
  - meshtastic
  - cartographie
---

# Meshtastic Daemon

## Présentation

`meshtastic-daemon` est un script Python qui se connecte à un nœud Meshtastic via TCP, récupère les informations de position et les métriques des nœuds détectés, puis génère un fichier GeoJSON utilisé par la carte BRouter pour afficher les nœuds du réseau maillé LoRa.

Le daemon s'exécute automatiquement toutes les minutes via un cron job et met à jour la fichier `/data/brouter/www/meshtastic_nodes.json` contenant les positions des nœuds actifs.

### Fonctionnalités principales

- Connexion au nœud Meshtastic via TCP (interface `TCPInterface`)
- Extraction des positions (latitude, longitude) et métriques (batterie, SNR, dernier contact)
- Filtrage des nœuds actifs (dernière écoute < 7 jours)
- Génération d'un fichier GeoJSON pour l'affichage sur la carte BRouter
- Écriture atomique du fichier de sortie (via fichier temporaire + `os.replace`)

---

## Fonctionnement

### Exécution du daemon

Le daemon est exécuté toutes les minutes par cron :

```bash
* * * * * root /data/brouter/meshtastic-daemon.py <IP_DU_NOEUD>
```

L'adresse IP du nœud Meshtastic est passée en argument et configurée lors de l'installation via la variable Ansible `recoverybox_meshtastic_node.ip`.

### Processus détaillé

1. **Connexion** : Le script établit une connexion TCP avec le nœud Meshtastic
2. **Collecte** : Il itère sur tous les nœuds visibles (`interface.nodes`)
3. **Filtrage** : Seuls les nœuds avec des coordonnées valides et un `lastHeard` < 604800 secondes (7 jours) sont conservés
4. **Génération GeoJSON** : Chaque nœud est converti en feature GeoJSON avec ses propriétés
5. **Écriture atomique** : Le fichier est écrit dans un fichier temporaire puis renommé pour éviter les corruptions

### Structure du GeoJSON

Chaque nœud est représenté comme un point GeoJSON avec les propriétés suivantes :

```json
{
  "type": "Feature",
  "geometry": {
    "type": "Point",
    "coordinates": [longitude, latitude]
  },
  "properties": {
    "name": "Nom du nœud",
    "id": "ID du nœud",
    "battery_level": 85,
    "snr": 9.5,
    "last_heard": "2024-01-15T10:30:00Z"
  }
}
```

---

## Interactions avec les fichiers

### Fichiers principaux

| Fichier | Description |
|---------|-------------|
| `/data/brouter/meshtastic-daemon.py` | Script principal du daemon |
| `/data/meshtastic_env/` | Environnement Python virtuel contenant le package `meshtastic` |
| `/etc/cron.d/meshtastic-daemon` | Configuration cron exécutant le daemon toutes les minutes |
| `/data/brouter/www/meshtastic_nodes.json` | Fichier GeoJSON de sortie (mis à jour automatiquement) |
| `/data/brouter/www/recoverybox-mesh.js` | Script JavaScript côté client pour l'affichage sur la carte |
| `/data/brouter/www/mesh-node.png` | Icône des nœuds affichés sur la carte |

### Configuration

Le daemon utilise la configuration suivante définie dans `/etc/recoverybox/custom_config.yml` :

```yaml
recoverybox_meshtastic_node:
  mac: "00:00:00:00:00:00"
  ip: "192.168.200.101"
```

---

## Configuration avancée

### Modification de l'adresse IP du nœud

Pour modifier l'adresse IP du nœud Meshtastic connecté au daemon :

1. Éditer le fichier de configuration :

```bash
nano /etc/recoverybox/custom_config.yml
```

2. Modifier la valeur `recoverybox_meshtastic_node.ip`

3. Redémarrer le service cron pour appliquer les changements :

```bash
systemctl restart cron.service
```

!!! info "Vérification"
    Vous pouvez vérifier la configuration actuelle du cron en consultant le fichier `/etc/cron.d/meshtastic-daemon`.

### Modification de la fréquence d'exécution

Pour modifier la fréquence d'exécution du daemon (par défaut toutes les minutes) :

1. Éditer le fichier cron :

```bash
nano /etc/cron.d/meshtastic-daemon
```

2. Modifier la ligne de cron selon vos besoins. Par exemple, pour exécuter toutes les 5 minutes :

```bash
*/5 * * * * root /data/brouter/meshtastic-daemon.py <IP_DU_NOEUD>
```

3. Sauvegarder et quitter. Les changements seront appliqués automatiquement.

---

## Debug

### Vérifier l'état du cron

```bash
systemctl status cron.service
```

### Consulter les logs du cron

```bash
journalctl -u cron.service -f
```

### Vérifier le fichier de sortie

Vérifier que le fichier GeoJSON est bien mis à jour :

```bash
ls -lh /data/brouter/www/meshtastic_nodes.json
cat /data/brouter/www/meshtastic_nodes.json | head -20
```

### Exécution manuelle du daemon

Pour tester le daemon manuellement :

```bash
python3 /data/brouter/meshtastic-daemon.py 192.168.200.101
```

Remplacez `192.168.200.101` par l'adresse IP de votre nœud Meshtastic.

### Vérifier les logs du daemon

Le daemon n'écrit pas de logs persistants. En cas d'erreur, vous pouvez rediriger la sortie vers un fichier :

```bash
python3 /data/brouter/meshtastic-daemon.py 192.168.200.101 > /tmp/meshtastic-debug.log 2>&1
```

### Problèmes courants

| Problème | Cause probable | Solution |
|----------|----------------|----------|
| Fichier JSON vide | Nœud Meshtastic inaccessible | Vérifier l'IP et la connectivité réseau |
| Erreur `ModuleNotFoundError` | Environnement Python non configuré | Réinstaller le daemon via Ansible |
| Pas de nœuds affichés | Aucun nœud actif dans la portée | Vérifier que les nœuds Meshtastic sont allumés et à portée |

### Vérification de la connectivité

Tester la connexion au nœud Meshtastic :

```bash
ping <IP_DU_NOEUD>
```

Vérifier que le port TCP est accessible :

```bash
nc -zv <IP_DU_NOEUD> 4403
```

---

!!! info "Documentation externe"
    - [Site officiel Meshtastic](https://meshtastic.org/)
    - [Documentation de l'API Python Meshtastic](https://python.meshtastic.org/)
    - [Projet BRouter](https://brouter.de/)
