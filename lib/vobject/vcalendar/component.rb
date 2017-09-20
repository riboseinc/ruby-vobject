require "vobject"
require "vobject/property"
require "vobject/vcalendar/grammar"
require "json"

class Vobject::Component::Vcalendar < Vobject::Component
  attr_accessor :comp_name, :children

  class << self
    def parse(vcf, strict)
      hash = Vobject::Vcalendar::Grammar.new(strict).parse(vcf)
      comp_name = hash.keys.first

      new comp_name, hash[comp_name], hash[:errors]
    end

    def initialize(key, cs)
      # super key, cs
      self.comp_name = key
      raise_invalid_initialization if key != name

      self.children = []
      if cs.is_a?(Array)
        cs.each do |component|
          c = []
          component.each_key do |k|
            val = component[k]
            # iteration of array || hash values is making the value a key!
            next if k.class == Array
            next if k.class == Hash
            cc = child_class(k, val)
            c << cc.new(k, val)
          end
          children << c
        end
      else
        cs.each_key do |k|
          val = cs[k]
          # iteration of array || hash values is making the value a key!
          next if k.class == Array
          next if k.class == Hash
          cc = child_class(k, val)
          children << cc.new(k, val)
        end
      end
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
      return base_class if [:CLASS, :OBJECT, :METHOD].include? key
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
class Vobject::Component::Vcalendar::Vavailability < Vobject::Component::Vcalendar
end
class Vobject::Component::Vcalendar::Vavailability::Available < Vobject::Component::Vcalendar
end
