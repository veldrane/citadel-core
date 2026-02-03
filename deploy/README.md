
Stages are designed to be executed **incrementally** and **selectively**.

---

## Identity & authentication model

- **FreeIPA** acts as:
  - DNS authority
  - Kerberos realm
  - User / group source

- **Keycloak** acts as:
  - OIDC Identity Provider
  - Federation layer on top of IPA
  - Token issuer for Kubernetes and services

- **Kubernetes**:
  - kube-apiserver is configured for OIDC authentication
  - external IdP is the single source of user identity
  - RBAC is mapped to IdP identities

Service discovery between components relies heavily on **DNS SRV records**
(e.g. `_idp._tcp`, `_jump._tcp`) to avoid hard-coded host dependencies.

---

## Networking model

- Virtual machines are connected via **libvirt networks**
- **VLAN tagging** is used for L2 segmentation
- Logical separation typically includes:
  - Management / jump access
  - Infrastructure services (IPA, Keycloak, registry)
  - Student / workload clusters

This is intentionally kept **close to real infrastructure patterns** rather
than abstracted away.

---

## Kubernetes & OVN

- Kubernetes is deployed via **kubeadm**
- OVN-Kubernetes manifests are **vendored** in this repository
- Multiple versions can coexist (e.g. for upgrade testing)
- No reliance on "latest" manifests fetched at runtime

This allows:
- deterministic installs
- diffing between OVN versions
- controlled upgrade experiments

---

## Trade-offs (intentional)

This deployment makes several **explicit trade-offs**:

- Heavy use of `shell` tasks instead of pure Ansible modules
- Not all roles are strictly idempotent
- Secrets handling is pragmatic (lab-grade, not production-grade)
- Playbooks prioritize **clarity of flow** over abstraction

These choices are intentional to keep:
- the lab understandable
- iteration speed high
- cognitive overhead manageable for a single maintainer

---

## Expected usage

This directory is meant to be used for:

- personal lab experimentation
- training environments
- testing advanced infrastructure scenarios
- learning identity / networking / Kubernetes internals

It is **not intended** to be:
- a generic Ansible framework
- a turnkey production installer

---

## Running the deployment

There are helper scripts in the repository root (e.g. `build_*.sh`) that orchestrate
execution of these stages.

Typical workflow:

1. Prepare hosts / VMs template
2. Deploy FreeIPA
3. Deploy Keycloak
4. Deploy infrastructure services
5. Deploy Kubernetes clusters
6. Onboard users / students

Each stage can be executed independently if prerequisites are met.

---

## Notes for future maintainers (including future me)

- This lab optimizes for **learning and experimentation**, not perfection
- If something looks "manual", it probably is — on purpose
- Improving secrets management and idempotence is the primary future improvement area
- Network and identity flows are the **core value** of this environment

If you break it: good.
That usually means you learned something.

