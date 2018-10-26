class PlainRubyClass
  def initialize(attributes)
    @attributes = attributes
    self.class.last = self
  end

  attr_reader :attributes

  def self.last
    @last
  end

  def self.last=(instance)
    @last = instance
  end

  def self.reset
    @last = nil
  end
end
