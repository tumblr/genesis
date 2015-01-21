require 'rubygems'
require 'rake'
require 'jekyll'

desc "Serve up a local static site for testing"
task :serve do
  # This is how github serves it: https://help.github.com/articles/using-jekyll-with-pages
  ##`jekyll --auto --pygments --no-lsi --safe --serve`
  `jekyll serve --watch --highlighter --no-lsi --safe`
end

task :default => :help
