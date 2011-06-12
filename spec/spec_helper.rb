$: << File.join(File.dirname(__FILE__), "/../lib" )

# Set the default environment to sqlite3's in_memory database
ENV['RAILS_ENV'] ||= 'in_memory'

# Load the Rails environment and testing framework
require "#{File.dirname(__FILE__)}/app_root/config/environment"
require "#{File.dirname(__FILE__)}/../lib/cucumber_factory"
require 'spec/rails'

# Undo changes to RAILS_ENV
silence_warnings {RAILS_ENV = ENV['RAILS_ENV']}

# Run the migrations
ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate")

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
end

def prepare_cucumber_example
  @runtime = Cucumber::Runtime.new
  language = @runtime.load_programming_language('rb')
  scenario = stub('scenario', :language => 'en', :accept_hook? => true)
  language.send(:begin_scenario, scenario)
  @world = language.current_world
  @main = Object.new
  @main.extend(Cucumber::RbSupport::RbDsl)
  Cucumber::Factory.add_steps(@main)
  @runtime.before(scenario)
end

def invoke_cucumber_step(step)
  @runtime.step_match(step).invoke(nil) # nil means no multiline args
end
