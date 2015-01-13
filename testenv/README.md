# Genesis test environment

This is the test environment for Genesis which allows you to run
end-to-end testing of changes without risking accidentally taking down
the production setup. It uses two or three virtual machines:

* a bootbox used to support netbooting
* a target host which runs genesis
* and optional snooper host to watch the network and help with debugginfg the bootbox

The bootbox and snooper are managed by Vagrant for ease of
provisioning while target host is naked machine based on a Virtualbox
.ova file.

The target host uses netbooting via a downloaded iPXE image to more
accurately reflect the typical production boot ROMs which only support
PXE.

## Requirements:

* VirtualBox (version 4.3.10 because of the included .ova file)
* Vagrant
* Network access to fileserver (or having the Vagrant basebox previously installed)

## Configuration:

1. copy Vagrantfile.sample to Vagrantfile adjusting as needed
2. copy bootbox/puppet/manifests/bootbox.pp.sample to bootbox.pp and adjust
3. copy bootbox/puppet/modules/genesis/templates/{config.yaml,stage2}.erb.sample
and adjust

## Setup:

1. Import the testnode.ova virtual machine image into Virtualbox 
2. Go into the testenv/bootbox folder and run ```vagrant up```
3. Once the vagrant machine is running, start the imported virtual machine and it will network boot from the vagrant box

## Notes:

* All packages needed on the bootbox Vagrant VM to simulate the prod env are installed via puppet apply. See the puppet dir inside bootbox/ to see the manifests applied to the VM on startup. The puppet manifests applied to the VM on startup are in [bootbox](https://github.com/tumblr/genesis/tree/master/testenv/bootbox)
* Network booting goes across a virtualbox private network named 'genesis'
* Password for the bootbox follows normal vagrant scheme and can be ssh'd into via localhost:2222 (or vagrant ssh)
* vagrant sets up sharing of this directory tree under /genesis on the genesis-bootbox

## Bootbox details:

### Filesystem layout (from Vagranfile):
* / sl-base-4.3.10
* /vagrant <- bootbox-shared an easy way to pass files around
* /genesis <- ../.. a.k.a. top level of local git repo
* /web     <- web  sinatra web fileserver
* /testenv for puppet managed files, templated e.g. config.yaml menu.ipxe
Running services:
* dhcp
* tftp
* http sinatra application run by unicorn
* named (not used?)

### Target startup details:

The following details have a line of descriptive text, details on what the bootbox service does, and other files under puppet/ which are involed
1. VirtualBox iPXE asks dhcp what to do
    dhcpd says load /tftpboot/undionly.kpxe from @genesis_ipaddress via tftp
    dhcp server.pp dhcpd.conf.erb
2. iPXE/undionly.kpxe asks dhcp what to do
    dhcpd says ipxe load filename http://@genesis_ipaddress/testenv/menu.ipxe
    genesis.pp menu.erb
3. iPXE menu boots genesis image
4. kernel loads and starts
5. when a root login shell is started, run genesis-bootloader
   bash /root/.bash_profile
   bootcd/rpms/genesis-scripts/root-bash_profile
5. genesis-bootloader downloads config.yaml and stage2 then starts stage2
   unicorn web/genesis.rb
6. stage2 does tumblr specific genesis startup.  setup yum repos, load framework gem, start IPMI, download tasks, start genesis
   stage2.erb

* How to test or develop
Following is basic information about testing or developing the different parts of genesis and the test environment.  When I say "boot the target" you can do that or use the snooper host to manually run genesis-bootstrap instead.

* one of the GEMs
 - Modify source
 - update version number in .gemspec file
 - gem build ...gemspec
 - cp .gem file to testenv/bootbox/bootbox-shared/
 - vagrant ssh into the genesis bootbox
 - gem install /vagrant/...gem --no-rdoc --no-ri
 - boot the target

* stage2
 - edit testenv/bootbox/puppet/modules/genesis/templates/stage2.erb
 - vagrant up or vagrant provision to install it on bootbox
 - boot the target

* genesis-bootstrap
 - edit bootcd/rpms/bootloader/bin/genesis-bootstrap
 - cp genesis-bootstrap testenv/bootbox/bootbox-shared
 - run /vagrant/genesis-bootbox on snooper node
