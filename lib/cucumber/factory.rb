require 'cucumber/factory/build_strategy'

module Cucumber
  class Factory

    ATTRIBUTES_PATTERN = '( with the .+?)?( (?:which|who|that) is .+?)?'

    NAMED_RECORDS_VARIABLE = :'@named_cucumber_factory_records'

    CLEAR_NAMED_RECORDS_STEP_DESCRIPTOR = {
      :kind => :Before,
      :block => proc { Cucumber::Factory.send(:reset_named_records, self) }
    }

    NAMED_CREATION_STEP_DESCRIPTOR = {
      :kind => :Given,
      :pattern => /^"([^\"]*)" is an? (.+?)( \(.+?\))?#{ATTRIBUTES_PATTERN}?$/,
      # we cannot use vararg blocks here in Ruby 1.8, as explained by Aslak: http://www.ruby-forum.com/topic/182927
      :block => lambda { |a1, a2, a3, a4, a5| Cucumber::Factory.send(:parse_named_creation, self, a1, a2, a3, a4, a5) }
    }

    CREATION_STEP_DESCRIPTOR = {
      :kind => :Given,
      :pattern => /^there is an? (.+?)( \(.+?\))?#{ATTRIBUTES_PATTERN}$/,
       # we cannot use vararg blocks here in Ruby 1.8, as explained by Aslak: http://www.ruby-forum.com/topic/182927
      :block => lambda { |a1, a2, a3, a4| Cucumber::Factory.send(:parse_creation, self, a1, a2, a3, a4) }
    }

    class << self

      def add_steps(main)
        add_step(main, CREATION_STEP_DESCRIPTOR)
        add_step(main, NAMED_CREATION_STEP_DESCRIPTOR)
        add_step(main, CLEAR_NAMED_RECORDS_STEP_DESCRIPTOR)
      end

      private

      def add_step(main, descriptor)
        main.instance_eval {
          kind = descriptor[:kind]
          object = send(kind, *[descriptor[:pattern]].compact, &descriptor[:block])
          object.overridable if kind != :Before
          object
        }
      end

      def reset_named_records(world)
        world.instance_variable_set(NAMED_RECORDS_VARIABLE, {})
      end

      def named_records(world)
        hash = world.instance_variable_get(NAMED_RECORDS_VARIABLE)
        hash || reset_named_records(world)
      end

      def get_named_record(world, name)
        named_records(world)[name].tap do |record|
          record.reload if record.respond_to?(:reload) and record.respond_to?(:new_record?) and not record.new_record?
        end
      end

      def set_named_record(world, name, record)
        named_records(world)[name] = record
      end
  
      def parse_named_creation(world, name, raw_model, raw_variant, raw_attributes, raw_boolean_attributes)
        record = parse_creation(world, raw_model, raw_variant, raw_attributes, raw_boolean_attributes)
        set_named_record(world, name, record)
      end
    
      def parse_creation(world, raw_model, raw_variant, raw_attributes, raw_boolean_attributes)
        build_strategy = BuildStrategy.from_prose(raw_model, raw_variant)
        model_class = build_strategy.model_class
        attributes = {}
        if raw_attributes.try(:strip).present?
          raw_attributes.scan(/(?:the |and |with |but |,| )+(.*?) ("([^\"]*)"|above)/).each do |fragment|
            attribute = attribute_name_from_prose(fragment[0])
            value_type = fragment[1] # 'above' or a quoted string
            value = fragment[2] # the value string without quotes
            attributes[attribute] = attribute_value(world, model_class, attribute, value_type, value)
          end
        end
        if raw_boolean_attributes.try(:strip).present?
          raw_boolean_attributes.scan(/(?:which|who|that|is| )*(not )?(.+?)(?: and | but |,|$)+/).each do |fragment|
            flag = !fragment[0] # if the word 'not' didn't match above, this expression is true
            attribute = attribute_name_from_prose(fragment[1])
            attributes[attribute] = flag
          end
        end
        record = build_strategy.create_record(attributes)
        remember_record_names(world, record, attributes)
        record
      end

      def attribute_value(world, model_class, attribute, value_type, value)
        association = model_class.respond_to?(:reflect_on_association) ? model_class.reflect_on_association(attribute) : nil
        if association.present?
          if value_type == "above"
            value = CucumberFactory::Switcher.find_last(association.klass) or raise "There is no last #{attribute}"
          else
            value = get_named_record(world, value) || world.Transform(value)
          end
        else
          value = world.Transform(value)
        end
        value
      end

      def attribute_name_from_prose(prose)
        prose.downcase.gsub(" ", "_").to_sym
      end

      def remember_record_names(world, record, attributes)
        string_values = attributes.values.select { |v| v.is_a?(String) }
        for string_value in string_values
          set_named_record(world, string_value, record)
        end
      end

    end
  end
end
