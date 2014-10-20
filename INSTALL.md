# Structure

- genesis server
- tftp server
- nexus server
- pxe server
- kickstart server

## genesis server

The genesis server needs to have a user deploy with commit access for
a local copy of the genesis git repo and credentials that can be
shared.

The genesis server's git repo needs pre-receive.hook and post-receive.hook set
up for deployments to work. Samples are in the deploy directory.

