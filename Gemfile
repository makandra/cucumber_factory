source 'http://rubygems.org'

gemspec

group :development do
  if RUBY_VERSION > '1.9'
    # normally we do not want to freeze versions in a Gem's Gemfile in this
    # case, rspec-rails requires this exact test-unit version on ruby 1.9,
    # without actually having it as a dependency, so we need to freeze it here
    gem 'test-unit', '=1.2.3'
  end
end
