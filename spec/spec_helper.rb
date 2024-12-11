$: << File.join(File.dirname(__FILE__), "/../../lib" )

require 'cucumber_factory'
require 'gemika'
require 'factory_bot'
require 'carrierwave'
require 'carrierwave/orm/activerecord'

if ActiveRecord.respond_to?(:default_timezone=)
  ActiveRecord.default_timezone = :local
else
  # Legacy method that was removed in Rails 7.1:
  ActiveRecord::Base.default_timezone = :local
end

Dir["#{File.dirname(__FILE__)}/support/uploaders/*.rb"].sort.each {|f| require f}
Dir["#{File.dirname(__FILE__)}/support/models/*.rb"].sort.each {|f| require f}
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each {|f| require f}
Dir["#{File.dirname(__FILE__)}/shared_examples/**/*.rb"].sort.each {|f| require f}

Gemika::RSpec.configure_clean_database_before_example

Gemika::RSpec.configure_should_syntax

Gemika::RSpec.configure do |config|
  config.before(:each) do
    PlainRubyClass.reset
  end
  config.include FactoryBot::Syntax::Methods
end
