module CucumberFactory

  class UpdateStrategy

    def initialize(record)
      @record = record
    end

    def assign_attributes(attributes)
      active_record_strategy(attributes) ||
        ruby_object_strategy(attributes)
    end

    private

    def active_record_strategy(attributes)
      return unless @record.respond_to?(:save!)

      CucumberFactory::Switcher.assign_attributes(@record, attributes)
      @record.save!
    end

    def ruby_object_strategy(attributes)
      attributes.each do |name, value|
        @record.send("#{name}=".to_sym, value)
      end
    end

  end
end
