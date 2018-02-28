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
require 'cucumber/factory'
require 'cucumber_factory/switcher'
