# Fortinet VDOM Configuration - GRC Lab

## Overview
This document outlines the Virtual Domains (VDOMs) configured in the home GRC lab FortiGate environment. Each VDOM is logically segmented for security, performance, and compliance monitoring.

---

## VDOM: `Internet`

### Purpose
Handles WAN connectivity and routes external traffic.

### Interfaces
- `wan1` – ISP connection
- `dmz` – Isolated segment for public-facing services

### Firewall Policies
| ID | Source      | Destination | Service | Action  |
|----|-------------|-------------|---------|---------|
| 1  | LAN VDOM    | any         | HTTPS   | allow   |
| 2  | IoT VDOM    | any         | DNS     | allow   |

### Static Routes
- `0.0.0.0/0` → `wan1` (default route)

### Notes
- All traffic logs sent to Elastic for log analysis
- IPS and AV enabled on all outgoing policies

---

## VDOM: `LAN`

### Purpose
Main internal network for trusted systems

### Interfaces
- `lan1`, `lan2` – internal switches

### VLANs
- `VLAN10` – Workstations
- `VLAN20` – Admins

### Firewall Policies
| ID | Source  | Destination | Service  | Action |
|----|---------|-------------|----------|--------|
| 3  | LAN     | Internet    | HTTPS    | allow  |
| 4  | LAN     | IoT         | NTP, DNS | allow  |

---

## VDOM: `IoT`

### Purpose
Isolated segment for smart devices and cameras

### Interfaces
- `lan3` – Ubiquiti switch port for IoT
- `G4 Dome` camera

### Restrictions
- Deny access to LAN and Internet e
