require "vobject"
require "vobject/property"
require "vobject/vcalendar/grammar"
require "json"

class Vobject::Component
  attr_accessor :comp_name, :children, :multiple_components, :errors, :norm

  def <=>(another)
    me = self.to_norm
    o = another.to_norm
    me <=> o
  end

  def blank(version)
    ingest VOBJECT: { VERSION: { value: version } }
  end

  def initialize(key, cs, err)
    self.comp_name = key
    raise_invalid_initialization if key != name
    self.children = []
    if cs.nil?
    else
      cs.each_key do |k|
        val = cs[k]
        # iteration of array || hash values is making the value a key!
        next if k.class == Array
        next if k.class == Hash
        cc = child_class(k, val)
        if val.is_a?(Hash) && val.has_key?(:component)
          val[:component].each do |x|
            children << cc.new(k, x, [])
          end
        else
          children << cc.new(k, val)
        end
      end
    end
    self.errors = err.select { |e| !e.nil? }
    self.norm = nil
  end

  def get_errors
    errors
  end

  def child_class(key, val)
    base_class = if val.is_a?(Hash) && val.has_key?(:component)
                   component_base_class
                 elsif !(val.is_a?(Hash) && !val.has_key?(:value))
                   property_base_class
                 else
                   component_base_class
                 end
    return base_class if [:CLASS, :OBJECT, :METHOD].include? key
    camelized_key = key.to_s.downcase.split("_").map(&:capitalize).join("")
    base_class.const_get(camelized_key) rescue base_class
  end

  def to_s
    s = "BEGIN:#{name}\n"
    children.each do |c|
      s << c.to_s
    end
    s << "END:#{name}\n"
    s
  end

  def to_norm
    if norm.nil?
      s = "BEGIN:#{name.upcase}\n"
      properties = children.select { |c| c.is_a? Vobject::Property }
      components = children.select { |c| not c.is_a? Vobject::Property }
      properties.sort.each { |p| s << p.to_norm }
      components.sort.each { |p| s << p.to_norm }
      s << "END:#{name.upcase}\n"
      norm = s
    end
    norm
  end

  def to_hash
    a = {}
    children.each do |c|
      if c.is_a?(Vobject::Component)
        a = a.merge(c.to_hash) { |_, old, new| [old, new].flatten }
      elsif c.is_a?(Vobject::Property)
        a = a.merge(c.to_hash) { |_, old, new| [old, new].flatten }
      else
        a[c.name] = c.to_hash
      end
    end
    { comp_name => a }
  end

  def to_json
    to_hash.to_json
  end

  def name
    comp_name
  end

  private

  def property_base_class
    Vobject::Property
  end

  def component_base_class
    Vobject::Component
  end

  def parameter_base_class
    Vobject::Parameter
  end

  def raise_invalid_initialization
    raise "vObject component initialization failed"
  end
end
