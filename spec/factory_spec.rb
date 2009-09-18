require File.dirname(__FILE__) + '/spec_helper'

describe Cucumber::Factory do

  describe 'add_steps' do
  
    it "should add Given rules to the world" do
      world = mock('world').as_null_object
      world.should_receive(:Given).exactly(2).times
      Cucumber::Factory.add_steps(world)
    end
    
  end

  describe 'variable_name' do
  
    it "should translate natural language to instance variable names" do
      Cucumber::Factory.variable_name("movie").should == :'@movie'
      Cucumber::Factory.variable_name("Some Movie").should == :'@some_movie'
    end
    
    it "should make sure the generated instance variable names are legal" do
      Cucumber::Factory.variable_name("1973").should == :'@_1973'
      Cucumber::Factory.variable_name("%$§").should == :'@_'
    end
    
  end
  
  describe 'parse' do

    before(:each) do
      @world = Object.new
    end
  
    it "should create records" do
      Movie.should_receive(:create!).with({})
      Cucumber::Factory.parse(@world, "Given there is a movie")
    end
    
    it "should create records with attributes" do
      Movie.should_receive(:create!).with({ :title => "Sunshine", :year => "2007" })
      Cucumber::Factory.parse(@world, 'Given there is a movie with the title "Sunshine" and the year "2007"')
    end
    
    it "should create records with attributes containing spaces" do
      Movie.should_receive(:create!).with({ :box_office_result => "99999999" })
      Cucumber::Factory.parse(@world, 'Given there is a movie with the box office result "99999999"')
    end
        
    it "should set instance variables in the world" do
      Cucumber::Factory.parse(@world, 'Given "Sunshine" is a movie with the title "Sunshine" and the year "2007"')
      @world.instance_variable_get(:'@sunshine').title.should == "Sunshine"
    end
    
    it "should understand pointers to instance variables" do
      Cucumber::Factory.parse(@world, 'Given "Before Sunrise" is a movie with the title "Before Sunrise"')
      Cucumber::Factory.parse(@world, 'Given "Before Sunset" is a movie with the title "Before Sunset" and the prequel "Before Sunrise"')
      @world.instance_variable_get(:'@before_sunset').prequel.title.should == "Before Sunrise"
    end
    
    it "should allow to point to a previously created record through 'above'" do
      Cucumber::Factory.parse(@world, 'Given there is a user with the name "Jane"')
      Cucumber::Factory.parse(@world, 'Given there is a movie with the title "Before Sunrise"')
      Cucumber::Factory.parse(@world, 'Given there is a movie with the title "Before Sunset" and the reviewer above and the prequel above')
      @before_sunset = Movie.find_by_title!("Before Sunset")
      @before_sunset.prequel.title.should == "Before Sunrise"
      @before_sunset.reviewer.name.should == "Jane"
    end
    
  end

end
