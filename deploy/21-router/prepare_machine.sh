#! /bin/bash

IMAGEDIR="/data/vms/router.core.syscallx86.com"

mkdir -p "$IMAGEDIR"
qemu-img create -f qcow2 "$IMAGEDIR/root.qcow2" 20G 
virsh define kvm/opensens.xml
virsh start router.core.syscallx86.com