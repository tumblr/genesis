This directory for building the image that is booted to run genesis
tasks.  After they are built, copy the files in ./output/ to where
they are expected by the net-booting process.

Pre-requisites:
- livecd-tools and createrepo RPMs installed
- python and SimpleHTTPServer module


How to build:
- checkout code on a linux node
- build ruby stable if desired
- sudo ./create-image.sh
  
