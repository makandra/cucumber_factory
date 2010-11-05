module Cucumber
  module Factory
    class << self

      ATTRIBUTES_PATTERN = '( with the .+?)?( (?:which|who|that) is .+?)?'

      # List of Cucumber step definitions created by #add_steps
      attr_reader :step_definitions

      def add_steps(main)
        @step_definitions = []
        steps.each do |step|
          @step_definitions << (main.instance_eval do
            Given(step[:pattern], &step[:action])
          end)
        end
      end

      def steps
        # we cannot use vararg blocks here in Ruby 1.8, as explained by Aslak: http://www.ruby-forum.com/topic/182927
        [ { :pattern => /^"([^\"]*)" is an? (.+?)( \(.+?\))?#{ATTRIBUTES_PATTERN}?$/,
            :action => lambda { |a1, a2, a3, a4, a5| Cucumber::Factory.parse_named_creation(self, a1, a2, a3, a4, a5) } },
          { :pattern => /^there is an? (.+?)( \(.+?\))?#{ATTRIBUTES_PATTERN}$/,
            :action => lambda { |a1, a2, a3, a4| Cucumber::Factory.parse_creation(self, a1, a2, a3, a4) } } ]
      end
  
      def parse_named_creation(world, name, raw_model, raw_variant, raw_attributes, raw_boolean_attributes)
        record = parse_creation(world, raw_model, raw_variant, raw_attributes, raw_boolean_attributes)
        variable = variable_name_from_prose(name)
        world.instance_variable_set variable, record
      end
    
      def parse_creation(world, raw_model, raw_variant, raw_attributes, raw_boolean_attributes)
        model_class = model_class_from_prose(raw_model)
        attributes = {}
        if raw_attributes.try(:strip).present?
          raw_attributes.scan(/(?:the|and|with|but|,| )+(.*?) ("([^\"]*)"|above)/).each do |fragment|
            attribute = attribute_name_from_prose(fragment[0])
            value_type = fragment[1] # 'above' or a quoted string
            value = fragment[2] # the value string without quotes
            attributes[attribute] = attribute_value(world, model_class, attribute, value_type, value)
          end
        end
        if raw_boolean_attributes.try(:strip).present?
          raw_boolean_attributes.scan(/(?:which|who|that|is| )*(not )?(.+?)(?: and | but |,|$)+/).each do |fragment|
            flag = !fragment[0] # if not ain't there, this is true
            attribute = attribute_name_from_prose(fragment[1])
            attributes[attribute] = flag
          end
        end
        variant = raw_variant.present? && /\((.*?)\)/.match(raw_variant)[1].downcase.gsub(" ", "_")
        create_record(model_class, variant, attributes)
      end

      private

      def attribute_value(world, model_class, attribute, value_type, value)
        association = model_class.respond_to?(:reflect_on_association) ? model_class.reflect_on_association(attribute) : nil
        if association.present?
          if value_type == "above"
            # Don't use class.last, in sqlite that is not always the last inserted element
            value = association.klass.find(:last, :order => "id") or raise "There is no last #{attribute}"
          else
            value = world.instance_variable_get(variable_name_from_prose(value))
          end
        else
          value = world.Transform(value)
        end
        value
      end

      def attribute_name_from_prose(prose)
        prose.downcase.gsub(" ", "_").to_sym
      end

      def model_class_from_prose(prose)
        # don't use \w which depends on the system locale
        prose.gsub(/[^A-Za-z0-9_\/]+/, "_").camelize.constantize
      end
      
      def variable_name_from_prose(prose)
        # don't use \w which depends on the system locale
        name = prose.downcase.gsub(/[^A-Za-z0-9_]+/, '_')
        name = name.gsub(/^_+/, '').gsub(/_+$/, '')
        name = "_#{name}" unless name.length >= 0 && name =~ /^[a-z]/
        :"@#{name}"
      end
      
      def factory_girl_factory_name(model_class)
        model_class.to_s.underscore.to_sym
      end
      
      def create_record(model_class, variant, attributes)
        factory_name = factory_girl_factory_name(model_class)
        if defined?(::Factory) && factory = ::Factory.factories[factory_name]
          ::Factory.create(factory_name, attributes)
        elsif model_class.respond_to?(:make) # Machinist blueprint
          if variant.present?
            model_class.make(variant.to_sym, attributes)
          else
            model_class.make(attributes)
          end
        elsif model_class.respond_to?(:create!) # Plain ActiveRecord
          model = model_class.new
          model.send(:attributes=, attributes, false) # ignore attr_accessible
          model.save!
          model
        else
          model_class.new(attributes)
        end
      end

    end
  end
end
