# Boot image
This directory contains sources for building the image that is booted to run genesis
tasks. You can use the [test environment]() to build the genesis image, or use a SL6 
installation. The instructions below assume you are using the test environment.

## Pre-requisites:

Pre-requisites are installed when using the test environment and include

- livecd-tools and createrepo RPMs installed
- python and SimpleHTTPServer module

## Building the Genesis Scripts RPM:

The Genesis scripts rpm includes scripts and configuration files used by Genesis in the bootcd image

 - Bring up the testenv and ssh into the bootbox (vagrant ssh)
 - Build the RPMs using rpmbuild and mock:
 
```cd /genesis/bootcd/rpms/genesis_scripts```

Build the source rpm

```rpmbuild --define '_tmppath /tmp' --define '_sourcedir src' --define '_srcrpmdir .' --nodeps -bs genesis_scripts.spec```

Clear mock data, if trying to rebuild gives you a file or directory not found error

```mock --scrub=all```  

Build the rpm (ensure the src rpm version is correct, when copy-pasting from here, it is likely to be incorrect)

```mock -r epel-6-x86_64 --rebuild genesis_scripts-0.2-3.el6.src.rpm```

 - Resulting RPM can be found in /var/lib/mock/epel-6-x86/result
 - Copy the RPM into [bootcd/rpms](https://github.com/tumblr/genesis/tree/master/bootcd/rpms)
   - ```cp /var/lib/mock/epel-6-x86_64/result/genesis_scripts-0.5-3.el6.noarch.rpm ../```
   - The ```create-image.sh``` script will look for the RPM in this location

## Building the boot image:
 - Create the Genesis boot image
   - ```cd /genesis/bootcd```
   - ```sudo ./create-image.sh```
   - The ```create-image``` script will create the initrd and kernel in ```/genesis/bootcd/output```

## Deploying the boot image:
 - Copy the files from the output to where PXEBoot is expecting it, this is typically your file server.
