# Genesis

## Introduction and motivation
Genesis is a tool for data center automation. The primary motivation for
developing Genesis at Tumblr was to streamline the process of discovering new
machines and reporting their hardware details to 
[Collins](https://github.com/tumblr/collins), our inventory management system,
without having to do a bunch of data entry by hand. In addition, we've also
extended Genesis to be a convenient way to do hardware configuration such as
altering BIOS settings and configuring RAID cards before provisioning an
operating system on to the host.

From a high-level point of view, Genesis consists of a stripped down linux image
suitable to boot over PXE and a ruby DSL for describing tasks to be executed on
the host.

This repository also includes a [test environment](https://github.com/tumblr/genesis/tree/master/testenv) 
which is suitable for building the linux image.

## Framework

[genesis_framework](https://rubygems.org/gems/genesis_framework) [![framework](https://badge.fury.io/rb/genesis_framework.svg)](http://badge.fury.io/rb/genesis_framework)

[genesis_retryingfetcher](https://rubygems.org/gems/genesis_retryingfetcher) [![retryingfetcher](https://badge.fury.io/rb/genesis_retryingfetcher.svg)](http://badge.fury.io/rb/genesis_retryingfetcher)

[genesis_promptcli](https://rubygems.org/gems/genesis_promptcli) [![promptcli](https://badge.fury.io/rb/genesis_promptcli.svg)](http://badge.fury.io/rb/genesis_promptcli)


The [Genesis framework](https://github.com/tumblr/genesis/tree/master/src/framework) and
supporting gem can be found in [src](https://github.com/tumblr/genesis/tree/master/src)

## Tasks
Tasks are created using the [Genesis
DSL](https://github.com/tumblr/genesis/blob/master/tasks/README.md) which makes
it easy to run commands, install packages, etc. in the stripped down
environment.

Examples of tasks are the
[TimedBurnin](https://github.com/tumblr/genesis/blob/master/tasks/TimedBurnin.rb)
task, which performs a stress test on the system to rule out hardware errors
before putting it into production, and
[BiosConfigrR720](https://github.com/tumblr/genesis/blob/master/tasks/BiosConfigrR720.rb),
which sets up the BIOS on Dell R720s just the way we want it.

## General workflow
There are a couple of systems apart from Genesis that need to be in place for a
successful deployment. These are

* a DHCP server,
* a TFTP server,
* and a file server (serving static files over HTTP)

More detail on setting these up is documented in
[INSTALL.md](https://github.com/tumblr/genesis/blob/master/INSTALL.md).

When a machine boots, the DHCP server tells the PXE firmware to chain boot into
iPXE. We then use iPXE to present a list of menu choices, fetched from a remote
server. When the user makes a choice we load the Genesis kernel and initrd (from
the file server) along with parameters on the kernel command line. Once the
Genesis OS has loaded, the genesis-bootloader fetches and executes a ruby script
describing a second stage where we install gems, a few base RPMs, and fetch our
tasks from a remote server. Finally, we execute the relevant tasks.

For a real world example; consider a brand new server that boots up. It makes a
DHCP request and loads the iPXE menu. In this case, we know that we haven't seen
this MAC address before, so it must be a new machine. We boot Genesis in to
discovery mode, where the tasks it runs are written to fetch all the hardware
information we need and report it back to the Collins. In our setup this
includes information such as hard drives and their capacity and the number of
CPUs, but also more detailed information such as service tags, which memory
banks are in use, and even the name of the switchports all interfaces are
connected to. We then follow this up with 48 hours of hardware stress-test using
the TimedBurnin task.

## Test environment
To avoid testing Genesis in production, we've set up a virtual test environment
based on VirtualBox. This allows for end-to-end testing of changes to the
framework, new tasks, etc.

More information about the test environment and setting it up can be found in
[testenv/README.md](https://github.com/tumblr/genesis/blob/master/testenv/README.md).

## Building an Image

To make it easy to get started with genesis, we have included a `Dockerfile` that will allow
you to compile a bootable live image without needing a lot of client side configuration. If you
have docker running on your machine and just want to build the latest images:

```
# mkdir output
# docker run --privileged=true -v $(pwd)/output:/output tumblr/genesis-builder
# ls output
```

To build a custom image, if you have tweaked something about genesis, you can present build a custom builder image:

```
# docker build -f Dockerfile.centos6 -t genesis-builder .
# docker run --privileged=true -v $(pwd)/output:/output genesis-builder
# ls output
```

## Contact
Please feel free to open issues on GitHub for any feedback or problems you might
run in to. We also actively encourage pull requests. Please also make
sure to check [CONTRIBUTING.md](https://github.com/tumblr/genesis/blob/master/CONTRIBUTING.md).

## License
Copyright 2016 Tumblr Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.
