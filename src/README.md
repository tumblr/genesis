
# Src

This directory contains the source which implements the Gensis task DSL and code supporting the execution of tasks.

## Updating instructions:

There are three GEMs of which the framework does most of the work.  These gems are built the common way using ```gem build```

1. cd src/<Gem>   # where <Gem> is teh name of the gem you are building
2. edit the .gemspec file corresponding to the modified gem.  Increment the verison number and adjust dependencies as needed.
3. run: gem build genesis_<Gem>.gemspec
3. publish it to your gemserver
4. 4. update the genesis config.yaml file version, if it is version pinned

Note: the testenv and bootcd will find the gems here so leave a copy

## Testing ideas:

In your testenv or an already booted genesis image:
1. scp source-host:<Gem-Version>.gem .
2. gem install ./<Gem-Version>.gem
3. use irb or genesis command to execercize

Caveat:  The genesis-bootloader will install the versions of these gems as specified in your configuration file.
