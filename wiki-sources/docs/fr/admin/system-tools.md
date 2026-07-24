# Outils système

## GPSD

Le service gpsd permet de gérer la communication avec le GPS et de fournir les informations de position et de temps aux applications qui en ont besoin. Il est configuré pour écouter sur le port 2947 et peut être interrogé par des clients compatibles avec le protocole gpsd.

Ce service est automatiquement installé et démarré qu'un GPS soit présent ou non sur la RecoveryBox. Le service est conffiguré pour se lancer même si aucune application ne l'intéroge. Cela permet de s'assurer que le GPS est toujours disponible pour les applications qui en ont besoin, même si elles ne sont pas encore lancées.

### Fichier de configuration

```
/etc/default/gpsd
```

## Chrony

Le service chrony permet de gérer la synchronisation de l'heure du système. Par défaut il utilise des serveurs NTP publics pour se synchroniser. 

Dans la RecoveryBox, chrony est configuré pour utiliser le GPS comme source de temps principale et fournir l'heure exacte aux équipements connectés à la RecoveryBox.

### Fichier de configuration
```
/etc/chrony/000-gps.conf
```

## Driver RTLSDR
