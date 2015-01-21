---
layout: default
---

# Introduction and motivation

Genesis is a tool for data center automation. The primary motiviation
for developing Genesis at Tumblr was to streamline the process of
discovering new machines and reporting their hardware details to
[Collins](https://github.com/tumblr/collins), our inventory management
system, without having to do a bunch of data entry by hand. In
addition, we've also extended Genesis to be a convenient way to do
hardware configuration such as altering BIOS settings and configuring
RAID cards before provisioning an operating system on to the host.  It
has replaced an older system which was a collection of shell scripts.
Being wrtten in a ruby DSL has enabled a more flexible, easy to
understand, and easy to maintain system that more of the staff can use
and extend.

From a high-level point of view, Genesis consists of a stripped down
linux image suitable to boot over PXE and a ruby DSL for describing
tasks to be executed on the host.

# For more information

The [README](https://github.com/tumblr/genesis/blob/master/README.md)
file has detailed information about the project.

