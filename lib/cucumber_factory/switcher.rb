module CucumberFactory
  module Switcher
    extend self

    def find_last(klass)
      # Don't use class.last, in sqlite that is not always the last inserted element
      if Rails::VERSION::MAJOR < 4
        klass.find(:last, :order => "id")
      else
        klass.order(:id).last
      end
    end

    def assign_attributes(model, attributes)
      if Rails::VERSION::MAJOR < 3 || (Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR < 2)
        model.send(:attributes=, attributes, false) # ignore attr_accessible
      elsif Rails::VERSION::MAJOR < 4
        model.send(:assign_attributes, attributes, without_protection: true)
      else
        model.send(:assign_attributes, attributes)
      end
    end

  end
end
