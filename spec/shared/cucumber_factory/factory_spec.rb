require 'spec_helper'

describe Cucumber::Factory do

  subject { Cucumber::Factory }

  describe 'model_class_from_prose' do

    it "should return the class matching a natural language expression" do
      subject.send(:model_class_from_prose, "movie").should == Movie
      subject.send(:model_class_from_prose, "job offer").should == JobOffer
    end

    it "should allow namespaced models" do
      subject.send(:model_class_from_prose, "people/actor").should == People::Actor
    end

  end

  describe 'factory_girl_factory_name' do

    it "should underscorize everything" do
      subject.send(:factory_girl_factory_name, People::Actor).should == :people_actor
      subject.send(:factory_girl_factory_name, JobOffer).should == :job_offer
    end

  end

end
