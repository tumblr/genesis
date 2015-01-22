
# Contents

This directory contains the Genesis framework and supporting Gems. The framework includes sources which implement the Genesis task DSL. The gems incldue code supporting the execution of tasks.

## Building instructions:

There are three GEMs of which the framework does most of the work.  These gems are built using ```gem build```

1. cd <gem>   # where <gem> is one of frameword/retryingfetcher/prompt cli
2. edit the .gemspec file.  Increment the version number and adjust dependencies as needed.
3. run: gem build genesis_<gem>.gemspec
3. publish it to your gemserver
4. update the genesis config.yaml file version, if it is version pinned

Note: The testenv and bootcd will find the gems here so leave a copy. The bootcd include the gems as it is required using bootstrapping. 

## Testing changes:

In your testenv or an already booted genesis image:  
1. scp source-host:<gem>-<version>.gem  
2. gem install ./<gem>-<version>.gem  
3. use irb or genesis command to exercize  

Caveat:  The genesis-bootloader will install the versions of these gems as specified in your configuration file.
