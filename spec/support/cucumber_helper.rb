def prepare_cucumber_example
  @runtime = Cucumber::Runtime.new
  language = @runtime.load_programming_language('rb')
  scenario = double('scenario', :language => 'en', :accept_hook? => true)
  language.send(:begin_scenario, scenario)
  @world = language.current_world
  @main = Object.new
  @main.extend(Cucumber::RbSupport::RbDsl)
  Cucumber::Factory.add_steps(@main)
  @runtime.before(scenario)
end

def invoke_cucumber_step(step)
  @runtime.step_match(step).invoke(nil) # nil means no multiline args
end
