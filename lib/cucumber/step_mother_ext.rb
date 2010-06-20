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

  class StepMother

    def step_match_with_factory_priority(*args)
      step_match_without_factory_priority(*args)
    rescue Ambiguous => e
      matched_definitions = e.matches.collect(&:step_definition)
      if matched_definitions.size == 2 && (Cucumber::Factory.step_definitions & matched_definitions).any?
        (matched_definitions - Cucumber::Factory.step_definitions).first
      else
        raise
      end
    end

    alias_method_chain :step_match, :factory_priority

  end

end

