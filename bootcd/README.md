This directory for building the image that is booted to run genesis
tasks.  After they are built, copy the files in ./output/ to where
they are expected by the net-booting process.

Pre-requisites:
- livecd-tools and createrepo RPMs installed
- python and SimpleHTTPServer module


How to build the boot image:
- checkout code on a linux node or on bootbox cd /genesis/bootcd
- build ruby stable if desired
- build RPMs in rpms/
- sudo ./create-image.sh
- copy it from output to where PXEboot is expecting it

How to build RPM:
 - bring up the testenv and ssh into the bootbox
 - cd /genesis/bootcd/rpms/genesis_scripts
 - rpmbuild --define '_tmppath /tmp' --define '_sourcedir src' --define '_srcrpmdir .' --nodeps -bs genesis_scripts.spec
 - mock --scrub=all    # if trying to rebuild gives you a file or directory not found error
 - mock -r epel-6-x86_64 --rebuild genesis_scripts-0.2-3.el6.src.rpm
 - ls /var/lib/mock/epel-6-x86_64/result
   build.log  genesis_scripts-0.2-3.el6.x86_64.rpm  state.log
   genesis_scripts-0.2-3.el6.src.rpm  root.log
 - cd ..
 - save the RPM where create-image.sh can find it
   mv /var/lib/mock/epel-6-x86_64/result/genesis_scripts-0.2-3.el6.noarch.rpm .
 - [optional] also copy it into the shared testenv directory of the host machine
   cp genesis_scripts-0.2-3.el6.x86_64.rpm /vagrant
