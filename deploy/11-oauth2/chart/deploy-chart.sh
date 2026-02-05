#!/bin/bash

helm upgrade --install oauth2-proxy \
     oauth2-proxy/oauth2-proxy \
     --version "v7.14.2" \
     -f oidc-proxy.yaml \
     --namespace oauth2-proxy

kubectl patch svc oauth2-proxy --patch '{"spec":{"externalIPs":["10.4.1.130"]}}'