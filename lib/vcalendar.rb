require "vobject"
require "vobject/component"
require "vobject/vcalendar/component"
require "vobject/vcalendar/grammar"
require "json"

class Vcalendar < Vobject::Component
  attr_accessor :comp_name, :children, :version

  class << self
    def parse(vcf, strict)
      Vobject::Component::Vcalendar.parse(vcf, strict)
    end
  end

  def initialize(key, cs, err)
    super key, cs, err
  end

  def child_class(key, val)
    base_class = if key == :VTODO
                   Vobject::Component::Vcalendar::ToDo
                 elsif key == :VFREEBUSY
                   Vobject::Component::Vcalendar::FreeBusy
                 elsif key == :JOURNAL
                   Vobject::Component::Vcalendar::Journal
                 elsif key == :STANDARD
                   Vobject::Component::Vcalendar::Timezone::Standard
                 elsif key == :DAYLIGHT
                   Vobject::Component::Vcalendar::Timezone::Daylight
                 elsif key == :VTIMEZONE
                   Vobject::Component::Vcalendar::Timezone
                 elsif key == :VEVENT
                   Vobject::Component::Vcalendar::Event
                 elsif key == :VALARM
                   Vobject::Component::Vcalendar::Alarm
                 elsif key == :VAVAILABILITY
                   Vobject::Component::Vcalendar::Vavailability
                 elsif key == :AVAILABLE
                   Vobject::Component::Vcalendar::Vavailability::Available
                 elsif !(val.is_a?(Hash) && !val.has_key?(:value))
                   property_base_class
                 else
                   Vobject::Component::Vcalendar
                 end
    return base_class if [:CLASS, :OBJECT, :METHOD].include?
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
# class Vobject::Component::Vcalendar::Vavailability::Available < Vobject::Component::Vcalendar::Vavailability
# end
