---
title: HTTPS
description: HTTPS configuration options for RecoveryBox
tags:
  - tool
  - installation
  - service
  - security
---

# HTTPS

## Overview

It is possible to enable HTTPS browsing on the RecoveryBox. This secures exchanges between the browser and the web server by encrypting transmitted data.

HTTPS uses an SSL/TLS certificate to establish a secure connection. This certificate must be approved by an external authority (CA) and renewed regularly to be considered valid by web browsers. The very principle of RecoveryBox operating offline prevents automatic SSL/TLS certificate renewal. RecoveryBox therefore uses a self-signed certificate for HTTPS. This enables HTTPS but web browsers will display a security warning indicating the certificate is not approved by an external authority. This warning will only appear on the first connection to the web server.

!!! warning "Warning"
    The error message on the first connection to RecoveryBox services is normal and **must not** be considered a security issue.

When HTTPS is enabled, all HTTP connections are automatically redirected to HTTPS.

!!! note "Meshtastic"
    LoRa devices based on ESP32 chips do not support HTTPS. To keep compatibility with these devices, HTTPS is always disabled on this service.

## Enabling HTTPS

HTTPS is enabled during installation/update via the [Ansible variable](ansible-variables.md) `recoverybox_enable_https`. It can be enabled or disabled at any time by modifying this variable in `/etc/recoverybox/custom_config.yml` and re-running the installation script.

## Customizing the SSL/TLS certificate

You can set up your own SSL/TLS certificate for HTTPS. To do so, place the certificate and private key files in the `/etc/ssl/recoverybox/` directory with the names `recoverybox.crt` and `recoverybox.key`.