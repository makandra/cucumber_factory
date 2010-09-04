require File.dirname(__FILE__) + '/spec_helper'

require 'cucumber'
require 'cucumber/rb_support/rb_language'

class Factory # for factory_girl compatibility spec
  def self.factories
    {}
  end
end

describe 'steps provided by cucumber_factory' do

  before(:each) do
    prepare_cucumber_example
  end

  it "should create ActiveRecord models by calling #new and #save!" do
    movie = Movie.new
    Movie.should_receive(:new).with().and_return(movie)
    movie.should_receive(:save!)
    @step_mother.invoke("there is a movie")
  end

  it "should create models that have a machinist blueprint by calling #make" do
    MachinistModel.should_receive(:make).with({ :attribute => "foo"})
    @step_mother.invoke('there is a machinist model with the attribute "foo"')
  end

  it "should be able to invoke machinist blueprint variants" do
    MachinistModel.should_receive(:make).with(:variant, { :attribute => "foo"})
    @step_mother.invoke('there is a machinist model (variant) with the attribute "foo"')
  end

  it "should be able to invoke machinist blueprint variants containing spaces or uppercase characters in prose" do
    MachinistModel.should_receive(:make).with(:variant_mark_two, { :attribute => "foo"})
    @step_mother.invoke('there is a machinist model (Variant Mark Two) with the attribute "foo"')
  end

  it "should create models that have a factory_girl factory by calling #Factory.make(:model_name)" do
    Factory.should_receive(:factories).with().and_return({ :job_offer => :job_offer_factory }) # Fake factory look up in factory_girl
    Factory.should_receive(:create).with(:job_offer, { :title => "Awesome job" })
    @step_mother.invoke('there is a job offer with the title "Awesome job"')
  end

  it "should instantiate plain ruby classes by calling #new" do
    PlainRubyClass.should_receive(:new).with({})
    @step_mother.invoke("there is a plain ruby class")
  end

  it "should instantiate classes with multiple words in their name" do
    JobOffer.should_receive(:new).with({})
    @step_mother.invoke("there is a job offer")
  end

  it "should instantiate classes with uppercase characters in their name" do
    user = User.new
    User.should_receive(:new).and_return(user)
    @step_mother.invoke("there is a User")
  end

  it "should allow either 'a' or 'an' for the article" do
    Opera.should_receive(:new).with({})
    @step_mother.invoke("there is an opera")
  end

  it "should create records with attributes" do
    movie = Movie.new
    Movie.stub(:new => movie)
    movie.should_receive(:"attributes=").with({ :title => "Sunshine", :year => "2007" }, false)
    @step_mother.invoke('there is a movie with the title "Sunshine" and the year "2007"')
  end

  it "should apply Cucumber transforms to attribute values" do
    movie = Movie.new
    Movie.stub(:new => movie)
    @world.should_receive(:Transform).with("value").and_return("transformed value")
    movie.should_receive(:"attributes=").with({ :title => "transformed value" }, false)
    @step_mother.invoke('there is a movie with the title "value"')
  end

  it "should create records with attributes containing spaces" do
    movie = Movie.new
    Movie.stub(:new => movie)
    movie.should_receive(:"attributes=").with({ :box_office_result => "99999999" }, false)
    @step_mother.invoke('there is a movie with the box office result "99999999"')
  end

  it "should create records with attributes containing uppercase characters" do
    user = User.new
    User.stub(:new => user)
    user.should_receive(:"attributes=").with({ :name => "Susanne" }, false)
    @step_mother.invoke('there is a User with the Name "Susanne"')
  end

  it "should override attr_accessible protection" do
    @step_mother.invoke('there is a payment with the amount "120" and the comment "Thanks for lending"')
    payment = Payment.last
    payment.amount.should == 120
    payment.comment.should == 'Thanks for lending'
  end

  it "should set instance variables in the world" do
    @step_mother.invoke('"Sunshine" is a movie with the title "Sunshine" and the year "2007"')
    @world.instance_variable_get(:'@sunshine').title.should == "Sunshine"
  end

  it "should understand pointers to instance variables" do
    @step_mother.invoke('"Before Sunrise" is a movie with the title "Before Sunrise"')
    @step_mother.invoke('"Before Sunset" is a movie with the title "Before Sunset" and the prequel "Before Sunrise"')
    @world.instance_variable_get(:'@before_sunset').prequel.title.should == "Before Sunrise"
  end

  it "should allow to point to a previously created record through 'above'" do
    @step_mother.invoke('there is a user with the name "Jane"')
    @step_mother.invoke('there is a movie with the title "Before Sunrise"')
    @step_mother.invoke('there is a movie with the title "Before Sunset" and the reviewer above and the prequel above')
    before_sunset = Movie.find_by_title!("Before Sunset")
    before_sunset.prequel.title.should == "Before Sunrise"
    before_sunset.reviewer.name.should == "Jane"
  end

  it "should allow to set positive boolean attributes with which/who after the attribute list" do
    @step_mother.invoke('there is a user with the name "Jane" who is deleted')
    @step_mother.invoke('there is a user with the name "Jack" which is deleted')
    jane = User.find_by_name!('Jane')
    jane.name.should == 'Jane'
    jane.deleted.should equal(true)
    jack = User.find_by_name!('Jack')
    jack.name.should == 'Jack'
    jack.deleted.should equal(true)
  end

  it "should allow to set boolean attributes without regular attributes preceding them" do
    @step_mother.invoke('there is a user who is deleted')
    jane = User.find(:last, :order => 'id')
    jane.deleted.should equal(true)
  end

  it "should allow to set negative boolean attribute" do
    @step_mother.invoke('there is a user who is not deleted')
    jane = User.find(:last, :order => 'id')
    jane.deleted.should equal(false)
  end

  it "should allow to set multiple boolean attributes" do
    @step_mother.invoke('there is a user who is locked and not deleted and subscribed')
    jane = User.find(:last, :order => 'id')
    jane.locked.should equal(true)
    jane.deleted.should equal(false)
    jane.subscribed.should equal(true)
  end

  it "should allow to set boolean attributes that are named from multiple words" do
    @step_mother.invoke('there is a user who is locked and not scared and scared by spiders and deleted')
    jane = User.find(:last, :order => 'id')
    jane.locked.should equal(true)
    jane.scared.should equal(false)
    jane.scared_by_spiders.should equal(true)
    jane.deleted.should equal(true)
  end

end
