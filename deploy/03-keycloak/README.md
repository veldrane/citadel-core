# Central Identity Provider – Keycloak – 03_keycloak

This directory contains the deployment and configuration of **Keycloak**,
which acts as the **central Identity Provider (IdP)** for the infrastructure.

Keycloak sits **on top of FreeIPA** and provides modern identity protocols
(OIDC / OAuth2) to consumers such as Kubernetes and user-facing services.

## Role in the Infrastructure

Keycloak is responsible for **federating identities from FreeIPA** and exposing
them in a form usable by modern platforms.

Key design points:

- Keycloak is **not the source of truth**
- FreeIPA remains the authoritative identity backend
- Keycloak is a protocol translation and UX layer

This separation keeps identity ownership clean while enabling modern integrations.

## Realm Model

- A Keycloak **realm is generated automatically**
- The realm name matches the **FreeIPA domain**
- This creates a 1:1 conceptual mapping between IPA and Keycloak

All users, groups, and relevant identity attributes are **synchronized from FreeIPA**
into the corresponding Keycloak realm.

## Identity Source

Keycloak pulls **all identity data from FreeIPA**:

- users
- groups
- group membership
- authentication credentials (via federation)

No local users are intended to be managed directly in Keycloak.

## Current Integrations

At the current stage, Keycloak is integrated with:

- **Kubernetes API Server**
  - OIDC authentication
  - user and group mapping for RBAC

- **kubectl**
  - OIDC-based login flow
  - token acquisition via external login plugin

- **Kubernetes Dashboard**
  - protected by OAuth2 Proxy
  - authentication delegated to Keycloak

This provides a consistent authentication experience across core operational tooling.

## Future Direction

Planned future integrations include:

- additional Kubernetes services (Prometheus, Grafana, etc.)
- internal web applications
- service-to-service authentication flows
- broader OAuth2 / OIDC usage beyond Kubernetes

Keycloak is intentionally introduced early to allow gradual expansion
without redesigning the identity layer.

## Ansible Roles Overview

The `ansible` subdirectory contains roles responsible for deploying and configuring
Keycloak and its integration with FreeIPA.

Each role focuses on a single responsibility to keep the identity stack understandable.

### Roles

- **common**
  Base system preparation:
  - OS packages and updates
  - baseline system configuration
  - prerequisites for running Keycloak

- **keycloak**
  Core Keycloak deployment:
  - Keycloak installation
  - service configuration
  - startup and lifecycle management

- **keycloak-realm**
  Realm bootstrap and configuration:
  - automatic realm creation
  - realm naming aligned with IPA domain
  - base realm settings

- **keycloak-ipa-federation**
  Identity federation with FreeIPA:
  - LDAP / Kerberos federation setup
  - user and group synchronization
  - attribute mapping

- **keycloak-clients**
  Client configuration:
  - Kubernetes API server OIDC client
  - kubectl login client
  - OAuth2 Proxy client for Dashboard

- **keycloak-hardening**
  Security and operational hardening:
  - HTTPS configuration
  - token and session policies
  - baseline security settings

## Design Philosophy

Keycloak acts as a **bridge between traditional enterprise identity**
and **modern cloud-native platforms**.

FreeIPA defines *who* you are.
Keycloak defines *how* you authenticate to modern systems.

Keeping these roles separate preserves clarity, security, and long-term flexibility.