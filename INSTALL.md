# Installation

## Prerequisites

For operation, genesis needs the following services
- DHCP server
- TFTP server
- HTTP file server

## Build

Build the boot image. This needs to be built in Linux with livecd-tools. The
Genesis-bootbox virtualbox VM provided in the test environment has all the tools
needed.

    linuxbox$ cd bootscript && sudo ./create-image.sh
    localmachine$ scp linuxbox:genesis/bootcd/output/genesis'*' genesis/web/public/ipxe-images/

## Configuration

### TFTP server
The TFTP server serves the iPXE binary to the PXE firmware. We use the xinetd
server daemon to launch the tftp daemon for incoming requests.

```
service tftp
{
  disable     = no
  socket_type = dgram
  protocol    = udp
  wait        = yes
  user        = root
  server      = /usr/sbin/in.tftpd
  server_args = -s /var/lib/tftpboot
  per_source  = 11
  cps         = 1000 2
  instances   = 1000
  flags       = IPv4
}
```

Place the undionly.kpxe file (see
[the iPXE docs](http://ipxe.org/download#chainloading_from_an_existing_pxe_rom)
for more information) in /var/lib/tftpboot.

Example puppet code:
* [TFTP](https://github.com/tumblr/genesis/tree/master/testenv/bootbox/puppet/modules/tftp/manifests)
* [iPXE](https://github.com/tumblr/genesis/tree/master/testenv/bootbox/puppet/modules/ipxe/manifests)

### DHCP server
The DHCP server needs to be set up to chain load the iPXE firmware from the TFTP
server. Using ISC DHCPd, a simplified configuration looks like

```
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.200 192.168.1.229;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.168.1.255;
    option domain-name-servers <dns servers>;

    if exists ipxe.http {
        filename "<url to ipxe menu config>";
    } else {
        filename "undionly.kpxe";
	next-server <file server ip>;
    }
}
```
More information on DHCP for loading iPXE can be found at 
[iPXE.org](http://ipxe.org/howto/dhcpd#pxe_chainloading).

Example puppet code:
* [DHCP](https://github.com/tumblr/genesis/tree/master/testenv/bootbox/puppet/modules/dhcp/manifests)

### HTTP file server
The file server serves the genesis OS initrd and kernel so that iPXE can boot 
them. It also serves the genesis config.

It can also serve the iPXE menu configuration and the stage 2 ruby script.
In a more complex setup however, these might be generated on the fly by a script.

## Configuration files
Examples to all the configuration files mentioned above can be found in the
test environment puppet code. Here are a couple of sample files that are good
to check out.

* [Sample genesis config file](https://github.com/tumblr/genesis/blob/master/testenv/bootbox/puppet/modules/genesis/templates/config.yaml.erb.sample)
Fetched by Genesis OS to configure various URLs and other settings
* [Sample menu.ipxe](https://github.com/tumblr/genesis/blob/master/testenv/bootbox/puppet/modules/genesis/templates/menu.ipxe.erb)
Used by iPXE to present a menu to the user. Note the GENESIS_MODE and 
GENESIS_CONF_URL kernel parameters.
* [Sample stage2 script](https://github.com/tumblr/genesis/blob/master/testenv/bootbox/puppet/modules/genesis/templates/stage2.erb.sample)

