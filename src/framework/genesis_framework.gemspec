Gem::Specification.new do |gem|
  gem.name = "genesis_framework"
  gem.homepage = 'https://github.ewr01.tumblr.net/Tumblr/genesis'
  gem.license = 'Apache License, 2.0'
  gem.summary = %q{Generic server onboarding framework}
  gem.description = %q{Genesis is a project used to manage provisioning of hardware. This is the framework which runs the specified tasks.}
  gem.authors = ["Jeremy Johnstone", 'Roy Marantz']
  gem.email = 'opensourcesoftware@tumblr.com'

  gem.date = '2014-11-14'
  gem.version = '0.4.2'
  gem.add_dependency("genesis_promptcli","~> 0.2.0")
  gem.add_dependency("genesis_retryingfetcher","~> 0.2.0")
  gem.add_dependency("collins_client","~> 0.2.10")
  gem.add_dependency("facter","~> 2.0.1")

  gem.files = Dir["bin/*", "lib/**/*", "*.md", "*.txt", "test/*.rb"]
  gem.executables << "genesis"
end

