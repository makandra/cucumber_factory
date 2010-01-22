module Cucumber
  module Factory
  
    def self.add_steps(world)
      steps.each do |step|
        world.instance_eval do
          Given(step[0], &step[1].bind(world))
        end
      end
    end
    
    def self.steps
      [
        [
          /^"([^\"]*)" is an? (.+?)( \(.+?\))?( with the .+?)?$/, 
          lambda { |name, raw_model, raw_variant, raw_attributes| Cucumber::Factory.parse_named_creation(self, name, raw_model, raw_variant, raw_attributes) }
        ],
        [
          /^there is an? (.+?)( \(.+?\))?( with the .+?)?$/,
          lambda { |raw_model, raw_variant, raw_attributes| Cucumber::Factory.parse_creation(self, raw_model, raw_variant, raw_attributes) }
        ]
      ]
    end
    
    def self.parse(world, command)
      command = command.sub(/^When |Given |Then /, "")
      steps.each do |step|
        match = step[0].match(command)
        if match
          step[1].bind(world).call(*match.captures)
          return
        end
      end
      raise "No step definition for: #{command}"
    end
    
    def self.parse_named_creation(world, name, raw_model, raw_variant, raw_attributes)
      record = parse_creation(world, raw_model, raw_variant, raw_attributes)
      variable = variable_name_from_prose(name)
      world.instance_variable_set variable, record
    end
  
    def self.parse_creation(world, raw_model, raw_variant, raw_attributes)
      model_class = model_class_from_prose(raw_model)
      attributes = {}
      if raw_attributes.present? && raw_attributes.strip.present?
        raw_attributes.scan(/(the|and|with| )+(.*?) ("([^\"]*)"|above)/).each do |fragment|
          value = nil
          attribute = fragment[1].downcase.gsub(" ", "_").to_sym
          value_type = fragment[2] # 'above' or a quoted string
          value = fragment[3]
          association = model_class.reflect_on_association(attribute) if model_class.respond_to?(:reflect_on_association)
          if association.present?
            if value_type == "above"
              value = association.klass.last or raise "There is no last #{attribute}"
            else
              value = world.instance_variable_get(variable_name_from_prose(value))
            end
          end
          attributes[attribute] = value
        end
      end
      variant = raw_variant.present? && /\((.*?)\)/.match(raw_variant)[1]
      create_record(model_class, variant, attributes)
    end
    
    def self.model_class_from_prose(prose)
      # don't use \w which depends on the system locale
      prose.gsub(/[^A-Za-z0-9_]+/, "_").camelize.constantize
    end
    
    def self.variable_name_from_prose(prose)
      # don't use \w which depends on the system locale
      name = prose.downcase.gsub(/[^A-Za-z0-9_]+/, '_')
      name = name.gsub(/^_+/, '').gsub(/_+$/, '')
      name = "_#{name}" unless name.length >= 0 && name =~ /^[a-z]/
      :"@#{name}"
    end
    
    private
    
    def self.factory_girl_factory_name(model_class)
      model_class.to_s.underscore.to_sym
    end
    
    def self.create_record(model_class, variant, attributes)
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
