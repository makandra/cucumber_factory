module CucumberFactory
  module Switcher
    extend self

    def find_last(klass)
      # Don't use class.last, in sqlite that is not always the last inserted element
      # If created_at is available prefer it over id as column for ordering so that we can handle UUIDs
      order_column = klass.column_names.include?('created_at') ? 'created_at, id' : 'id'
      if Rails::VERSION::MAJOR < 4
        klass.find(:last, :order => order_column)
      else
        klass.order(order_column).last
      end
    end

    def assign_attributes(model, attributes)
      if Rails::VERSION::MAJOR < 3 || (Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR < 2)
        model.send(:attributes=, attributes, false) # ignore attr_accessible
      elsif Rails::VERSION::MAJOR < 4
        model.send(:assign_attributes, attributes, :without_protection => true)
      else
        model.send(:assign_attributes, attributes)
      end
    end

  end
end
