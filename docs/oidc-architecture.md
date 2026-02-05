# OIDC Architecture for Kubernetes + Dashboard
(Keycloak + oauth2-proxy + kubectl)

This document describes a **minimal, capability‑driven OIDC architecture** for Kubernetes,
designed to be explicit, auditable, and safe against credential leakage.

The design goals are:

- Separate **identity**, **capability**, and **authorization**
- Use **one master audience** for the Kubernetes cluster
- Use **multiple client_id values** for individual tools and services
- Grant Kubernetes access **only on explicit request** via optional scopes

---

## 1. Identity Flow Overview

```
User
  |
  | (username/password)
  v
FreeIPA
  |
  | (replication / federation)
  v
Keycloak (OIDC Issuer)
  |
  | JWT (audience + claims)
  v
+----------------------------+
| Kubernetes API Server      |
| oauth2-proxy (Dashboard)   |
| kubectl (CLI)              |
+----------------------------+
```

- **FreeIPA**: Source of truth for users and credentials
- **Keycloak**: OIDC issuer, token minting, scopes & audience control
- **Kubernetes**: Verifies JWT issuer + audience, enforces RBAC
- **oauth2-proxy**: Web OIDC client protecting Dashboard
- **kubectl**: CLI OIDC client using exec plugin

---

## 2. Client ID Design

### 2.1 Master Kubernetes Audience Client

**Client ID:** `k8s-0001`

Purpose:
- Represents the **Kubernetes cluster itself**
- Used only as a **JWT audience value**
- Referenced by kube‑apiserver

Properties:
- Public client
- **No client secret**
- Not used for interactive login

> kube‑apiserver only checks `aud == k8s-0001`, it never authenticates *as* this client.

---

### 2.2 kubectl Client

**Client ID:** `kubectl-0001`

Purpose:
- Interactive CLI login
- Issues tokens on behalf of the user

Properties:
- Public client (PKCE recommended)
- Optional client secret acceptable for lab usage
- Does NOT get Kubernetes access by default

---

### 2.3 Dashboard Client

**Client ID:** `dashboard-0001`

Purpose:
- OAuth2/OIDC login for Kubernetes Dashboard
- Used by oauth2-proxy

Properties:
- Confidential client
- Has its own client secret
- Separate blast radius from kubectl and other services

---

## 3. Scope Design (Capability Model)

### 3.1 Optional Client Scope: `k8s-0001-access`

This scope represents the **capability to access the Kubernetes API**.

If (and only if) this scope is requested:
- The token becomes valid for Kubernetes
- RBAC applies normally

### Mappers inside this scope

1. **Audience Mapper**
   - Adds `k8s-0001` to `aud`

2. **Group Membership Mapper**
   - Adds `groups` claim (for RBAC)

3. **Username Mapper**
   - Adds `preferred_username` (or `username`)

### Assignment

- Assigned as **OPTIONAL** scope to:
  - `kubectl-0001`
  - `dashboard-0001`

This ensures Kubernetes access is **explicitly requested**, not implicit.

---

## 4. Kubernetes API Server Configuration

```yaml
--oidc-issuer-url=https://idp.core.syscallx86.com/realms/core.syscallx86.com
--oidc-client-id=k8s-0001
--oidc-username-claim=preferred_username
--oidc-groups-claim=groups
--oidc-ca-file=/path/to/keycloak/ca.crt
```

Kubernetes verifies:
- JWT signature
- Issuer (`iss`)
- Audience (`aud` contains `k8s-0001`)

Authorization is handled **only** by Kubernetes RBAC.

---

## 5. Kubernetes RBAC Example

### Namespace‑level read access via group

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: viewers-readonly
  namespace: dashboard
subjects:
- kind: Group
  name: k8s:viewers
roleRef:
  kind: ClusterRole
  name: view
  apiGroup: rbac.authorization.k8s.io
```

### Cluster admin for a specific user

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: veldrane-cluster-admin
subjects:
- kind: User
  name: veldrane
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

---

## 6. Dashboard + oauth2-proxy Configuration

### Keycloak Client (`dashboard-0001`)

- Valid Redirect URI:
  - `https://dashboard.core.syscallx86.com/oauth2/callback`
- Confidential client
- Secret stored in Kubernetes Secret / Helm values

### oauth2-proxy Configuration (concept)

```ini
provider = "oidc"
oidc_issuer_url = "https://idp.core.syscallx86.com/realms/core.syscallx86.com"

redirect_url = "https://dashboard.core.syscallx86.com/oauth2/callback"
email_domains = ["*"]

# Explicit capability request
scope = "openid profile email k8s-0001-access"

# Forward user token to Dashboard
pass_access_token = true
pass_authorization_header = true
set_authorization_header = true

cookie_secure = true
cookie_domains = ".core.syscallx86.com"

upstreams = [
  "https://kubernetes-dashboard-kong-proxy.dashboard.svc.cluster.local"
]
```

Result:
- Dashboard receives the **user bearer token**
- Kubernetes RBAC applies per user

---

## 7. kubectl Configuration (OIDC exec plugin)

### kubeconfig user entry

```yaml
users:
- name: veldrane/k8s-0001
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1
      command: kubectl
      args:
      - oidc-login
      - get-token
      - --oidc-issuer-url=https://idp.core.syscallx86.com/realms/core.syscallx86.com
      - --oidc-client-id=kubectl-0001
      - --oidc-client-secret=REDACTED_IF_USED
      - --oidc-extra-scope=k8s-0001-access
      - --oidc-use-access-token
      - --username=veldrane
```

### kubeconfig cluster + context

```yaml
clusters:
- name: k8s-0001
  cluster:
    server: https://<API_SERVER_HOST>:6443
    certificate-authority-data: <BASE64_CA>

contexts:
- name: default/k8s-0001/veldrane
  context:
    cluster: k8s-0001
    user: veldrane/k8s-0001
    namespace: default

current-context: default/k8s-0001/veldrane
```

---

## 8. Security Properties Achieved

- No shared client secrets across tools
- Kubernetes master audience has **no secret**
- Explicit capability escalation via optional scope
- Clear blast radius per client_id
- Clean separation:
  - Identity → Keycloak
  - Capability → Scopes + Audience
  - Authorization → Kubernetes RBAC

This model scales cleanly to additional services
(Grafana, Prometheus, ArgoCD, custom APIs)
by adding new client_ids and optional scopes.
