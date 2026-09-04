---
title: Cockpit
description: Web-based administration console accessible via the browser.
tags:
  - service
  - administration
---

# Cockpit

## Presentation

Cockpit is a web-based administration console designed to simplify the management of the RecoveryBox. It provides a user-friendly interface for monitoring system status, managing services and configuring various aspects of the system. The console is accessible via the URL `https://cockpit.recovery.box`.

!!! note "First access"
    On first access, a certificate error may appear because Cockpit uses a self-signed HTTPS certificate. Users must accept the risk or add an exception in their browser.

## Access to service

- **URL** : `https://cockpit.recovery.box`
- **Username / Password** : The same credentials as for logging into the machine.
- **Certificate** : The certificate is self-signed; it is necessary to accept the browser warning to access the interface.

It is possible to manage services from this web interface, which allows to start, stop or restart services without having to use the command line. All machine services can be administered this way. It is therefore **strongly discouraged** to use this feature without a **good understanding** of the services and their dependencies. We recommend using the `services-manager` command which only manages services purely related to the RecoveryBox solution.

When connecting to the Cockpit interface, the user is in **restricted mode**. It is therefore necessary to switch to **Administrator** mode to access all features.

## Advanced configuration

### A. Configuration files

Cockpit uses its base configuration. No custom configuration file has been created.
The self-signed certificate can be found in the `/etc/cockpit/ws-certs.d/` folder.

### B. Debugging

#### Service

```bash
# View Cockpit service logs
journalctl -u cockpit.service
```

#### Apache logs

The Apache web proxy logs, used by Cockpit, are available in the `/var/log/apache2/` directory.

```bash
less +G /var/log/apache2/cockpit_error.log
less +G /var/log/apache2/cockpit_access.log
```