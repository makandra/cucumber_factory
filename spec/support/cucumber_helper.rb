def prepare_cucumber_example
  if Cucumber::VERSION >= '3'
    @runtime = Cucumber::Runtime.new
    scenario = double('scenario', :language => 'en', :accept_hook? => true)
    @runtime.send(:begin_scenario, scenario)
    @main = Object.new
    @main.extend(Cucumber::Glue::Dsl)
  else
    @runtime = Cucumber::Runtime.new
    language = support_code.ruby if support_code.respond_to?(:ruby)
    language ||= support_code.load_programming_language('rb')
    language
    scenario = double('scenario', :language => 'en', :accept_hook? => true)
    language.send(:begin_scenario, scenario)
    @world = language.current_world
    @main = Object.new
    @main.extend(Cucumber::RbSupport::RbDsl)
  end

  Cucumber::Factory.add_steps(@main)
end

def invoke_cucumber_step(step)
  multiline_argument = begin
    Cucumber::MultilineArgument::None.new # Cucumber 2+
  rescue NameError
    nil # Cucumber 1
  end
  first_step_match(step).invoke(multiline_argument) # nil means no multiline args
end

def support_code
  @runtime.instance_variable_get(:@support_code)
end

def first_step_match(*args)
  support_code.send(:step_matches, *args).first
end
