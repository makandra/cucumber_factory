module Cucumber
  class Factory

    # wraps machinist / factory_girl / ruby object logic

    class BuildStrategy

      class << self

        def from_prose(model_prose, variant_prose)
          # don't use \w which depends on the system locale
          underscored_model_name = model_prose.gsub(/[^A-Za-z0-9_\/]+/, "_")
          if variant_prose.present?
            variants = /\((.*?)\)/.match(variant_prose)[1].split(/\s*,\s*/)
            variants = variants.collect { |variant| variant.downcase.gsub(" ", "_") }
          else
            variants = []
          end

          if factory_girl_strategy = factory_girl_strategy(underscored_model_name, variants)
            factory_girl_strategy
          else
            model_class = underscored_model_name.camelize.constantize
            machinist_strategy(model_class, variants) ||
              active_record_strategy(model_class) ||
              ruby_object_strategy(model_class)
          end
        end

        private

        def factory_girl_strategy(factory_name, variants)
          return unless defined?(::FactoryGirl)
          variants = variants.map(&:to_sym)
          factory_name = factory_name.to_s.underscore.gsub('/', '_').to_sym

          factory = ::FactoryGirl.factories[factory_name]

          if factory.nil? && variants.present? && factory = ::FactoryGirl.factories[variants[0]]
            factory_name, *variants = variants
          end

          if factory
            new(factory.build_class) do |attributes|
              ::FactoryGirl.create(factory_name, *variants, attributes)
            end
          end

        end

        def machinist_strategy(model_class, variants)
          if model_class.respond_to?(:make)

            new(model_class) do |attributes|
              if variants.present?
                variants.size == 1 or raise 'Machinist only supports a single variant per blueprint'
                model_class.make(variants.first.to_sym, attributes)
              else
                model_class.make(attributes)
              end
            end

          end
        end

        def active_record_strategy(model_class)
          if model_class.respond_to?(:create!)

            new(model_class) do |attributes|
              model = model_class.new
              CucumberFactory::Switcher.assign_attributes(model, attributes)
              model.save!
              model
            end

          end
        end

        def ruby_object_strategy(model_class)
          new(model_class) do |attributes|
            model_class.new(attributes)
          end
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
end
