module CucumberFactory
  module Switcher
    extend self

    def find_last(klass)
      # Don't use class.last, in sqlite that is not always the last inserted element
      # If created_at is available prefer it over id as column for ordering so that we can handle UUIDs
      primary_key = klass.primary_key
      has_numeric_primary_key = klass.columns_hash[primary_key].type == :integer
      order_column = if has_numeric_primary_key || !klass.column_names.include?('created_at')
        primary_key
      else
        "created_at, #{primary_key}"
      end
      if active_record_version < 4
        klass.find(:last, :order => order_column)
      else
        klass.order(order_column).last
      end
    end

    def assign_attributes(model, attributes)
      if active_record_version < 3
        model.send(:attributes=, attributes, false) # ignore attr_accessible
      elsif active_record_version < 4
        model.send(:assign_attributes, attributes, :without_protection => true)
      else
        model.send(:assign_attributes, attributes)
      end
    end

    private

    def active_record_version
      ActiveRecord::VERSION::MAJOR
    end

  end
end
