#!/bin/bash

KICKSTART="/root/lab/01_template/kickstart/kickstart.cfg"

mkdir -p /data/vms/rocky10

virt-install \
--name rocky10 \
--ram 2048 \
--vcpus 2 \
--disk bus=virtio,path=/data/vms/rocky10/rootvg.qcow2,format=qcow2,size=20 \
--os-variant rocky10 \
--network model=virtio,network=public \
--xml './devices/interface/vlan/tag/@id=8' \
--graphics none \
--serial pty \
--location /data/iso/Rocky-10.0-x86_64-boot.iso \
--initrd-inject=$KICKSTART \
--boot bootmenu.enable=on,bios.useserial=on \
--extra-args="inst.ks=file:/kickstart.cfg  inst.text console=tty0"
