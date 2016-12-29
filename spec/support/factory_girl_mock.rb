class FactoryGirl # for factory_girl compatibility spec

  def self.factories
    {}
  end

  Factory = Struct.new(:name, :build_class)

  def self.stub_factories(hash)
    factories = {}
    hash.each do |name, build_class|
      factories[name] = Factory.new(name, build_class)
    end
    FactoryGirl.stub :factories => factories
  end
end

