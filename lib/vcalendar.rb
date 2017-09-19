require "vobject"
require "vobject/component"
require "vobject/vcalendar/component"
require "vobject/vcalendar/grammar"
require "json"

class Vcalendar < Vobject::Component

  attr_accessor :comp_name, :children, :version

  class << self

    def parse(vcf, strict)
      #hash = Vobject::Vcalendar::Grammar.new(strict).parse(vcf)
      hash = Vobject::Component::Vcalendar.parse(vcf, strict)
      #comp_name = hash.keys.first

      #self.new(comp_name, hash[comp_name], hash[:errors] )
      hash
    end

  end

  def initialize key, cs, err
    super key, cs, err
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
    elsif !(val.is_a?(Hash) && !val.has_key?(:value) )
      base_class = property_base_class
    else
      base_class = Vobject::Component::Vcalendar
    end
    return base_class if key == :CLASS || key == :OBJECT || key == :METHOD
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

