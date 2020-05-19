require 'spec_helper'

TRANSFORMS_SUPPORTED = Cucumber::VERSION < '3'

describe 'steps provided by cucumber_factory' do
  before(:each) do
    prepare_cucumber_example
  end

  context 'FactoryBot' do
    it "should create ActiveRecord models by calling #new and #save!" do
      movie = Movie.new
      Movie.should_receive(:new).with(no_args).and_return(movie)
      movie.should_receive(:save!)
      invoke_cucumber_step("there is a movie")
    end

    it "should create models that have a factory_bot factory by calling #FactoryBot.create(:model_name)" do
      FactoryBot.should_receive(:create).with(:job_offer, { :title => "Awesome job" })
      invoke_cucumber_step('there is a job offer with the title "Awesome job"')
    end

    it "should create model variants that have a factory_bot factory by calling #FactoryBot.create(:variant)" do
      FactoryBot.should_receive(:create).with(:job_offer, :tempting_job_offer, { :title => "Awesomafiablyfantasmic job" })
      invoke_cucumber_step('there is a job offer (tempting job offer) with the title "Awesomafiablyfantasmic job"')
    end

    it "should create model variants that have a factory_bot trait by calling #FactoryBot.create(:factory, :trait1, :trait2)" do
      FactoryBot.should_receive(:create).with(:job_offer, :risky, :lucrative, { :title => "Awesomafiablyfantasmic job" })
      invoke_cucumber_step('there is a job offer (risky, lucrative) with the title "Awesomafiablyfantasmic job"')
    end

    it "should create model variants that have a factory_bot factory by using the model name as a factory name" do
      FactoryBot.should_receive(:create).with(:job_offer, { :title => "Awesomafiablyfantasmic job" })
      invoke_cucumber_step('there is a job offer with the title "Awesomafiablyfantasmic job"')
    end

    it "should instantiate classes with multiple words in their name" do
      job_offer = JobOffer.new
      JobOffer.should_receive(:new).with(no_args).and_return(job_offer)
      invoke_cucumber_step("there is a job offer")
    end

    it "should instantiate classes with uppercase characters in their name" do
      user = User.new
      User.should_receive(:new).and_return(user)
      invoke_cucumber_step("there is a User")
    end

    it "should allow either 'a' or 'an' for the article" do
      opera = Opera.new
      Opera.should_receive(:new).with(no_args).and_return(opera)
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

    if TRANSFORMS_SUPPORTED
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

    it "should allow to set an explicit primary key" do
      invoke_cucumber_step('there is a payment with the ID 2')
      payment = Payment.last
      payment.id.should == 2
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

    it "should allow to set a belongs_to association to a previously created record by refering to their explicitely set primary keys" do
      invoke_cucumber_step('there is a movie with the ID 123')
      invoke_cucumber_step('there is a movie with the title "Before Sunset" and the prequel 123')
      movie = Movie.find_by_title!('Before Sunset')
      prequel = Movie.find(123)
      movie.prequel.should == prequel
    end

    it "should allow to set a belongs_to association to a previously created record by saying 'above'" do
      invoke_cucumber_step('there is a user with the name "Jane"')
      invoke_cucumber_step('there is a user with the name "John"')
      invoke_cucumber_step('there is a movie with the title "Limitless"')
      invoke_cucumber_step('there is a movie with the title "Before Sunrise"')
      invoke_cucumber_step('there is a movie with the title "Before Sunset" and the reviewer above and the prequel above')
      before_sunset = Movie.find_by_title!("Before Sunset")
      before_sunset.prequel.title.should == "Before Sunrise"
      before_sunset.reviewer.name.should == "John"
    end

    if TRANSFORMS_SUPPORTED
      it "should fallback to using transforms when no named record is found" do
        user = User.create!(:name => 'Me')
        @main.instance_eval do
          Transform(/^(me)$/) do |value|
            user
          end
        end
        invoke_cucumber_step('there is a movie with the title "Before Sunset" and the reviewer "me"')
        before_sunset = Movie.find_by_title!("Before Sunset")
        before_sunset.reviewer.should == user
      end
    end

    it "should give created_at precedence over id when saying 'above' if the primary key is not numeric" do
      invoke_cucumber_step('there is a uuid user with the name "Jane" and the id "jane"')
      invoke_cucumber_step('there is a uuid user with the name "John" and the id "john"')
      UuidUser.find_by_name("John").update_attributes!(:created_at => 1.day.ago)
      invoke_cucumber_step('there is a movie with the title "Before Sunset" and the uuid reviewer above')
      before_sunset = Movie.find_by_title!("Before Sunset")
      before_sunset.uuid_reviewer.name.should == "Jane"
    end

    it "should ignore created_at if the primary key is numeric" do
      invoke_cucumber_step('there is a user with the name "Jane"')
      invoke_cucumber_step('there is a user with the name "John"')
      User.find_by_name("John").update_attributes!(:created_at => 1.day.ago)
      invoke_cucumber_step('there is a movie with the title "Before Sunset" and the reviewer above')
      before_sunset = Movie.find_by_title!("Before Sunset")
      before_sunset.reviewer.name.should == "John"
    end

    it "should raise a proper error if there is no previous record when saying 'above'" do
      lambda do
        invoke_cucumber_step('there is a movie with the title "Before Sunset" and the reviewer above and the prequel above')
      end.should raise_error(/There is no last reviewer/i)
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
      user.deleted.should == true
    end

    it "should allow to set positive boolean attributes with 'which' after the attribute list" do
      user = User.new
      User.stub(:new => user)
      invoke_cucumber_step('there is a user with the name "Jane" which is deleted')
      user.name.should == "Jane"
      user.deleted.should == true
    end

    it "should allow to set positive boolean attributes with 'that' after the attribute list" do
      user = User.new
      User.stub(:new => user)
      invoke_cucumber_step('there is a user with the name "Jane" that is deleted')
      user.name.should == "Jane"
      user.deleted.should == true
    end

    it "should allow to set boolean attributes without regular attributes preceding them" do
      user = User.new
      User.stub(:new => user)
      invoke_cucumber_step('there is a user who is deleted')
      user.deleted.should == true
    end

    it "should allow to set negative boolean attribute" do
      user = User.new
      User.stub(:new => user)
      invoke_cucumber_step('there is a user who is not deleted')
      user.deleted.should == false
    end

    it "should allow to set multiple boolean attributes" do
      user = User.new
      User.stub(:new => user)
      invoke_cucumber_step('there is a user who is locked and not deleted and subscribed')
      user.locked.should == true
      user.deleted.should == false
      user.subscribed.should == true
    end

    it "should allow to set boolean attributes that are named from multiple words" do
      user = User.new
      User.stub(:new => user)
      invoke_cucumber_step('there is a user who is locked and not scared and scared by spiders and deleted')
      user.locked.should == true
      user.scared.should == false
      user.scared_by_spiders.should == true
      user.deleted.should == true
    end

    it "should allow to join boolean attribute lists with 'and's, commas and 'but's" do
      user = User.new
      User.stub(:new => user)
      invoke_cucumber_step('there is a user who is locked, scared, but scared by spiders and deleted')
      user.locked.should == true
      user.scared.should == true
      user.scared_by_spiders.should == true
      user.deleted.should == true
    end

    it "should allow to set a has_many association by refering to multiple named records in square brackets" do
      invoke_cucumber_step('there is a movie with the title "Sunshine"')
      invoke_cucumber_step('there is a movie with the title "Limitless"')
      invoke_cucumber_step('there is a user with the reviewed movies ["Sunshine" and "Limitless"]')
      user = User.last
      reviewed_movie_titles = user.reviewed_movies.map(&:title)
      reviewed_movie_titles.should =~ ['Sunshine', 'Limitless']
    end

    it 'allow associations for transient attributes if they are named after the associated model' do
      invoke_cucumber_step('there is a movie with the title "Sunshine"')
      invoke_cucumber_step('there is a user with the movie "Sunshine"')
      user = User.last
      user.reviewed_movies.count.should == 1
      user.reviewed_movies.first.title.should == 'Sunshine'
    end

    it "should allow to set attributes via doc string" do
      user = User.new
      User.stub(:new => user)

      invoke_cucumber_step('there is a user with these attributes:', <<-DOC_STRING)
