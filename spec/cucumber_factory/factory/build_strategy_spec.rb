require 'spec_helper'

describe CucumberFactory::BuildStrategy do

  # most of the behaviour is integration tested in steps_spec.rb

  describe '.from_prose' do

    context 'when describing a factory_bot factory' do
      it 'returns a strategy and transient attributes corresponding to the factories model' do
        strategy, transient_attributes = described_class.from_prose('job offer', nil)

        strategy.should be_a(described_class)
        strategy.model_class.should == JobOffer
        transient_attributes.should == [:my_transient_attribute]
      end

      it 'uses the variant for the factory name if present' do
        strategy, transient_attributes = described_class.from_prose('job offer', '(tempting_job_offer)')

        strategy.should be_a(described_class)
        strategy.model_class.should == JobOffer
        transient_attributes.should == [:my_transient_attribute, :other_transient_attribute]
      end
    end

    context 'when describing a non factory_bot model' do
      before do
        hide_const("FactoryBot")
      end

      it "should return a strategy for the class matching a natural language expression" do
        described_class.from_prose("movie", nil).first.model_class.should == Movie
        described_class.from_prose("job offer", nil).first.model_class.should == JobOffer
      end

      it "should ignore variants for the class name" do
        described_class.from_prose("movie", "(job offer)").first.model_class.should == Movie
      end

      it "should allow namespaced models" do
        described_class.from_prose("people/actor", nil).first.model_class.should == People::Actor
      end
    end

  end

  describe '.class_from_factory' do
    it 'returns the class associated with a factory_bot factory' do
      described_class.class_from_factory('film').should == Movie
    end
  end

end
