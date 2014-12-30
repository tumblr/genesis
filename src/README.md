This directory contains the source for the part of genesis that executes tasks.

Updating instructions:

1) edit the .gemspec file corresponding to the modified gem.  Increment the verison number and adjust dependencies as needed.
2) run: gem build FOO.gemspec
3) publish it to your gemserver

Testing ideas:

in the testenv or an already booted genesis image
scp source-host:FOO-VERSION.gem .
gem install ./FOO-VERSION.gem
use irb or genesis command
