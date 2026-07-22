# Debug


## Hotspot

### Vérifier le service

```bash
systemctl status ap
```

Le service doit être actif.


### Vérifier le conteneur Docker

```bash
docker ps
```

Le conteneur **simple-hotspot** doit apparaître dans la liste.

Pour consulter les journaux :

```bash
docker logs <container_id>
```

### Vérifier l'interface Wi-Fi

Lister les interfaces :

```bash
ip link
```

L'interface :

```text
wlanAP
```

doit être présente.

Il est également possible de vérifier les interfaces sans fil :

```bash
iw dev
```


### Vérifier le bridge

```bash
networkctl
```

ou

```bash
bridge link
```

permettent de vérifier que `wlanAP` est bien rattachée au bridge **Lan**.


### Vérifier le DHCP

Depuis un client Wi-Fi :

```bash
ipconfig
```

(Windows)

ou

```bash
ip addr
```

(Linux)

permettent de vérifier qu'une adresse IP a bien été attribuée.


### Vérifier le routage

Le routage IPv4 doit être activé :

```bash
sysctl net.ipv4.ip_forward
```

Le résultat attendu est :

```text
net.ipv4.ip_forward = 1
```


### Vérifier le pare-feu

Le service IPtables doit être actif :

```bash
systemctl status iptables
```

Il est également possible d'afficher les règles NAT :

```bash
iptables -t nat -L -n
```


### Vérifier la détection de la carte Wi-Fi

Si aucune interface Wi-Fi n'apparaît :

```bash
iw dev
```

ou

```bash
ip link
```

il est probable que le pilote de la carte ne soit pas installé.

Le script d'installation fournit plusieurs firmwares courants (Intel et Realtek notamment), mais certaines cartes nécessitent un pilote spécifique qui devra être installé manuellement.


### Journaux utiles

Les principaux journaux sont accessibles via :

```bash
journalctl -u ap
```

```bash
journalctl -u systemd-networkd
```

Ainsi que les journaux du conteneur Docker :

```bash
docker logs <container_id>
```

Ces commandes permettent généralement d'identifier rapidement les problèmes liés au démarrage du point d'accès, à la configuration radio ou à l'attribution des adresses IP.