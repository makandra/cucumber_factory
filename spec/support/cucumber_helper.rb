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

  add_steps_filepath = File.expand_path(File.join(File.dirname(__FILE__), '../../lib/cucumber_factory/add_steps.rb'))
  @main.instance_eval(File.read(add_steps_filepath))
end

def invoke_cucumber_step(step, doc_string = nil, data_table = nil)
  if Cucumber::VERSION >= '2'
    multiline_argument = Cucumber::MultilineArgument::None.new

    if doc_string.present?
      multiline_argument = Cucumber::MultilineArgument::DocString.new(doc_string)
    end

    if data_table.present?
      multiline_argument = Cucumber::MultilineArgument::DataTable.from(data_table)
    end
  else
    multiline_argument = nil

    if doc_string.present?
      multiline_argument =  Cucumber::Ast::DocString.new(doc_string, '')
    end

    if data_table.present?
      multiline_argument = Cucumber::Ast::Table.parse(data_table, nil, nil)
    end
  end

  first_step_match(step).invoke(multiline_argument)
end

def support_code
  @runtime.instance_variable_get(:@support_code)
end

def first_step_match(*args)
  support_code.send(:step_matches, *args).first
end
