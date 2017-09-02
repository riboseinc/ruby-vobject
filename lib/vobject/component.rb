require 'vobject'
require 'vobject/property'
require 'vobject/vcalendar/grammar'
require 'json'

class Vobject::Component

  attr_accessor :comp_name, :children

=begin
  class << self

    def parse(vcf)
      hash = Vobject::Grammar.parse(vcf)
      comp_name = hash.keys.first

      self.new comp_name, hash[comp_name]
    end

    private

    def raise_invalid_parsing
      raise "Vobject component parse failed"
    end

  end
=end

  def initialize key, cs
    self.comp_name = key

    raise_invalid_initialization if key != name

    self.children = []
    cs.each_key do |key|
      val = cs[key]
      # iteration of array or hash values is making the value a key!
      next if key.class == Array
      next if key.class == Hash 

        cc = child_class(key, val)
        self.children << cc.new(key, val)
    end
  end

  def child_class key, val
    if !(val.is_a?(Hash) and !val.has_key?(:value) ) 
	    base_class = property_base_class
    else
	    base_class = Vobject::Component
    end
    return base_class if key == :CLASS or key == :OBJECT or key == :METHOD
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
		a = a.merge c.to_hash
	elsif c.is_a?(Vobject::Property)
		a = a.merge c.to_hash
		#a[c.prop_name] = c.to_hash
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

  private

  def name
    comp_name
  end

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


class Vobject::Component::Vcalendar < Vobject::Component

  attr_accessor :comp_name, :children

  class << self

    def parse(vcf)
      hash = Vobject::Vcalendar::Grammar.parse(vcf)
      comp_name = hash.keys.first

      self.new comp_name, hash[comp_name]
    end


    def initialize key, cs
	    super key, cs  
    end

  def child_class key, val
    if !(val.is_a?(Hash) and !val.has_key?(:value) ) 
	    base_class = property_base_class
    elsif key == :VTODO
	    base_class = Vobject::Component::Vcalendar::ToDo
    elsif key == :VFREEBUSY
	    base_class = Vobject::Component::Vcalendar::FreeBusy
    elsif key == :JOURNAL
	    base_class = Vobject::Component::Vcalendar::Journal
    elsif key == :STANDARD
	    base_class = Vobject::Component::Vcalendar::Timezone::Standard
    elsif key == :DAYLIGHT
	    base_class = Vobject::Component::Vcalendar::Timezone::Daylight
    elsif key == :VTIMEZONE
	    base_class = Vobject::Component::Vcalendar::Timezone
    elsif key == :VEVENT
	    base_class = Vobject::Component::Vcalendar::Event
    elsif key == :VALARM
	    base_class = Vobject::Component::Vcalendar::Alarm
    else
	    base_class = Vobject::Component::Vcalendar
    end
    return base_class if key == :CLASS or key == :OBJECT or key == :METHOD
    camelized_key = key.to_s.downcase.split("_").map(&:capitalize).join("")
    base_class.const_get(camelized_key) rescue base_class
  end

    private

    def raise_invalid_parsing
      raise "Vobject component parse failed"
    end

  end
end




class Vobject::Component::Vcalendar::ToDo < Vobject::Component::Vcalendar
end
class Vobject::Component::Vcalendar::Freebusy < Vobject::Component::Vcalendar
end
class Vobject::Component::Vcalendar::Journal < Vobject::Component::Vcalendar
end
class Vobject::Component::Vcalendar::Timezone < Vobject::Component::Vcalendar
end
class Vobject::Component::Vcalendar::Timezone::Standard < Vobject::Component::Vcalendar::Timezone
end
class Vobject::Component::Vcalendar::Timezone::Daylight < Vobject::Component::Vcalendar::Timezone
end
class Vobject::Component::Vcalendar::Event < Vobject::Component::Vcalendar
end
class Vobject::Component::Vcalendar::Alarm < Vobject::Component::Vcalendar
end

