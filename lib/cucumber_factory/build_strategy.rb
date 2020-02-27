module CucumberFactory

  # wraps machinist / factory_bot / ruby object logic

  class BuildStrategy

    class << self

      def from_prose(model_prose, variant_prose)
        variants = variants_from_prose(variant_prose)
        factory = factory_bot_factory(model_prose, variants)

        if factory
          strategy = factory_bot_strategy(factory, model_prose, variants)
          transient_attributes = factory_bot_transient_attributes(factory, variants)
        else
          strategy = alternative_strategy(model_prose, variants)
          transient_attributes = []
        end

        [strategy, transient_attributes]
      end

      private

      def variants_from_prose(variant_prose)
        if variant_prose.present?
          variants = /\((.*?)\)/.match(variant_prose)[1].split(/\s*,\s*/)
          variants.collect { |variant| variant.downcase.gsub(" ", "_").to_sym }
        else
          []
        end
      end

      def factory_bot_factory(model_prose, variants)
        return unless factory_bot_class

        factory_name = factory_name_from_prose(model_prose)
        factory = factory_bot_class.factories[factory_name]

        if factory.nil? && variants.present?
          factory = factory_bot_class.factories[variants[0]]
        end

        factory
      end

      def factory_bot_strategy(factory, model_prose, variants)
        return unless factory

        factory_name = factory_name_from_prose(model_prose)
        if factory_bot_class.factories[factory_name].nil? && variants.present?
          factory_name, *variants = variants
        end

        new(factory.build_class) do |attributes|
          # Cannot have additional scalar args after a varargs
          # argument in Ruby 1.8 and 1.9
          args = []
          args += variants
          args << attributes
          factory_bot_class.create(factory_name, *args)
        end
      end

      def factory_bot_transient_attributes(factory, variants)
        return [] unless factory

        factory_attributes = factory_bot_attributes(factory, variants)
        class_attributes = factory.build_class.attribute_names.map(&:to_sym)

        factory_attributes - class_attributes
      end

      def factory_bot_attributes(factory, variants)
        traits = factory_bot_traits(factory, variants)
        factory.with_traits(traits.map(&:name)).definition.attributes.names
      end

      def factory_bot_traits(factory, variants)
        factory.definition.defined_traits.select do |trait|
          variants.include?(trait.name.to_sym)
        end
      end

      def alternative_strategy(model_prose, variants)
        model_class = underscored_model_name(model_prose).camelize.constantize
        machinist_strategy(model_class, variants) ||
          active_record_strategy(model_class) ||
          ruby_object_strategy(model_class)
      end

      def machinist_strategy(model_class, variants)
        return unless model_class.respond_to?(:make)

        new(model_class) do |attributes|
          if variants.present?
            variants.size == 1 or raise 'Machinist only supports a single variant per blueprint'
            model_class.make(variants.first, attributes)
          else
            model_class.make(attributes)
          end
        end
      end

      def active_record_strategy(model_class)
        return unless model_class.respond_to?(:create!)

        new(model_class) do |attributes|
          model = model_class.new
          CucumberFactory::Switcher.assign_attributes(model, attributes)
          model.save!
          model
        end
      end

      def ruby_object_strategy(model_class)
        new(model_class) do |attributes|
          model_class.new(attributes)
        end
      end

      def factory_bot_class
        factory_class = ::FactoryBot if defined?(FactoryBot)
        factory_class ||= ::FactoryGirl if defined?(FactoryGirl)
        factory_class
      end

      def factory_name_from_prose(model_prose)
        underscored_model_name(model_prose).to_s.underscore.gsub('/', '_').to_sym
      end

      def underscored_model_name(model_prose)
        # don't use \w which depends on the system locale
        model_prose.gsub(/[^A-Za-z0-9_\/]+/, "_")
      end

    end


    attr_reader :model_class

    def initialize(model_class, &block)
      @model_class = model_class
      @create_proc = block
    end

    def create_record(attributes)
      @create_proc.call(attributes)
    end

  end

end
