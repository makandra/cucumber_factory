def prepare_cucumber_example
  @runtime = Cucumber::Runtime.new
  language = load_ruby_language
  scenario = double('scenario', :language => 'en')
  language.send(:begin_scenario, scenario)
  @world = language.current_world
  @main = Object.new
  @main.extend(Cucumber::RbSupport::RbDsl)
  Cucumber::Factory.add_steps(@main)
  # @runtime.before(scenario) if @runtime.respond_to?(:before)
  # support_code.apply_before_hooks(scenario) # if @runtime.respond_to?(:apply_before_hooks)
end

def load_ruby_language
  language = support_code.ruby if support_code.respond_to?(:ruby)
  language ||= support_code.load_programming_language('rb')
  language
end

def invoke_cucumber_step(step)
  multiline_argument = Cucumber::MultilineArgument::None.new
  first_step_match(step).invoke(multiline_argument) # nil means no multiline args
end

def support_code
  @runtime.instance_variable_get(:@support_code)
end

def first_step_match(*args)
  support_code.send(:step_matches, *args).first
end
