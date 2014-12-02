Gem::Specification.new do |gem|
  gem.name = "genesis_retryingfetcher"
  gem.email = 'jeremy@tumblr.com'
  gem.homepage = 'https://github.ewr01.tumblr.net/Tumblr/genesis'
  gem.license = "MIT"
  gem.summary = %Q{Genesis remote resource fetcher}
  gem.description = %Q{Genesis is a replacement project for InvisibleTouch that is used to manage provisioning of hardware. The retryingfetcher is what fetches resources from remote locations with a specified number of retries and backoff between each.}
  gem.authors = ["Jeremy Johnstone"]
  gem.version = "0.2.0"
  gem.date = '2014-04-10'
  gem.add_dependency("curb", "~> 0.8.5")
  gem.files = Dir["lib/*.rb", "*.md", "*.txt"]
end

