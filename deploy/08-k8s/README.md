# Kubernetes Cluster – 08_k8s

This directory contains the **Kubernetes cluster bootstrap and configuration layer** of the project.
It represents the lowest-level runtime platform on which all higher-level components are deployed.

## Overview

- **Kubernetes version:** v1.35.0
- **CNI:** OVN-Kubernetes v1.2.0
- **Installation method:** kubeadm-based, automated via shell scripts
- **Target use-case:** on-prem / lab-grade Kubernetes with strong focus on networking and identity

The cluster is intentionally kept close to upstream Kubernetes while integrating advanced networking
and authentication concepts.

## Directory Structure & Roles

This directory is responsible for:

- Bootstrapping a Kubernetes control-plane and worker nodes
- Installing and configuring OVN-Kubernetes as the CNI
- Wiring Kubernetes authentication to an internal Identity Provider (Keycloak)
- Providing a baseline user-facing access layer (Dashboard + OAuth2 Proxy)

It is designed as **infrastructure code**, not application code.

## build_cluster.sh

The `build_cluster.sh` script is the main entry point for cluster creation.

High-level responsibilities:

- Initializes the Kubernetes control plane using `kubeadm`
- Applies version-pinned Kubernetes configuration (v1.35.0)
- Installs OVN-Kubernetes (v1.2.0) and applies required CRDs and manifests
- Performs post-install steps required for networking and authentication

The script is intentionally explicit and linear to make debugging and customization easy.

## Authentication & Identity

The Kubernetes API server is integrated with an **internal Identity Provider (Keycloak)**:

- API server uses OIDC for user authentication
- Users are authenticated against the internal IdP
- RBAC is used for authorization once identity is established

This allows the cluster to behave similarly to managed Kubernetes offerings
while remaining fully on‑prem and self‑hosted.

## Networking Model

At this stage of the project:

- **Ingress is NOT used**
- Services are exposed via **External IPs**
- Internal cluster IPs are selectively published using OVN-Kubernetes capabilities

This is a conscious design decision to keep the networking model transparent
during early phases of the project.

Ingress controllers may be introduced later once the networking and identity
layers are fully validated.

## User-Facing Components

As part of the installation, the following components are deployed automatically:

- **Kubernetes Dashboard**
- **OAuth2 Proxy** in front of the Dashboard

This ensures:

- No anonymous access
- Dashboard authentication is delegated to the same IdP as the API server
- A consistent authentication experience for users

## Current Status

- Functional Kubernetes cluster
- Integrated OIDC authentication
- External IP–based service exposure
- Dashboard protected by OAuth2 Proxy

Future iterations will likely introduce:

- Ingress-based exposure
- More fine-grained network policies
- Additional identity-aware services