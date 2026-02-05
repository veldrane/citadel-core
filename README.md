# Citadel Lab

**Citadel** is a personal infrastructure lab and experimentation environment
focused on **identity, networking and Kubernetes internals**.

The primary goal of this project is to provide a **reproducible, integrated lab**
that allows testing and learning of advanced scenarios involving:

- external identity providers
- Kubernetes authentication and authorization
- software-defined networking
- real-world infrastructure patterns

This repository is **not a generic framework** and **not a production installer**.
It is a hands-on lab, designed, built and maintained by a single person, with
explicit trade-offs between completeness, elegance and available time.

---

## What Citadel provides

At its core, Citadel can provision a fully integrated environment consisting of:

- **FreeIPA** – identity, DNS, Kerberos
- **Keycloak** – OIDC, federation, service identities
- **Kubernetes** (latest) – configured to authenticate against an external IdP
- **OVN-Kubernetes** – explicit, vendored manifests (tested versions)
- **Container registry**
- **Build node**
- **Jump / management host**
- **Network segmentation using VLANs**

The environment supports **multi-tenant / multi-student Kubernetes clusters**
and enables testing of advanced scenarios such as:

- OIDC authentication to kube-apiserver
- Identity federation (IPA ↔ Keycloak ↔ Kubernetes)
- OVN networking behavior and upgrades
- Registry and build pipelines
- Network isolation and controlled access paths

---

## Repository structure

The repository is expected to grow over time.
At the moment, the main focus is on deployment logic.

```
.
├── deploy/          # Infrastructure provisioning and configuration
│   ├── 01-prepare-nodes
│   ├── 02-freeipa
│   ├── 03-keycloak
│   ├── 04-registry
│   ├── 05-build
│   ├── 08-k8s
│   ├── 10-jump
│   ├── 80-users
│   ├── 99-global
│   └── 99-newhost
└── README.md
```

Future additions may include:
- documentation
- training materials
- labs and exercises
- reference architectures
- example workloads

---

## Architecture overview

Citadel follows a **staged deployment model**.
Each stage builds on the previous one and can be executed independently
once prerequisites are satisfied.

Key architectural principles:

- **Identity-first design**
- **Explicit networking**
- **Deterministic deployments**
- **Minimal abstraction**

The lab intentionally stays close to how real infrastructure is built and operated,
rather than hiding complexity behind automation layers.

---

## Identity & authentication model

- **FreeIPA** acts as:
  - DNS authority
  - Kerberos realm
  - User and group source

- **Keycloak** acts as:
  - OIDC Identity Provider
  - Federation layer on top of IPA
  - Token issuer for Kubernetes and services

- **Kubernetes**:
  - kube-apiserver authenticates users via OIDC
  - external IdP is the single source of user identity
  - RBAC is mapped to IdP identities

Service discovery between components relies on **DNS SRV records**
(e.g. `_idp._tcp`, `_jump._tcp`) to avoid hard-coded dependencies.

---

## Networking model

- Virtual machines are connected via **libvirt networks**
- **VLAN tagging** is used for L2 segmentation
- Typical separation includes:
  - management / jump access
  - infrastructure services
  - student / workload clusters

The networking model is explicit by design and suitable for experimenting
with real-world failure modes and traffic flows.

---

## Kubernetes & OVN

- Kubernetes clusters are deployed via **kubeadm**
- OVN-Kubernetes manifests are **vendored** in the repository
- Multiple OVN versions may coexist for testing and upgrade experiments
- No reliance on dynamically fetched "latest" manifests

This enables:
- deterministic installs
- controlled upgrades
- direct comparison between OVN versions

---

## Trade-offs and design philosophy

Citadel makes several **explicit trade-offs**:

- pragmatic use of `shell` tasks where clarity is preferred over abstraction
- not all components are strictly idempotent
- secrets handling is lab-grade, not production-grade
- simplicity and transparency are prioritized over polish

These choices keep the lab:
- understandable
- flexible
- fast to iterate on

---

## Intended usage

Citadel is intended for:

- personal experimentation
- training environments
- learning identity and networking internals
- testing Kubernetes authentication and networking scenarios

It is **not intended** to be:
- a turnkey production installer
- a general-purpose automation framework

---

## Notes to future maintainers (including future me)

- This project optimizes for **learning over perfection**
- If something breaks, that is often the point
- Identity and networking flows are the core value of this lab
- The most likely future improvements are:
  - better secrets management
  - improved idempotence
  - richer documentation and training materials

If it looks manual, it probably is — on purpose.
