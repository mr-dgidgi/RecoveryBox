---
title: Cartography
description: Local mapping service based on Brouter and TileServer-GL with map generation via generate-map.
tags:
  - service
  - cartography
---

# Cartography

## Overview

RecoveryBox's cartography service is based on **Brouter** and **TileServer-GL**. It provides a web interface for browsing maps, fully offline.

- **[Brouter](https://github.com/abrensch/brouter)** is an open-source routing engine primarily designed for cycling and hiking. It integrates elevation calculation and allows importing, generating, and exporting GPX files.
- **[TileServer-GL](https://tileserver.readthedocs.io/en/latest/)** is an open-source cartography server that serves vector and raster maps from `.mbtiles` data files. It uses MapLibre/Mapbox GL for on-the-fly tile rendering.

The local map is generated on the fly and integrates the chosen area in high definition onto a low-resolution world map.

## Service Access

The cartography interface is accessible to all users connected to the RecoveryBox hotspot.

| URL                                            | Description                          |
| ---------------------------------------------- | ------------------------------------ |
| [http://map.recovery.box](http://map.recovery.box) | Access to the cartography interface  |

## Advanced Configuration

### A. Configuration Files

| Item | Description |
| --- | --- |
| `/data/tileserver/map.mbtiles` | Main map file |
| `/var/log/apache2/carto_access.log` | Apache access logs for the carto service |
| `/var/log/apache2/carto_error.log` | Apache error logs for the carto service |

### B. Customization

#### Adding an additional zone via `generate-map`

The `generate-map` tool allows downloading and integrating new cartographic zones in high definition. It retrieves OpenStreetMap data from [geofabrik.de](https://download.geofabrik.de) and offers 4 zoom levels: 6, 10, 12, 14.

The script automatically generates tiles and then merges the new data with existing data. This operation can take varying amounts of time depending on map size and machine power.

!!! info "Dedicated documentation"
    For more details on using `generate-map` (full procedure, zoom levels, debugging), consult the dedicated page: [**generate-map**](../admin/generate-map.md)

#### Adding your own `.mbtiles` file

If you already have your own `.mbtiles` file, it can be installed at the following location:

```text
/data/tileserver/map.mbtiles
```

!!! warning "File name"
    The file must be named `map.mbtiles`.

Then restart the service via the `service-manager` to load the new map.

### C. Debugging

```bash
# View access logs
cat /var/log/apache2/carto_access.log

# View error logs
cat /var/log/apache2/carto_error.log
```