name: Jane
locked: true
      DOC_STRING

      user.name.should == "Jane"
      user.locked.should == true
    end

    it "should allow to set attributes via additional doc string" do
      user = User.new
      User.stub(:new => user)

      invoke_cucumber_step('there is a user with the email "test@invalid.com" and these attributes:', <<-DOC_STRING)
name: Jane
      DOC_STRING

      user.name.should == "Jane"
      user.email.should == "test@invalid.com"
    end

    it 'should allow named records when setting attributes via doc string' do
      invoke_cucumber_step('"Some Prequel" is a movie with these attributes:', <<-DOC_STRING)
title: Before Sunrise
      DOC_STRING
      invoke_cucumber_step('there is a movie with the title "Limitless"')
      invoke_cucumber_step('there is a movie with the title "Before Sunset" and the prequel "Some Prequel"')
      movie = Movie.find_by_title!('Before Sunset')
      prequel = Movie.find_by_title!('Before Sunrise')
      movie.prequel.should == prequel
    end

    it "should allow to set attributes via data table" do
      user = User.new
      User.stub(:new => user)

      invoke_cucumber_step('there is a user with these attributes:', nil, <<-DATA_TABLE)
| name   | Jane |
| locked | true |
      DATA_TABLE

      user.name.should == "Jane"
      user.locked.should == true
    end

    it "should allow to set attributes via additional data table" do
      user = User.new
      User.stub(:new => user)

      invoke_cucumber_step('there is a user with the email "test@invalid.com" and these attributes:', nil, <<-DATA_TABLE)
