#!/bin/bash

WORKERS=2

cd ansible/

echo "Building vms for student $i"
echo "  - Building master"
export suffix=$(head -c 16 /dev/urandom | sha1sum | cut -c1-6)
ansible-playbook 00_prepare_setup.yaml -e "student=$1" -e "k8s_role=master" -e "node_index=1" -e "suffix=$suffix"
ansible-playbook 01_prepare_nodes.yaml
ansible-playbook 02_configure_master.yaml
ansible-playbook 03_deploy_master.yaml
ansible-playbook 11_register_ipa_svc.yaml
for m in $(seq 1 $WORKERS); do
  echo "  - Building worker $m"
  ansible-playbook 00_prepare_setup.yaml -e "student=$1" -e "k8s_role=worker" -e "node_index=$m" -e "suffix=$suffix"
  ansible-playbook 01_prepare_nodes.yaml
  ansible-playbook 04_configure_worker.yaml
  ansible-playbook 05_deploy_worker.yaml
done
#ansible-playbook 06_send_cfg.yaml



