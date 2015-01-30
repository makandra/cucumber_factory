module Cucumber
  class Factory

    # wraps machinist / factory_girl / ruby object logic

    class BuildStrategy

      class << self

        def from_prose(model_prose, variant_prose)
          # don't use \w which depends on the system locale
          underscored_model_name = model_prose.gsub(/[^A-Za-z0-9_\/]+/, "_")
          variant = variant_prose.present? && /\((.*?)\)/.match(variant_prose)[1].downcase.gsub(" ", "_")

          if factory_girl_strategy = factory_girl_strategy(variant || underscored_model_name)
            factory_girl_strategy
          else
            model_class = underscored_model_name.camelize.constantize
            machinist_strategy(model_class, variant) ||
              active_record_strategy(model_class) ||
              ruby_object_strategy(model_class)
          end
        end

        private

        def factory_girl_strategy(factory_name)
          return unless defined?(::FactoryGirl)

          factory_name = factory_name.to_s.underscore.gsub('/', '_').to_sym
          if factory = ::FactoryGirl.factories[factory_name]

            new(factory.build_class) do |attributes|
              ::FactoryGirl.create(factory.name, attributes)
            end

          end
        end

        def machinist_strategy(model_class, variant)
          if model_class.respond_to?(:make)

            new(model_class) do |attributes|
              if variant.present?
                model_class.make(variant.to_sym, attributes)
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
