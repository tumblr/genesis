# Boot image
This directory contains sources for building the image that is booted to run genesis
tasks. You can use the [test environment](https://github.com/tumblr/genesis/blob/master/testenv/README.md) to build the genesis image, or use a SL6
installation. The instructions below assume you are using the test environment.

## Pre-requisites:

Pre-requisites are installed when using the test environment and include

- livecd-tools and createrepo RPMs installed
- python and SimpleHTTPServer module

## Building the Genesis Scripts RPM:

The Genesis scripts rpm includes scripts and configuration files used by Genesis in the bootcd image

 - Bring up the testenv and ssh into the bootbox (vagrant ssh) or ensure all of the [pre requisites](#pre-requisites) are installed correctly
 - Build the RPMs using rpmbuild and mock:

```cd /genesis/bootcd/rpms/genesis_scripts```

 - Build the source rpm

```rpmbuild --define '_tmppath /tmp' --define '_sourcedir src' --define '_srcrpmdir .' --nodeps -bs genesis_scripts.spec```

 - Build the rpm (ensure the src rpm version is correct, when copy-pasting from here, it is likely to be incorrect)

```mock -r epel-6-x86_64 --rebuild genesis_scripts-0.8-1.el6.src.rpm```

If trying to rebuild gives you a file or directory not found error, clear mock
data.

```mock --scrub=all```

 - Resulting RPM can be found in /var/lib/mock/epel-6-x86/result
 - Copy the RPM into [bootcd/rpms](https://github.com/tumblr/genesis/tree/master/bootcd/rpms)
   - ```cp /var/lib/mock/epel-6-x86_64/result/genesis_scripts-0.8-1.el6.noarch.rpm ../```
   - The ```create-image.sh``` script will look for the RPM in this location

## Building the boot image:
 - Bring up the testenv and ssh into the bootbox (vagrant ssh) or ensure all of the [pre requisites](#pre-requisites) are installed correctly
 - Build the ``genesis_scripts`` rpm, and copy it to ``/genesis/bootcd/rpms``. [See these docs for instructions.](#building-the-genesis-scripts-rpm)
 - Build the genesis gems found in `/genesis/src`. Do not move or install them. [See these instructions for how to build the gems.](https://github.com/tumblr/genesis/blob/master/src/README.md)
 - ```cd /genesis/bootcd```
 - ```sudo ./create-image.sh```
 - The ```create-image``` script will create the initrd and kernel in ```/genesis/bootcd/output```

## Deploying the boot image:
 - Copy the files from the output to where PXEBoot is expecting it, this is typically your file server.

## Tmpfs Root for Production

If you have tasks that tend to pull down lots of files to "disk", you may run into the issue where the overlay filesystem overtop of the squashfs root becomes filled. To avoid this, the bootcd ships with a patched ```/usr/share/dracut/modules.d/90dmsquash-live/dmsquash-live-root``` that supports the ```toram``` kernel parameter. If you pass ```toram``` to the kernel in your ipxe config, dracut will copy your squashfs root over to a tmpfs volume and mount that as the root filesystem. You can see the patch we apply [here](dracut.toram.patch) and the fully patched file [here](dmsquash-live-root.toram.sh).

More info here: http://www.espenbraastad.no/post/el6-rootfs-on-tmpfs/?p=160

Sample ipxe config for booting genesis with tmpfs root instead of squashfs+overlay:

```
#!ipxe
.....
initrd <%= @ipxe_initrd %>
kernel <%= @ipxe_kernel %> <%= @ipxe_kernel_flags %> toram GENESIS_MODE=${target} GENESIS_CONF_URL=<%= @ipxe_config_url %> <%= @raid_level.nil? ? "" : "GENESIS_RAID_LEVEL=#{raid_level}" %>
```

Please note, the ```toram``` option will not work in the testenv, as the Genesis ova has only 2g of ram, and the default / partition is 4g. As such, this option is suitable for production environments, but not testing.
