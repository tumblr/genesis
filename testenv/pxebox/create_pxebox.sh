#!/bin/bash

if [ -z $(which VBoxManage) ]; then
  echo "VBoxManager not found in PATH."
  exit 1
fi

VMNAME="Genesis-pxe"
VMPATH="/"$(VBoxManage list systemproperties|grep "^Default machine folder" \
|cut -d '/' -f 2-)"/$VMNAME/"

if [ $(VBoxManage list vms|sed 's/"\(.*\)".*/\1/'|grep $VMNAME) ]; then
  echo "Removing old pxebox from VirtualBox"
  VBoxManage unregistervm $VMNAME --delete
fi

echo "Creating new VM: $VMNAME"
VBoxManage createvm --name $VMNAME --ostype Linux26_64 --register

echo "Setting up blank 8GB disk"
VBoxManage storagectl $VMNAME --name 'SATA Controller' --add sata \
  --hostiocache off --portcount 1
VBoxManage createhd --filename "$VMPATH/$VMNAME.vdi" --size 8192 --format VDI
VBoxManage storageattach $VMNAME --storagectl 'SATA Controller' --port 0 \
  --device 0 --type hdd --medium "$VMPATH/$VMNAME.vdi"

echo "Setting up NIC"
VBoxManage modifyvm $VMNAME --nic1 intnet
VBoxManage modifyvm $VMNAME --intnet1 'genesis'

echo "Setting boot order to boot from net first, disk second"
VBoxManage modifyvm $VMNAME --boot1 net
VBoxManage modifyvm $VMNAME --boot2 disk
