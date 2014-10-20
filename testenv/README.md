# Genesis test environment

This is the test environment for Genesis which allows you to run
end-to-end testing of changes without risking accidentally taking down
the production setup. It uses two virtual machines, one managed by
Vagrant for ease of provisioning, and another naked machine which is
setup to network boot from the bootbox machine managed via Vagrant. It
uses ipxe chainloading (despite VirtualBox already supporting IPXE) to
more accurately reflect the real production environment.

Requirements:

* VirtualBox
* Vagrant
* Network access to Nexus (or having the Vagrant basebox previously installed)

To rebuild testnode.ova also need :

* RedHat based OS live cd.  We used Scientific Linux 6.5

Setup:

1. Import the testnode.ova virtual machine image into Virtualbox 
1. Go into the testenv/bootbox folder and run ```vagrant up```
1. Once the vagrant machine is running, start the imported virtual machine and it will network boot from the vagrant box

Notes:

* All packages needed on the bootbox Vagrant VM to simulate the prod env are installed via puppet apply. See the puppet dir inside bootbox/ to see the manifests applied to the VM on startup
* Network booting goes across a virtualbox private network named 'genesis'
* Password for the bootbox follows normal vagrant scheme and can be ssh'd into via localhost:2222 (or vagrant ssh)


