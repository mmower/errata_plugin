# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'errata/version'
 
Gem::Specification.new do |s|
  s.name        = "errata"
  s.version     = Errata::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Mower"]
  s.email       = ["self@mattmower.com"]
  s.homepage    = "http://github.com/mmower/errata"
  s.summary     = "The best way to deal with your Rails application errors"
  s.description = "Errata reports errors directly to your console"
 
  s.required_rubygems_version = ">= 1.3.6"
  # s.rubyforge_project         = "bundler"
 
  # s.add_development_dependency "rspec"
 
  s.files        = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md ROADMAP.md CHANGELOG.md)
  # s.executables  = ['bundle']
  s.require_path = 'lib'
end