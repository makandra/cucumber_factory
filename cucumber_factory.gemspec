# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cucumber_factory/version"

Gem::Specification.new do |spec|
  spec.name = %q{cucumber_factory}
  spec.version = CucumberFactory::VERSION
  spec.authors = ["Henning Koch"]
  spec.email = %q{github@makandra.de}
  spec.homepage = %q{https://github.com/makandra/cucumber_factory}
  spec.summary = %q{Create records from Cucumber features without writing step definition.}
  spec.description = %q{Cucumber Factory allows you to create ActiveRecord models from your Cucumber features without writing step definitions for each model.}
  spec.license = 'MIT'
  spec.metadata = {
    'source_code_uri' => 'https://github.com/makandra/cucumber_factory',
    'bug_tracker_uri' => 'https://github.com/makandra/cucumber_factory/issues',
    'changelog_uri' => 'https://github.com/makandra/cucumber_factory/blob/master/CHANGELOG.md',
    'rubygems_mfa_required' => 'true',
  }

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency('cucumber')
  spec.add_dependency('activesupport')
  spec.add_dependency('activerecord')
  spec.add_dependency('cucumber_priority', '>=0.2.0')

end
