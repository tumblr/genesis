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

cleanup() {
    [[ -n "$pid" ]] && kill $pid
    [[ -n "$REPO" ]] && rm -rf "$REPO"
    rm -rf base dell epel it local ruby193 tftpboot updates fastbugs security
    rm -rf tftpboot
    [[ -n "$tmpdir" ]] && rm -rf  "$tmpdir/live" "$tmpdir/livecache"
}
trap cleanup SIGINT EXIT

if [ `df /dev/shm | tail -1 | awk '{print $2}'` -gt 3000000 ] 
then
  echo "### building image in  ${TMP_DIR:-/dev/shm/genesis}"
  tmpdir="${TMP_DIR:-/dev/shm/genesis}"
else
  echo "### /dev/shm isn't big enough, building in ${TMP_DIR:-/tmp}"
  tmpdir="${TMP_DIR:-/tmp}"
fi

rm -f genesis.iso

echo '### creating local repo'
rm -rf $REPO
mkdir -p $REPO
cp rpms/*.rpm $REPO
createrepo $REPO
echo '### local repo contains these RPMs'
ls -l $REPO/*.rpm

echo '### starting http://localhost:8000 yum repro'
# port must match genesis.ks expected value
python -m SimpleHTTPServer 8000 $REPO &
pid=$!

echo '### creating livecd'
livecd-creator -c genesis.ks -f genesis -t "$tmpdir/live/" --cache="$tmpdir/livecache/" -v

echo '### cleanup local rpm repo'
kill $pid
unset pid
rm -rf $REPO

echo '### cleanup unused directories'
rm -rf base dell epel it local ruby193 tftpboot updates fastbugs security

echo '### create genesis.iso'
livecd-iso-to-pxeboot genesis.iso

mkdir -p output
mv tftpboot/initrd0.img output/genesis-initrd.img
mv tftpboot/vmlinuz0 output/genesis-vmlinuz
chmod 644 output/genesis-vmlinuz
mv genesis.iso output/
rm -rf tftpboot

printf "### $0 completed successfully results in ./output/"
ls -l output
