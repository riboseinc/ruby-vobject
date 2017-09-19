require "vobject"
require "vobject/property"
require "vobject/vcalendar/grammar"
require "json"

class Vobject::Component

  attr_accessor :comp_name, :children, :multiple_components, :errors

  def blank version
    return self.ingest :VOBJECT, {:VERSION => {:value => version}}
  end


  def initialize key, cs, err
    self.comp_name = key
    raise_invalid_initialization if key != name
    self.children = []
    if cs.nil?
    else
      cs.each_key do |key|
        val = cs[key]
        # iteration of array || hash values is making the value a key!
        next if key.class == Array
        next if key.class == Hash
        cc = child_class(key, val)
        if val.is_a?(Hash) && val.has_key?(:component)
          val[:component].each do |x|
            self.children << cc.new(key, x, [])
          end
        else
          self.children << cc.new(key, val)
        end
      end
    end
    self.errors = err
  end

  def get_errors
    self.errors
  end

  def child_class key, val
    if val.is_a?(Hash) && val.has_key?(:component)
      base_class = component_base_class
    elsif !(val.is_a?(Hash) && !val.has_key?(:value) )
      base_class = property_base_class
    else
      base_class = component_base_class
    end
    return base_class if key == :CLASS || key == :OBJECT || key == :METHOD
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

  def to_hash
    a = {}
    children.each do |c|
      if c.is_a?(Vobject::Component)
        a = a.merge(c.to_hash) { |key, old, new| [old, new].flatten }
      elsif c.is_a?(Vobject::Property)
        a = a.merge(c.to_hash) { |key, old, new| [old, new].flatten }
      else
        a[c.name] = c.to_hash
      end
    end
    ret = {comp_name => a }
    ret
  end

  def to_json
    self.to_hash.to_json
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


