#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

if [ `df /dev/shm | tail -1 | awk '{print $2}'` -gt 3000000 ] 
then
  # lets build in the image in our shm
  tmpdir="${TMP_DIR:-/dev/shm/genesis}"
else
  # shm isn't big enough
  tmpdir="${TMP_DIR:-/tmp}"
fi

rm -f genesis.iso
rm -rf /usr/share/nginx/html/repo 
mkdir -p /usr/share/nginx/html/repo 
cp sources/*.rpm /usr/share/nginx/html/repo
createrepo /usr/share/nginx/html/repo
livecd-creator -c genesis.ks -f genesis -t "$tmpdir/live/" --cache="$tmpdir/livecache/" -v
rm -rf base dell epel it local ruby193 tftpboot updates fastbugs security
livecd-iso-to-pxeboot genesis.iso
mkdir -p output
mv tftpboot/initrd0.img output/genesis-initrd.img
mv tftpboot/vmlinuz0 output/genesis-vmlinuz
chmod 644 output/genesis-vmlinuz
mv genesis.iso output/
rm -rf tftpboot
