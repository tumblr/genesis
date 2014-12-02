# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name = "genesis_promptcli"
  gem.email = 'jeremy@tumblr.com'
  gem.homepage = 'https://github.ewr01.tumblr.net/Tumblr/genesis'
  gem.license = "MIT"
  gem.summary = %Q{Genesis CLI prompt}
  gem.description = %Q{Genesis is a replacement project for InvisibleTouch that is used to manage provisioning of hardware. The promptcli is what asks if you want to perform something and has a timeout going with a default value if nothing selected in specified time period.}
  gem.authors = ["Jeremy Johnstone"]

  gem.files = Dir["{lib}/*.rb", "*.md", "*.txt"]
  gem.date = '2014-04-10'
  gem.version = "0.2.0"
  #gem.add_dependency("termios", "~> 0.9.4")
  # if you want to use 1.9.2+, use ruby-termios -_-
  gem.add_dependency("ruby-termios", "~> 0.9.6")
end
