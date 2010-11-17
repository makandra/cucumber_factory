require 'cucumber/step_mother'

module Cucumber

  class Ambiguous

    attr_reader :matches

    def initialize_with_remembering_matches(step_name, matches, *args)
      @matches = matches
      initialize_without_remembering_matches(step_name, matches, *args)
    end

    alias_method_chain :initialize, :remembering_matches

  end

  (defined?(Runtime) ? Runtime : StepMother).class_eval do

    def step_match_with_factory_priority(*args)
      step_match_without_factory_priority(*args)
    rescue Ambiguous => e
      non_factory_matches = e.matches.reject do |match|
        Cucumber::Factory.step_definitions.include?(match.step_definition)
      end
      if non_factory_matches.size == 1
        non_factory_matches.first
      else
        raise
      end
    end

    alias_method_chain :step_match, :factory_priority

  end

end
