This directory contains the source for the part of genesis that executes tasks.

Updating instructions:

1) edit the .gemspec file corresponding to the modified gem.  Increment the verison number and adjust dependencies as needed.
2) run: gem build FOO.gemspec
3) gem install ./FOO-VERSION.gem
4) use irb to test
5) publish it to your gemserver


