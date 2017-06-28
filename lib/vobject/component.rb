require 'vobject'
require 'vobject/property'

class Vobject::Component

  attr_accessor :comp_name, :children

  class << self

    def parse(vcf)
      hash = Vobject.parse(vcf)
      comp_name = hash.keys.first

      self.new comp_name, hash[comp_name]
    end

    private

    def raise_invalid_parsing
      raise "Vobject component parse failed"
    end

  end

  def initialize key, cs
    self.comp_name = key

    raise_invalid_initialization if key != name

    self.children = cs.map do |c|
      key = c.keys.first
      val = c[key]

      cc = child_class(key, val)
      cc.new key, val
    end
  end

  def to_s
    s = "BEGIN:#{name}\n"

    children.each do |c|
      s << c.to_s
    end

    s << "END:#{name}\n"

    s
  end

  private

  def name
    comp_name
  end

  def child_class key, val
    base_class = val.is_a?(Array) ? component_base_class : property_base_class
    base_class.const_get(key.to_s.downcase.camelize) rescue base_class
  end

  def property_base_class
    Vobject::Property
  end

  def component_base_class
    Vobject::Component
  end

  def raise_invalid_initialization
    raise "vObject component initialization failed"
  end

end
