Gem::Specification.new do |gem|
  gem.name = "genesis_bootloader"
  gem.homepage = 'https://github.ewr01.tumblr.net/Tumblr/genesis'
  gem.license = "MIT"
  gem.summary = %Q{Generic server onboarding bootloader}
  gem.description = %Q{Genesis is a replacement project for InvisibleTouch that is used to manage provisioning of hardware. The bootloader is what is installed in the base system image to kick off the process.}
  gem.authors = ["Jeremy Johnstone"]
  gem.email = 'jeremy@tumblr.com'

  gem.date = '2014-04-10'
  gem.version = "0.2.0"
  gem.add_dependency("genesis_promptcli","~> 0.2.0")
  gem.add_dependency("genesis_retryingfetcher","~> 0.2.0")

  gem.files = Dir["bin/*", "*.md", "*.txt", "test/*.rb"]
  gem.executables << "genesis-bootloader"
end

