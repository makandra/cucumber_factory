require 'spec_helper'

describe CucumberFactory::BuildStrategy do

  subject { CucumberFactory::BuildStrategy }

  # most of the behaviour is integration tested in steps_spec.rb

  describe '.from_prose' do

    context 'when describing a factory_bot factory' do

      it 'returns a strategy corresponding to the factories model' do
        FactoryBot.stub_factories :job_offer => JobOffer
        strategy = subject.from_prose('job offer', nil)

        strategy.should be_a(described_class)
        strategy.model_class.should == JobOffer
      end

      it 'uses the variant for the factory name if present' do
        FactoryBot.stub_factories :job_offer => JobOffer
        strategy = subject.from_prose('foo', '(job offer)')

        strategy.should be_a(described_class)
        strategy.model_class.should == JobOffer
      end

    end

    context 'when describing a non factory_bot model' do

      it "should return a strategy for the class matching a natural language expression" do
        subject.from_prose("movie", nil).model_class.should == Movie
        subject.from_prose("job offer", nil).model_class.should == JobOffer
      end

      it "should ignore variants for the class name" do
        subject.from_prose("movie", "(job offer)").model_class.should == Movie
      end

      it "should allow namespaced models" do
        subject.from_prose("people/actor", nil).model_class.should == People::Actor
      end

    end

  end

end
