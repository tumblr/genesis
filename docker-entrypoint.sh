#!/bin/bash
export GENESIS_DIR="${GENESIR_DIR:-/genesis}"
export OUTPUT_DIR="${OUTPUT_DIR:-/output}"

set -ex
echo "Performing build of Genesis Framework"
cd $GENESIS_DIR

echo "===> Building Genesis Scripts RPM"
pushd $GENESIS_DIR/bootcd/rpms/genesis_scripts
rpmbuild --define '_tmppath /tmp' --define '_sourcedir src' --define '_srcrpmdir .' --nodeps -bs genesis_scripts.spec
rpmbuild --rebuild genesis_scripts-*.src.rpm
cp /root/rpmbuild/RPMS/noarch/genesis_scripts-*.noarch.rpm $GENESIS_DIR/bootcd/rpms/
popd
echo ":: Built RPM:"
ls -la $GENESIS_DIR/bootcd/rpms/

echo "===> Building Genesis Image"
cd bootcd
# this is necessary to avoid devicemapper syncronization raceconditions creating
# devices in livecdcreator. Just use the old fallback logic when run in a container:
# https://www.redhat.com/archives/lvm-devel/2012-November/msg00069.html
export DM_DISABLE_UDEV=1
./create-image.sh
