# put the facter path in the LOAD_PATH so facter looks for new facts there
# this path needs to have a 'facter' dir as an immediate subdir
$LOAD_PATH << File.join(File.expand_path(File.dirname(__FILE__)),'genesisframework')
require 'genesisframework/task'
require 'genesisframework/tasks'
require 'genesisframework/utils'
