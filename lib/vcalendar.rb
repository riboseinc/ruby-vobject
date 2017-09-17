require 'vobject'
require 'vobject/component'
require 'vobject/vcalendar/grammar'
require 'json'


#class Vcalendar < Vobject::Component
#
  #attr_accessor :version
#
  #class << self
#
#
    #private
    #
    #def raise_invalid_parsing
      #raise "iCal parse failed"
    #end
  #end
#
  #def parse(vcf)
      #return Vobject::Component::Vcalendar.parse(vcf)
  #end
#
  #def initialize version
	  #puts "AAA"
    #return Vobject::Component::Vcalendar.new :VCALENDAR, {:VERSION => {:value => version}}
  #end
  #
  #private
  #
  #def name
    #:VCALENDAR
  #end
  #
  #
#end



class Vcalendar < Vobject::Component

  attr_accessor :comp_name, :children, :version

  class << self
	  def blank version
	  return self.new :VCALENDAR, {:VERSION => {:value => version}}
	  end
    def parse(vcf)
      hash = Vobject::Vcalendar::Grammar.parse(vcf)
      comp_name = hash.keys.first

      return self.new comp_name, hash[comp_name]
    end

  end

    def initialize key, cs
	    super key, cs  
=begin
    self.comp_name = key
    raise_invalid_initialization if key != name

    self.children = []
    if cs.kind_of?(Array)
    	cs.each do |component|
		c = []
    		component.each_key do |key|
      			val = component[key]
      			# iteration of array or hash values is making the value a key!
      			next if key.class == Array
      			next if key.class == Hash 
        		cc = child_class(key, val)
        		c << cc.new(key, val)
    		end
		self.children << c
    	end
    else
    		cs.each_key do |key|
      			val = cs[key]
      			# iteration of array or hash values is making the value a key!
      			next if key.class == Array
      			next if key.class == Hash 
        		cc = child_class(key, val)
        		self.children << cc.new(key, val)
    		end
    end
=end
    end

  def child_class key, val
    if key == :VTODO
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
    elsif key == :VAVAILABILITY
	    base_class = Vobject::Component::Vcalendar::Vavailability
    elsif key == :AVAILABLE
	    base_class = Vobject::Component::Vcalendar::Vavailability::Available
    elsif !(val.is_a?(Hash) and !val.has_key?(:value) ) 
	    base_class = property_base_class
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
class Vobject::Component::Vcalendar::Vavailability < Vobject::Component::Vcalendar
end
#class Vobject::Component::Vcalendar::Vavailability::Available < Vobject::Component::Vcalendar::Vavailability
#end

