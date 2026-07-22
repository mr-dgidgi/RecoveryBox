---
title: MkDocs
description: RecoveryBox technical wiki based on MkDocs Material, serving online and offline documentation.
tags:
  - service
  - documentation
---

# MkDocs

## Overview

**[MkDocs](https://www.mkdocs.org)** is a static site generator designed for technical documentation. RecoveryBox uses **[MkDocs Material](https://squidfunk.github.io/mkdocs-material/)**, a feature-rich theme (search, tab navigation, dark mode, etc.).

The wiki site is accessible to all users connected to the hotspot and contains documentation for all RecoveryBox services, tools, and procedures.

For more details about the project, consult the **[official MkDocs documentation](https://www.mkdocs.org)** and the **[MkDocs Material GitHub repository](https://github.com/squidfunk/mkdocs-material)**.

### Properties

| Property | Value |
| --- | --- |
| **Type** | Docker container (systemd service) |
| **Image** | `squidfunk/mkdocs-material` |
| **Port** | `18001` (host) → `8080` (container) |
| **Volume** | `/data/wiki` (host) → `/docs` (container) |
| **Activation variable** | `recoverybox_enable_mkdocs` |

## Service Access

The wiki is accessible to all users connected to the RecoveryBox hotspot.

| URL | Description |
| --- | --- |
| [http://wiki.recovery.box](http://wiki.recovery.box) | RecoveryBox Wiki |

!!! note "Multilingual"
    The wiki is available in French and English. A language selector is available in the interface.

## Advanced Configuration

### A. Configuration Files

| Item | Description |
| --- | --- |
| `/data/wiki/mkdocs.yml` | MkDocs configuration file (site, theme, navigation) |
| `/data/wiki/docs/` | Directory containing all wiki Markdown files |

The `mkdocs.yml` file defines the site name, URL, Material theme (slate palette, tab navigation), and language alternates.

### B. Customization

#### Adding or modifying pages

The wiki content resides in `/data/wiki/docs/`. The structure is as follows:

```text
docs/
├── fr/           ← French documentation
├── en/           ← English documentation
└── images/       ← shared graphic resources
```

To add a page, create a `.md` file in the appropriate directory (`fr/` or `en/`) then add it to the `nav` section of `mkdocs.yml` if necessary.

!!! info "Hot reload"
    MkDocs Material in development mode automatically reloads modifications. In production (Docker container), a service restart via the `service-manager` is required to apply structural changes.

#### Theme customization

The MkDocs Material theme can be customized via the `/data/wiki/mkdocs.yml` file. Main parameters:

```yaml
theme:
  name: material
  features:
    - navigation.tabs
  palette:
    scheme: slate
```

Consult the **[Material theme documentation](https://squidfunk.github.io/mkdocs-material/)** for advanced options (search, icons, extensions, etc.).

### C. Debugging

```bash
# View service logs
journalctl -u mkdocs.service -f

# Verify the container is running
docker ps | grep mkdocs
```
