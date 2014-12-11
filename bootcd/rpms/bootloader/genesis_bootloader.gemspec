Gem::Specification.new do |gem|
  gem.name = "genesis_bootloader"
  gem.homepage = 'https://github.ewr01.tumblr.net/Tumblr/genesis'
  gem.license = "Apache License, 2.0"
  gem.summary = %Q{Generic server onboarding bootloader}
  gem.description = %Q{Genesis is used to manage provisioning of hardware. The bootloader is what is installed in the base system image to kick off the process.}
  gem.authors = ["Jeremy Johnstone", 'Roy Marantz']
  gem.email = 'opensource@tumblr.com'

  gem.date = '2014-12-11'
  gem.version = "0.3.0"
  gem.add_dependency("genesis_promptcli", '~> 0')
  gem.add_dependency("genesis_retryingfetcher", '~> 0')

  gem.files = Dir["bin/*", "*.md", "*.txt", "test/*.rb"]
  gem.executables << "genesis-bootloader"
end

