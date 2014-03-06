require 'spec_helper'

require_relative 'cucumber_helper'
require 'cucumber'
require 'cucumber/rb_support/rb_language'

class FactoryGirl # for factory_girl compatibility spec
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
    invoke_cucumber_step("there is a movie")
  end

  it "should create models that have a machinist blueprint by calling #make" do
    MachinistModel.should_receive(:make).with({ :attribute => "foo"})
    invoke_cucumber_step('there is a machinist model with the attribute "foo"')
  end

  it "should be able to step_match machinist blueprint variants" do
    MachinistModel.should_receive(:make).with(:variant, { :attribute => "foo"})
    invoke_cucumber_step('there is a machinist model (variant) with the attribute "foo"')
  end

  it "should be able to step_match machinist blueprint variants containing spaces or uppercase characters in prose" do
    MachinistModel.should_receive(:make).with(:variant_mark_two, { :attribute => "foo"})
    invoke_cucumber_step('there is a machinist model (Variant Mark Two) with the attribute "foo"')
  end

  it "should create models that have a factory_girl factory by calling #FactoryGirl.create(:model_name)" do
    FactoryGirl.should_receive(:factories).with().and_return({ :job_offer => :job_offer_factory }) # Fake factory look up in factory_girl
    FactoryGirl.should_receive(:create).with(:job_offer, { :title => "Awesome job" })
    invoke_cucumber_step('there is a job offer with the title "Awesome job"')
  end

  it "should create model variants that have a factory_girl factory by calling #FactoryGirl.create(:variant_name)" do
    FactoryGirl.should_receive(:factories).with().and_return({ :tempting_job_offer => :tempting_job_offer_factory }) # Fake factory look up in factory_girl
    FactoryGirl.should_receive(:create).with(:tempting_job_offer, { :title => "Awesomafiablyfantasmic job" })
    invoke_cucumber_step('there is a job offer (tempting job offer) with the title "Awesomafiablyfantasmic job"')
  end

  it "should instantiate plain ruby classes by calling #new" do
    PlainRubyClass.should_receive(:new).with({})
    invoke_cucumber_step("there is a plain ruby class")
  end

  it "should instantiate classes with multiple words in their name" do
    JobOffer.should_receive(:new).with({})
    invoke_cucumber_step("there is a job offer")
  end

  it "should instantiate classes with uppercase characters in their name" do
    user = User.new
    User.should_receive(:new).and_return(user)
    invoke_cucumber_step("there is a User")
  end

  it "should instantiate namespaced classes" do
    actor = People::Actor.new
    People::Actor.should_receive(:new).and_return(actor)
    invoke_cucumber_step("there is a people/actor")
  end

  it "should allow either 'a' or 'an' for the article" do
    Opera.should_receive(:new).with({})
    invoke_cucumber_step("there is an opera")
  end

  it "should create records with attributes" do
    movie = Movie.new
    Movie.stub(:new => movie)
    invoke_cucumber_step('there is a movie with the title "Sunshine" and the year "2007"')
    movie.title.should == "Sunshine"
    movie.year.should == 2007
  end

  it "should allow to join attribute lists with 'and's, commas and 'but's" do
    movie = Movie.new
    Movie.stub(:new => movie)
    invoke_cucumber_step('there is a movie with the title "Sunshine", the year "2007" but with the box office result "32000000"')
    movie.title.should == "Sunshine"
    movie.year.should == 2007
    movie.box_office_result.should == 32000000
  end

  it "should apply Cucumber transforms to attribute values" do
    movie = Movie.new
    Movie.stub(:new => movie)
    @main.instance_eval do
      Transform /^(value)$/ do |value|
        'transformed value'
      end
    end
    invoke_cucumber_step('there is a movie with the title "value"')
    movie.title.should == "transformed value"
  end

  it "should create records with attributes containing spaces" do
    movie = Movie.new
    Movie.stub(:new => movie)
    invoke_cucumber_step('there is a movie with the box office result "99999999"')
    movie.box_office_result.should == 99999999
  end

  it "should create records with attributes containing uppercase characters" do
    user = User.new
    User.stub(:new => user)
    invoke_cucumber_step('there is a User with the Name "Susanne"')
    user.name.should == "Susanne"
  end

  it "should override attr_accessible protection" do
    invoke_cucumber_step('there is a payment with the amount "120" and the comment "Thanks for lending"')
    payment = Payment.last
    payment.amount.should == 120
    payment.comment.should == 'Thanks for lending'
  end

  it "should allow to name records and set a belongs_to association to that record by refering to that name" do
    invoke_cucumber_step('"Some Prequel" is a movie with the title "Before Sunrise"')
    invoke_cucumber_step('there is a movie with the title "Limitless"')
    invoke_cucumber_step('there is a movie with the title "Before Sunset" and the prequel "Some Prequel"')
    movie = Movie.find_by_title!('Before Sunset')
    prequel = Movie.find_by_title!('Before Sunrise')
    movie.prequel.should == prequel
  end

  it "should allow to set a belongs_to association to a previously created record by refering to any string attribute of that record" do
    invoke_cucumber_step('there is a movie with the title "Before Sunrise"')
    invoke_cucumber_step('there is a movie with the title "Limitless"')
    invoke_cucumber_step('there is a movie with the title "Before Sunset" and the prequel "Before Sunrise"')
    movie = Movie.find_by_title!('Before Sunset')
    prequel = Movie.find_by_title!('Before Sunrise')
    movie.prequel.should == prequel
  end

  it "should allow to set a belongs_to association to a previously created record by saying 'above'" do
    invoke_cucumber_step('there is a user with the name "Jane"')
    invoke_cucumber_step('there is a movie with the title "Limitless"')
    invoke_cucumber_step('there is a movie with the title "Before Sunrise"')
    invoke_cucumber_step('there is a movie with the title "Before Sunset" and the reviewer above and the prequel above')
    before_sunset = Movie.find_by_title!("Before Sunset")
    before_sunset.prequel.title.should == "Before Sunrise"
    before_sunset.reviewer.name.should == "Jane"
  end

  it "should reload an object assigned to a belongs_to before assigning" do
    invoke_cucumber_step('"Jane" is a user who is deleted')
    User.last.update_attributes(:deleted => false)
    proc { invoke_cucumber_step('there is a movie with the title "Before Sunset" and the reviewer "Jane"') }.should_not raise_error
  end

  it "should allow to set positive boolean attributes with 'who' after the attribute list" do
    user = User.new
    User.stub(:new => user)
    invoke_cucumber_step('there is a user with the name "Jane" who is deleted')
    user.name.should == "Jane"
    user.deleted.should be_true
  end

  it "should allow to set positive boolean attributes with 'which' after the attribute list" do
    user = User.new
    User.stub(:new => user)
    invoke_cucumber_step('there is a user with the name "Jane" which is deleted')
    user.name.should == "Jane"
    user.deleted.should be_true
  end

  it "should allow to set positive boolean attributes with 'that' after the attribute list" do
    user = User.new
    User.stub(:new => user)
    invoke_cucumber_step('there is a user with the name "Jane" that is deleted')
    user.name.should == "Jane"
    user.deleted.should be_true
  end

  it "should allow to set boolean attributes without regular attributes preceding them" do
    user = User.new
    User.stub(:new => user)
    invoke_cucumber_step('there is a user who is deleted')
    user.deleted.should be_true
  end

  it "should allow to set negative boolean attribute" do
    user = User.new
    User.stub(:new => user)
    invoke_cucumber_step('there is a user who is not deleted')
    user.deleted.should be_false
  end

  it "should allow to set multiple boolean attributes" do
    user = User.new
    User.stub(:new => user)
    invoke_cucumber_step('there is a user who is locked and not deleted and subscribed')
    user.locked.should be_true
    user.deleted.should be_false
    user.subscribed.should be_true
  end

  it "should allow to set boolean attributes that are named from multiple words" do
    user = User.new
    User.stub(:new => user)
    invoke_cucumber_step('there is a user who is locked and not scared and scared by spiders and deleted')
    user.locked.should be_true
    user.scared.should be_false
    user.scared_by_spiders.should be_true
    user.deleted.should be_true
  end

  it "should allow to join boolean attribute lists with 'and's, commas and 'but's" do
    user = User.new
    User.stub(:new => user)
    invoke_cucumber_step('there is a user who is locked, scared, but scared by spiders and deleted')
    user.locked.should be_true
    user.scared.should be_true
    user.scared_by_spiders.should be_true
    user.deleted.should be_true
  end

end
