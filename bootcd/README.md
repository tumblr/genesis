This is the image that is booted to run genesis tasks.

How to build:
- checkout code on a linux node
- build ruby stable if desired
- cp ruby RPM in a repo with baseurl=http://localhost/repo/
  or adjust genesis.ks
- cp bootloader RPM into same repo
- sudo ./create-image.sh
  
