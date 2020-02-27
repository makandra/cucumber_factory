$: << File.join(File.dirname(__FILE__), "/../../lib" )

require 'cucumber_factory'
require 'gemika'
require 'factory_bot'

ActiveRecord::Base.default_timezone = :local

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
