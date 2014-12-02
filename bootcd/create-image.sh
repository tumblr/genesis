#!/bin/bash

REPO=repo

set -e

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 
  exit 1
fi
for cmd in createrepo livecd-creator livecd-iso-to-pxeboot; do
  if [[  `command -v $cmd >/dev/null 2>&1` ]]; then
    echo "$cmd required, but not found in PATH.  Aborting." 1>&2
    exit 1
  fi
done



if [ `df /dev/shm | tail -1 | awk '{print $2}'` -gt 3000000 ] 
then
  # lets build in the image in our shm
  tmpdir="${TMP_DIR:-/dev/shm/genesis}"
else
  # shm isn't big enough
  tmpdir="${TMP_DIR:-/tmp}"
fi

rm -f genesis.iso

rm -rf $REPO
mkdir -p $REPO
cp rpms/*.rpm $REPO
createrepo $REPO

# port must match genesis.ks expected value
python -m SimpleHTTPServer 8000 $REPO &
pid=$!

livecd-creator -c genesis.ks -f genesis -t "$tmpdir/live/" --cache="$tmpdir/livecache/" -v

# cleanup local rpm repo
kill $pid
rm -rf $REPO

rm -rf base dell epel it local ruby193 tftpboot updates fastbugs security

livecd-iso-to-pxeboot genesis.iso

mkdir -p output
mv tftpboot/initrd0.img output/genesis-initrd.img
mv tftpboot/vmlinuz0 output/genesis-vmlinuz
rm -rf tftpboot

chmod 644 output/genesis-vmlinuz
mv genesis.iso output/

echo $0 completed successfully results in ./output/
