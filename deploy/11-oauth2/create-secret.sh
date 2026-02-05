CLIENT_ID=k8s-0001
CLIENT_SECRET=yhi4vq8RM6lwOsAkp0XRW70j2hIGCiGy
COOKIE_SECRET=$( openssl rand -base64 32 | head -c 32 | base64)

kubectl -n oidc-proxy create secret generic oauth2-secret \
  --from-literal=client-id=$CLIENT_ID \
  --from-literal=client-secret=$CLIENT_SECRET \
  --from-literal=cookie-secret=$COOKIE_SECRET \
  --dry-run=client -o json | jq eval 'del(.metadata.creationTimestamp)' > oauth2-secret.json