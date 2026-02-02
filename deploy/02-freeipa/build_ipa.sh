#!/bin/bash

cd ansible
ansible-playbook 01_prepare_nodes.yaml
ansible-playbook 02_install_ipa.yaml