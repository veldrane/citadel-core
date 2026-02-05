# Identity Management – FreeIPA – 02_freeipa

This directory contains the deployment and configuration of the **FreeIPA server**,
which acts as the **central Identity Management (IdM) system** for the entire infrastructure.

FreeIPA is a foundational component of the platform and serves as the single source of truth
for identity, authentication, and service registration.

## Role in the Infrastructure

FreeIPA is used as the **authoritative identity backend**:

- All servers in the infrastructure are registered in FreeIPA
- All internal users and groups are defined and managed here
- Authentication is centralized and consistent across services
- Other systems (e.g. Keycloak, Kubernetes) build on top of FreeIPA

This design mirrors enterprise on‑prem identity architectures.

## Core Responsibilities

The FreeIPA server provides the following services:

- **Identity Management**
  - users, groups, hosts, and host groups
  - centralized authentication and authorization primitives

- **Certificate Authority**
  - issues certificates for hosts and services
  - supports service identities (SPNs) tied to certificates
  - acts as a trusted CA for the internal infrastructure

- **Service Registration**
  - registers services in the IPA directory
  - creates and manages Service Principal Names (SPNs)
  - enables Kerberos-based authentication flows

- **DNS Management**
  - authoritative DNS for internal zones
  - automatic DNS registration for enrolled hosts
  - management of forward and reverse zones

- **Service Discovery**
  - automatic creation of SRV records
  - enabling dynamic discovery of infrastructure services
  - used by higher-level components (e.g. IdP, Kubernetes)

## Ansible Roles Overview

The `ansible` subdirectory contains roles responsible for deploying and configuring
the FreeIPA server.

Each role is designed to keep the identity layer explicit and reproducible.

### Roles

- **common**
  Base system preparation:
  - OS packages and updates
  - baseline system configuration
  - prerequisites required by FreeIPA

- **ipa-server**
  Core FreeIPA server installation:
  - FreeIPA server setup
  - domain and realm initialization
  - integrated DNS and CA configuration

- **ipa-dns**
  DNS-specific configuration:
  - forward and reverse DNS zones
  - DNS policies and defaults
  - enabling dynamic DNS updates

- **ipa-users**
  Identity objects management:
  - creation of internal users
  - group definitions
  - role-based grouping for infrastructure access

- **ipa-hosts**
  Host enrollment and management:
  - registering servers in IPA
  - assigning host groups
  - enabling automatic DNS registration

- **ipa-services**
  Service and SPN registration:
  - service principals
  - Kerberos service identities
  - preparation for certificate issuance

- **ipa-certificates**
  Certificate management:
  - issuing service certificates
  - CA trust distribution
  - integration with consuming systems

## Operational Notes

- FreeIPA is a **critical dependency** for the entire platform
- Loss or corruption of IPA data affects authentication globally
- Regular backups of IPA data and CA material are strongly recommended
- All higher-level identity systems (e.g. Keycloak) should be treated as consumers of IPA

## Design Philosophy

FreeIPA is intentionally placed early in the deployment chain.

Everything else — Kubernetes, Keycloak, service authentication —
assumes a functioning and authoritative identity layer.

In short: **if IPA is wrong, everything above it is wrong too**.