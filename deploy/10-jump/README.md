# Jump Server / Bastion – 10_jump

This directory contains the **Jump Server (Bastion) deployment layer**.
The jump server acts as the **primary operational entry point** into the environment
and is used to manage Kubernetes clusters and related infrastructure.

## Purpose

The jump server is intentionally separated from the Kubernetes cluster itself.

It is used for:
- Secure administrative access to the environment
- Running `kubectl`, `helm`, `ansible`, and related tooling
- Acting as a controlled bastion host for infrastructure operations
- Avoiding direct administrative access to Kubernetes nodes

This design follows a classic **bastion / jump-host model** commonly used in
production-grade on‑prem and cloud environments.

## Responsibilities

The jump server provides:

- Centralized access to Kubernetes control planes
- Preconfigured tooling and credentials
- A stable and auditable management surface
- Reduced attack surface on cluster nodes

No workloads or application services are intended to run here.

## Ansible Roles Overview

The `ansible` subdirectory contains roles responsible for preparing and configuring
the jump server.

Each role is intentionally small and focused.

### Roles

- **common**
  Base system preparation:
  - OS packages and updates
  - baseline system configuration
  - common utilities used across the environment

- **users**
  User and access management:
  - creation of administrative users
  - SSH key deployment
  - sudo configuration

- **tools**
  Installs operational tooling:
  - kubectl
  - helm
  - ansible
  - supporting CLI utilities required for cluster management

- **kubeconfig**
  Handles Kubernetes access configuration:
  - distribution of kubeconfig files
  - context setup for multiple clusters
  - secure storage of credentials

- **hardening**
  Basic security hardening:
  - SSH configuration tightening
  - limiting unnecessary services
  - baseline security posture for a bastion host

## Operational Model

Typical workflow:

1. Operator connects to the jump server via SSH
2. All Kubernetes operations are executed from this host
3. Direct access to Kubernetes nodes is avoided
4. Auditability and access control are centralized

This keeps cluster nodes minimal and reduces operational risk.

## Notes

- The jump server is a **control surface**, not a compute node
- It should be treated as a sensitive asset
- Backups of configuration and credentials are recommended