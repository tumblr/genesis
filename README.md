# Structure

TODO

# Deployment

Deployment is currently done via a git based deploy. There are three
setup steps to get going.

1) Copy the deploy key to your ~/.ssh directory

2) Add this to your .ssh/config

    Host genesis-prod-push
       Hostname genesis-03f648c5.ewr01.tumblr.net
       User deploy
       IdentityFile ~/.ssh/tumblr_deploy

3) Add the git remote via:

    git remote add production genesis-prod-push:/genesis.git

You can then do a "git push production master" to deploy from there forward. 

Please note, only pushes of the master branch currently do a deploy /
restart. This might change in the future.

Also please note, deploys are to be considered "brittle" at the
moment, so be extra careful. Make sure nobody is trying to deploy at
the same time, do not hit control-c once the git push has started,
etc.

Test Setup
=============

### Required Software

The following needs to be available on your local machine to test.
Download VirtualBox: http://download.virtualbox.org/virtualbox/4.3.10/VirtualBox-4.3.10-93012-OSX.dmg
It needs to be 4.3.10-93012 specifically due to client tools installed in the box image. 

Download Vagrant: http://www.vagrantup.com/downloads.html

### Build

Build the bootcd (need to build in Linux with livecd-tools!)

    linuxbox$ cd bootscript && sudo ./create-image.sh
    localmachine$ scp linuxbox:genesis/bootcd/output/genesis'*' genesis/web/public/ipxe-images/

### Test

Get vagrant running on your local machine:

    vagrant up
