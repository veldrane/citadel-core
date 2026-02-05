#!/bin/bash

kubectl config set-cluster k8s-0001 \
    --server="https://ctl-b78bca-00001.core.syscallx86.com:6443" \
    --insecure-skip-tls-verify=true

kubectl config set-context default/k8s-0001/jdvorak \
    --user=jdvorak/core.syscallx86.com  \
    --namespace=default \
    --cluster=k8s-0001

kubectl config use-context default/k8s-0001/jdvorak

kubectl oidc-login setup --oidc-issuer-url=https://idp.core.syscallx86.com/realms/core.syscallx86.com \
    --oidc-client-id=kubectl-0001 \
    --oidc-client-secret=S55H0SdPDIH07Mom5eryGBHSn8GrjlHH \
    --oidc-extra-scope=k8s-0001-access \
    --oidc-use-access-token \
    --username=jdvorak

kubectl config set-credentials jdvorak/core.syscallx86.com \
     --exec-api-version=client.authentication.k8s.io/v1beta1 \
     --exec-command=kubectl \
     --exec-arg=oidc-login \
     --exec-arg=get-token \
     --exec-arg=--oidc-issuer-url=https://idp.core.syscallx86.com/realms/core.syscallx86.com \
     --exec-arg=--oidc-client-id=kubectl-0001 \
     --exec-arg=--oidc-client-secret=S55H0SdPDIH07Mom5eryGBHSn8GrjlHH \
     --exec-arg=--oidc-extra-scope=k8s-0001-access \
     --exec-arg=--oidc-use-access-token \
     --exec-arg=--username=jdvorak
