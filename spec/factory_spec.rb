require File.dirname(__FILE__) + '/spec_helper'

describe Cucumber::Factory do

  describe 'add_steps' do
  
    it "should add Given rules to the world" do
      world = mock('world').as_null_object
      world.should_receive(:Given).exactly(2).times
      Cucumber::Factory.add_steps(world)
    end
    
  end
  
  describe 'model_class_from_prose' do

    it "should return the class matching a natural language expression" do
      Cucumber::Factory.model_class_from_prose("movie").should == Movie
      Cucumber::Factory.model_class_from_prose("job offer").should == JobOffer
    end

  end

  describe 'variable_name_from_prose' do
  
    it "should translate natural language to instance variable names" do
      Cucumber::Factory.variable_name_from_prose("movie").should == :'@movie'
      Cucumber::Factory.variable_name_from_prose("Some Movie").should == :'@some_movie'
    end
    
    it "should make sure the generated instance variable names are legal" do
      Cucumber::Factory.variable_name_from_prose("1973").should == :'@_1973'
      Cucumber::Factory.variable_name_from_prose("%$§").should == :'@_'
    end
    
  end

end
