# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cucumber_factory/version"

Gem::Specification.new do |s|
  s.name = %q{cucumber_factory}
  s.version = CucumberFactory::VERSION
  s.authors = ["Henning Koch"]
  s.email = %q{github@makandra.de}
  s.homepage = %q{http://github.com/makandra/cucumber_factory}
  s.summary = %q{Create records from Cucumber features without writing step definitions.}
  s.description = %q{Cucumber Factory allows you to create ActiveRecord models from your Cucumber features without writing step definitions for each model.}
  s.license = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency('rails', '~>2.3')
  s.add_development_dependency('rspec', '<2')
  s.add_development_dependency('rspec-rails', '=1.3.4')
  s.add_development_dependency('sqlite3')

  s.add_dependency('cucumber')
  s.add_dependency('activesupport')

end

