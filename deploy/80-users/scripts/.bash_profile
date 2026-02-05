# BEGIN ANSIBLE MANAGED KREW BLOCK
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH" 
# END ANSIBLE MANAGED KREW BLOCK
alias kubens='kubectl-ns'
alias oc='kubectl'
alias token='kubectl create token veldrane'
# BEGIN ANSIBLE MANAGED DBG BLOCK
kubersh() {
  export pod=$(kubectl get pods | grep $1 | awk '{print $1}')
  kubectl exec --stdin --tty "$pod" -- /bin/bash
}
dbgpod() {
  export debug_pod=$(kubectl get pod -n debug-ns | grep debug-pod | awk '{print $1}')
  kubectl exec --stdin --tty "$debug_pod" -n debug-ns -- /bin/bash
}

idptoken() {
  kubectl oidc-login get-token \
  --oidc-issuer-url="https://idp.core.syscallx86.com/realms/core.syscallx86.com" \
  --oidc-client-id="k8s-0001" \
  --oidc-client-secret=yhi4vq8RM6lwOsAkp0XRW70j2hIGCiGy \
  --skip-open-browser=true \
  --username=veldrane | jq -M .status.token | sed -E 's/\"//g'
}

# END ANSIBLE MANAGED DBG BLOCK
