module CucumberFactory
  module Switcher
    extend self

    def find_last(klass)
      if Rails::VERSION::MAJOR < 4
        klass.find(:last, :order => "id") or raise "There is no last #{attribute}"
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
