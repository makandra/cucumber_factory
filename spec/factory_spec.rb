require File.dirname(__FILE__) + '/spec_helper'

class Factory # for factory_girl compatibility spec
  def self.factories
    {}
  end  
end

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
  
  describe 'parse' do

    before(:each) do
      @world = Object.new
    end
  
    it "should create ActiveRecord models by calling #new and #save!" do
      movie = Movie.new
      Movie.should_receive(:new).with().and_return(movie)
      movie.should_receive(:save!)
      Cucumber::Factory.parse(@world, "Given there is a movie")
    end
    
    it "should create models that have a machinist blueprint by calling #make" do
      MachinistModel.should_receive(:make).with({ :attribute => "foo"})
      Cucumber::Factory.parse(@world, 'Given there is a machinist model with the attribute "foo"')
    end
    
    it "should create models that have a factory_girl factory by calling #Factory.make(:model_name)" do
      Factory.should_receive(:factories).with().and_return({ :job_offer => :job_offer_factory }) # Fake factory look up in factory_girl
      Factory.should_receive(:create).with(:job_offer, { :title => "Awesome job" })
      Cucumber::Factory.parse(@world, 'Given there is a job offer with the title "Awesome job"')
    end
    
    it "should instantiate plain ruby classes by calling #new" do
      PlainRubyClass.should_receive(:new).with({})
      Cucumber::Factory.parse(@world, "Given there is a plain ruby class")
    end
  
    it "should instantiate classes with multiple words in their name" do
      JobOffer.should_receive(:new).with({})
      Cucumber::Factory.parse(@world, "Given there is a job offer")
    end
  
    it "should instantiate classes with uppercase characters in their name" do
      user = User.new
      User.should_receive(:new).and_return(user)
      Cucumber::Factory.parse(@world, "Given there is a User")
    end
  
    it "should allow either 'a' or 'an' for the article" do
      Opera.should_receive(:new).with({})
      Cucumber::Factory.parse(@world, "Given there is an opera")
    end
    
    it "should create records with attributes" do
      movie = Movie.new
      Movie.stub(:new => movie)
      movie.should_receive(:"attributes=").with({ :title => "Sunshine", :year => "2007" }, false)
      Cucumber::Factory.parse(@world, 'Given there is a movie with the title "Sunshine" and the year "2007"')
    end
    
    it "should create records with attributes containing spaces" do
      movie = Movie.new
      Movie.stub(:new => movie)
      movie.should_receive(:"attributes=").with({ :box_office_result => "99999999" }, false)
      Cucumber::Factory.parse(@world, 'Given there is a movie with the box office result "99999999"')
    end

    it "should create records with attributes containing uppercase characters" do
      user = User.new
      User.stub(:new => user)
      user.should_receive(:"attributes=").with({ :name => "Susanne" }, false)
      Cucumber::Factory.parse(@world, 'Given there is a User with the Name "Susanne"')
    end
        
    it "should override attr_accessible protection" do
      Cucumber::Factory.parse(@world, 'Given there is a payment with the amount "120" and the comment "Thanks for lending"')
      payment = Payment.last
      payment.amount.should == 120
      payment.comment.should == 'Thanks for lending'
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
