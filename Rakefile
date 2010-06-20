require 'rake'
# require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

desc 'Default: Run all specs.'
task :default => :spec

desc "Run all specs"
Spec::Rake::SpecTask.new() do |t|
  t.spec_opts = ['--options', "\"spec/support/spec.opts\""]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc 'Generate documentation for the cucumber_factory gem.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'cucumber_factory'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "cucumber_factory"
    gemspec.summary = "Create records from Cucumber features without writing step definitions."
    gemspec.email = "github@makandra.de"
    gemspec.homepage = "http://github.com/makandra/cucumber_factory"
    gemspec.description = "Cucumber Factory allows you to create ActiveRecord models from your Cucumber features without writing step definitions for each model."
    gemspec.authors = ["Henning Koch"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