| name | Jane |
      DATA_TABLE

      user.name.should == "Jane"
      user.email.should == "test@invalid.com"
    end

    it 'should allow named records when setting attributes via data table' do
      invoke_cucumber_step('"Some Prequel" is a movie with these attributes:', nil, <<-DATA_TABLE)
| title | Before Sunrise |
      DATA_TABLE
      invoke_cucumber_step('there is a movie with the title "Limitless"')
      invoke_cucumber_step('there is a movie with the title "Before Sunset" and the prequel "Some Prequel"')
      movie = Movie.find_by_title!('Before Sunset')
      prequel = Movie.find_by_title!('Before Sunrise')
      movie.prequel.should == prequel
    end

    it "should allow mixed single quotes for model names" do
      invoke_cucumber_step("'Some Prequel' is a movie with the title \"Before Sunrise\"")
      invoke_cucumber_step('there is a movie with the title "Limitless"')
      invoke_cucumber_step('there is a movie with the title \'Before Sunset\' and the prequel "Some Prequel"')
      movie = Movie.find_by_title!('Before Sunset')
      prequel = Movie.find_by_title!('Before Sunrise')
      movie.prequel.should == prequel
    end

    it 'supports named associations with polymorphic associations' do
      invoke_cucumber_step('"my opera" is an opera')
      invoke_cucumber_step('there is a movie with the premiere site "my opera"')
    end

    it 'does not support last record references with polymorphic associations as the target class cannot be guessed' do
      invoke_cucumber_step('there is an opera')
      expect {
        invoke_cucumber_step('there is a movie with the premiere site above')
      }.to raise_error(CucumberFactory::Factory::Error, 'Cannot set last Movie#premiere_site for polymorphic associations')
    end
  end

  context 'without FactoryBot' do
    before do
      hide_const("FactoryBot")
    end

    it "should instantiate plain ruby classes by calling #new" do
      PlainRubyClass.should_receive(:new).with({})
      invoke_cucumber_step("there is a plain ruby class")
    end

    it "should instantiate namespaced classes" do
      actor = People::Actor.new
      People::Actor.should_receive(:new).and_return(actor)
      invoke_cucumber_step("there is a people/actor")
    end

    it "should allow to set integer attributes without surrounding quotes" do
      invoke_cucumber_step('there is a plain Ruby class with the amount 123 and the total 456')
      obj = PlainRubyClass.last
      obj.attributes[:amount].should == 123
      obj.attributes[:total].should == 456
    end

    it "should allow to set decimal attributes without surrounding quotes" do
      invoke_cucumber_step('there is a plain Ruby class with the amount 1.23 and the total 45.6')
      obj = PlainRubyClass.last
      obj.attributes[:amount].should be_a(BigDecimal)
      obj.attributes[:amount].to_s.should == "1.23"
      obj.attributes[:total].should be_a(BigDecimal)
      obj.attributes[:total].to_s.should == "45.6"
    end

    it "should allow set an array of strings with square brackets" do
      invoke_cucumber_step('there is a plain Ruby class with the tags ["foo", "bar"] and the list ["bam", "baz"]')
      obj = PlainRubyClass.last
      obj.attributes[:tags].should == ['foo', 'bar']
      obj.attributes[:list].should == ['bam', 'baz']
    end

    it "should allow set an array of numbers with square brackets" do
      invoke_cucumber_step('there is a plain Ruby class with the integers [1, 2] and the decimals [3.4, 4.5]')
      obj = PlainRubyClass.last
      obj.attributes[:integers].should == [1, 2]
      obj.attributes[:decimals].should == [BigDecimal('3.4'), BigDecimal('4.5')]
    end

    it 'should allow to set an empty array' do
      invoke_cucumber_step('there is a plain Ruby class with the tags []')
      obj = PlainRubyClass.last
      obj.attributes[:tags].should == []
    end

    it 'should allow to separate array values with either a comma or "and"' do
      invoke_cucumber_step('there is a plain Ruby class with the tags ["foo", "bar" and "baz"] and the list ["bam", "baz" and "qux"]')
      obj = PlainRubyClass.last
      obj.attributes[:tags].should == ['foo', 'bar', 'baz']
      obj.attributes[:list].should == ['bam', 'baz', 'qux']
    end

    it 'should allow to separate array values with an Oxford comma' do
      invoke_cucumber_step('there is a plain Ruby class with the tags ["foo", "bar", and "baz"] and the list ["bam", "baz", and "qux"]')
      obj = PlainRubyClass.last
      obj.attributes[:tags].should == ['foo', 'bar', 'baz']
      obj.attributes[:list].should == ['bam', 'baz', 'qux']
    end

    it "should allow attribute names starting with 'the'" do
      PlainRubyClass.should_receive(:new).with({:theme => 'Sci-fi'})
      invoke_cucumber_step('there is a plain ruby class with the theme "Sci-fi"')
    end

    it "should allow attribute names starting with 'and'" do
      PlainRubyClass.should_receive(:new).with({:android => 'Paranoid'})
      invoke_cucumber_step('there is a plain ruby class with the android "Paranoid"')
    end

    it "should allow attribute names starting with 'with'" do
      PlainRubyClass.should_receive(:new).with({:withdrawal => 'bank_account'})
      invoke_cucumber_step('there is a plain ruby class with the withdrawal "bank_account"')
    end

    it "should allow attribute names starting with 'but'" do
      PlainRubyClass.should_receive(:new).with({:butt => 'pear-shaped'})
      invoke_cucumber_step('there is a plain ruby class with the butt "pear-shaped"')
    end

    it "should allow to set array attributes via doc string" do
      invoke_cucumber_step('there is a plain Ruby class with these attributes:', <<-DOC_STRING)
