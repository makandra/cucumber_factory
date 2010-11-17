require File.dirname(__FILE__) + '/spec_helper'

require 'cucumber'
require 'cucumber/rb_support/rb_language'

describe Cucumber::Runtime, 'extended with cucumber_factory' do

  before(:each) do
    prepare_cucumber_example
  end

  describe 'step_match' do

    it "should not raise an ambiguous step error and match the user step if the only other matching step is a factory step" do
      user_step = @main.Given(/^there is a movie with a funny tone/){}
      match = @runtime.step_match('there is a movie with a funny tone')
      match.step_definition.should == user_step
      match.should be_a(Cucumber::StepMatch)
    end

    it "should still raise an ambiguous step error if more than two non-factory steps match" do
      @main.Given(/^there is a movie with (.*?) tone/){}
      @main.Given(/^there is a movie with a funny tone/){}
      expect do
        @runtime.step_match('there is a movie with a funny tone')
      end.to raise_error(Cucumber::Ambiguous)
    end
    
  end

end
