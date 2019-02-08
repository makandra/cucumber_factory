# Runtime dependencies
require 'active_support/all'
require 'active_record'

require 'cucumber'
if Cucumber::VERSION >= '3'
  require 'cucumber/glue/registry_and_more'
else
  require 'cucumber/rb_support/rb_language'
end

require 'cucumber_priority'

# Gem
require 'cucumber_factory/build_strategy'
require 'cucumber_factory/factory'
require 'cucumber_factory/switcher'

module Cucumber
  module Factory
    module_function

    def add_steps(main)
      warn "Using `Cucumber::Factory.add_steps(self)` is deprecated. Use `require 'cucumber_factory/add_steps'` instead."

      add_steps_filepath = File.join(File.dirname(__FILE__), 'cucumber_factory/add_steps.rb')
      main.instance_eval(File.read(add_steps_filepath))
    end
  end
end
