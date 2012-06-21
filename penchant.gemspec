# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "penchant/version"

Gem::Specification.new do |s|
  s.name        = "penchant"
  s.version     = Penchant::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Bintz"]
  s.email       = ["john@coswellproductions.com"]
  s.homepage    = ""
  s.summary     = %q{Things I do for my Rails projects to get up to speed in new environments fast}
  s.description = %q{Things I do for my Rails projects to get up to speed in new environments fast}

  s.rubyforge_project = "penchant"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'bundler'
end
