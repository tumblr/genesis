source 'https://rubygems.org'

# as per http://jekyllrb.com/docs/github-pages/
# use the same version of github-pages as github does
require 'json'
require 'open-uri'
versions = JSON.parse(open('https://pages.github.com/versions.json').read)

gem 'github-pages', versions['github-pages']

group :developement do
  gem 'rake'
end