tags: ["foo", "bar"]
      DOC_STRING

      obj = PlainRubyClass.last
      obj.attributes[:tags].should == ['foo', 'bar']
    end

    it "should allow to set array attributes via data table" do
      invoke_cucumber_step('there is a plain Ruby class with these attributes:', nil, <<-DATA_TABLE)
| tags | ["foo", "bar"] |
      DATA_TABLE

      obj = PlainRubyClass.last
      obj.attributes[:tags].should == ['foo', 'bar']
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

    it "should allow single quote for attribute values" do
      MachinistModel.should_receive(:make).with({ :attribute => "foo"})
      invoke_cucumber_step("there is a machinist model with the attribute 'foo'")
    end

    it "should allow mixed single and double quotes for different attribute values" do
      MachinistModel.should_receive(:make).with({ :attribute => "foo", :other_attribute => "bar" })
      invoke_cucumber_step("there is a machinist model with the attribute 'foo' and the other attribute \"bar\"")
    end

    it 'should not raise an error for a blank instance name' do
      MachinistModel.should_receive(:make).with({ :attribute => 'foo' })
      invoke_cucumber_step("'' is a machinist model with the attribute 'foo'")
    end

    it 'should warn if there are unused fragments' do
      MachinistModel.should_not_receive(:make)
      lambda { invoke_cucumber_step("there is a machinist model with the attribute NOQUOTES") }.should raise_error(ArgumentError, 'Unable to parse attributes " with the attribute NOQUOTES".')
      lambda { invoke_cucumber_step("there is a machinist model with the attribute 'foo' and the ") }.should raise_error(ArgumentError, 'Unable to parse attributes " and the ".')
      lambda { invoke_cucumber_step("there is a machinist model with the attribute 'foo'. the other_attribute 'bar' and the third attribute 'baz'") }.should raise_error(ArgumentError, 'Unable to parse attributes ".".')
    end
  end
end
