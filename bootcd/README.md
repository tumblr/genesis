# Boot image
This directory for building the image that is booted to run genesis
tasks.  After they are built, copy the files in ./output/ to where
they are expected by the net-booting process.

## Pre-requisites:
- livecd-tools and createrepo RPMs installed
- python and SimpleHTTPServer module

## Building the boot image:
- Checkout code on a linux node, or on the testenv bootbox do `cd /genesis/bootcd`
- Build ruby stable if desired
- Build RPMs in rpms/ (see below)
- `sudo ./create-image.sh` to create the initrd and kernel
- Copy it from output to where PXEboot is expecting it

## Building the RPMs:
 - Bring up the testenv and ssh into the bootbox
 - Build the RPMs using rpmbuild and mock:
```
cd /genesis/bootcd/rpms/genesis_scripts
rpmbuild --define '_tmppath /tmp' --define '_sourcedir src' --define '_srcrpmdir .' --nodeps -bs genesis_scripts.spec
mock --scrub=all`    # if trying to rebuild gives you a file or directory not found error
mock -r epel-6-x86_64 --rebuild genesis_scripts-0.2-3.el6.src.rpm
```
 - Resulting RPM can be found in /var/lib/mock/epel-6-x86/result
 - Copy the RPM into [bootcd/rpms](https://github.com/tumblr/genesis/tree/master/bootcd/rpms)
   - ```cp /var/lib/mock/epel-6-x86_64/result/genesis_scripts-0.5-3.el6.noarch.rpm ../```
   - The ```create-image.sh`` script will look for the
 - Create the Genesis boot image
   - ```cd ../..; sudo ./create-image.sh```
 - [optional] Also copy it into the shared testenv directory of the host machine

`cp genesis_scripts-0.2-3.el6.x86_64.rpm /vagrant`
