require "vobject"
require "vobject/propertyvalue"

module Vcard::V3_0
  module PropertyValue

    class Text < Vobject::PropertyValue

      class << self
        def escape x
          # temporarily escape \\ as \u007f, which is banned from text
          x.gsub(/\\/, "\u007f").gsub(/\n/, "\\n").gsub(/,/, "\\,").gsub(/;/, "\\;").gsub(/\u007f/, "\\\\")
        end

        def listencode x
          if x.is_a?(Array)
            ret = x.map { |m| Text.escape m}.join(",")
          elsif x.nil? || x.empty?
            ret = ""
          else
            ret = Text.escape x
          end
          ret
        end
      end

      def initialize(val)
        self.value = val
        self.type = "text"
      end

      def to_s
        Text.escape self.value
      end

      def to_hash
        self.value
      end

    end

    class ClassValue < Text
      def initialize(val)
        self.value = val
        self.type = "classvalue"
      end

      def to_hash
        self.value
      end

    end

    class Profilevalue < Text
      def initialize(val)
        self.value = val
        self.type = "profilevalue"
      end

      def to_hash
        self.value
      end

    end

    class Kindvalue < Text
      def initialize(val)
        self.value = val
        self.type = "kindvalue"
      end

      def to_hash
        self.value
      end

    end

    class Ianatoken < Text
      def initialize(val)
        self.value = val
        self.type = "ianatoken"
      end

      def to_hash
        self.value
      end

    end

    class Binary < Text
      def initialize(val)
        self.value = val
        self.type = "binary"
      end

      def to_hash
        self.value
      end

    end

    class Phonenumber < Text
      def initialize(val)
        self.value = val
        self.type = "phonenumber"
      end

      def to_hash
        self.value
      end

    end

    class Uri < Text
      def initialize(val)
        self.value = val
        self.type = "uri"
      end

      def to_hash
        self.value
      end

      def to_s
        self.value
      end

    end

    class Float < Vobject::PropertyValue
      include Comparable
      def <=>(anOther)
        self.value <=> anOther.value
      end

      def initialize(val)
        self.value = val
        self.type = "float"
      end

      def to_s
        self.value
      end

      def to_hash
        self.value
      end

    end

    class Integer < Vobject::PropertyValue
      include Comparable
      def <=>(anOther)
        self.value <=> anOther.value
      end

      def initialize(val)
        self.value = val
        self.type = "integer"
      end

      def to_s
        self.value.to_s
      end

      def to_hash
        self.value
      end

    end

    class Date < Vobject::PropertyValue
      include Comparable
      def <=>(anOther)
        self.value <=> anOther.value
      end

      def initialize(val)
        self.value = val
        self.type = "date"
      end

      def to_s
        sprintf("%04d-%02d-%02d", self.value[:year].to_i, self.value[:month].to_i, self.value[:day].to_i)
      end

      def to_hash
        self.value
      end

    end

    class DateTimeLocal < Vobject::PropertyValue
      include Comparable
      def <=>(anOther)
        self.value[:time] <=> anOther.value[:time]
      end

      def initialize(val)
        self.value = val.clone
        # val consists of :time && :zone values. If :zone is empty, floating local time (i.e. system local time) is assumed
        self.type = "datetimeLocal"
        val[:sec] += (val[:secfrac].to_f / (10 ** val[:secfrac].length)) if !val[:secfrac].nil? && !val[:secfrac].empty?
        if val[:zone].nil? || val[:zone].empty?
          self.value[:time] = ::Time.local(val[:year], val[:month], val[:day], val[:hour], val[:min], val[:sec])
        else
          self.value[:time] = ::Time.utc(val[:year], val[:month], val[:day], val[:hour], val[:min], val[:sec])
        end
        self.value[:origtime] = self.value[:time]
        if val[:zone] && val[:zone] != "Z"
          offset = val[:zone][:hour].to_i*3600 + val[:zone][:min].to_i*60
          offset += val[:zone][:sec].to_i if val[:zone][:sec]
          offset = -offset if val[:sign] == "-"
          self.value[:time] += offset.to_i
        end
      end

      def to_s
        localtime = self.value[:origtime]
        ret = sprintf("%04d-%02d-%02dT%02d:%02d:%02d", localtime.year, localtime.month, localtime.day,
                      localtime.hour, localtime.min, localtime.sec)
        ret = ret + ",.#{self.value[:secfrac]}" if self.value[:secfrac]
        zone = "Z" if self.value[:zone] && self.value[:zone] == "Z"
        zone = "#{self.value[:zone][:sign]}#{self.value[:zone][:hour]}:#{self.value[:zone][:min]}" if self.value[:zone] && self.value[:zone].is_a?(Hash)
        ret = ret + zone
        ret
      end


      def to_hash
        ret = {
          :year => self.value[:year],
          :month => self.value[:month],
          :day => self.value[:day],
          :hour => self.value[:hour],
          :min => self.value[:min],
          :sec => self.value[:sec],
        }
        ret[:zone] = self.value[:zone] if self.value[:zone]
        ret
      end

    end

    class Time < Vobject::PropertyValue

      def initialize(val)
        self.value = val
        self.type = "time"
      end

      def to_s
        ret = "#{self.value[:hour]}:#{self.value[:min]}:#{self.value[:sec]}"
        ret = ret + ".#{self.value[:secfrac]}" if self.value[:secfrac]
        zone = ""
        zone = "Z" if self.value[:zone] && self.value[:zone] == "Z"
        zone = "#{self.value[:zone][:sign]}#{self.value[:zone][:hour]}:#{self.value[:zone][:min]}" if self.value[:zone] && self.value[:zone].is_a?(Hash)
        ret = ret + zone
        ret
      end

      def to_hash
        self.value
      end

    end

    class Utcoffset < Vobject::PropertyValue

      def initialize(val)
        self.value = val
        self.type = "utcoffset"
      end

      def to_s
        ret = "#{self.value[:sign]}#{self.value[:hour]}:#{self.value[:min]}"
        #ret += self.value[:sec] if self.value[:sec]
        ret
      end

      def to_hash
        self.value
      end

    end

    class Geovalue < Vobject::PropertyValue

      def initialize(val)
        self.value = val
        self.type = "geovalue"
      end

      def to_s
        ret = "#{self.value[:lat]};#{self.value[:long]}"
        ret
      end

      def to_hash
        self.value
      end

    end

    class Version < Vobject::PropertyValue

      def initialize(val)
        self.value = val
        self.type = "version"
      end

      def to_s
        self.value
      end

      def to_hash
        self.value
      end

    end

    class Org < Vobject::PropertyValue
      def initialize(val)
        self.value = val
        self.type = "org"
      end

      def to_s
        self.value.map { |m| Text.escape m}.join(";")
      end

      def to_hash
        self.value
      end

    end

    class Fivepartname < Vobject::PropertyValue
      def initialize(val)
        self.value = val
        self.type = "fivepartname"
      end

      def to_s
        ret = Text.listencode self.value[:surname]
        ret += ";#{Text.listencode self.value[:givenname]}" if !self.value[:givenname].empty? || !self.value[:middlename].empty? || !self.value[:honprefix].empty? || !self.value[:honsuffix].empty?
        ret += ";#{Text.listencode self.value[:middlename]}" if !self.value[:middlename].empty? || !self.value[:honprefix].empty?
        ret += ";#{Text.listencode self.value[:honprefix]}" if !self.value[:honprefix].empty? || !self.value[:honsuffix].empty?
        ret += ";#{Text.listencode self.value[:honsuffix]}" if !self.value[:honsuffix].empty?
        ret
      end

      def to_hash
        self.value
      end

    end

    class Address < Vobject::PropertyValue
      def initialize(val)
        self.value = val
        self.type = "address"
      end

      def to_s
        ret = Text.listencode self.value[:pobox]
        ret += ";#{Text.listencode self.value[:ext]}" if !self.value[:ext].empty? || !self.value[:street].empty? || !self.value[:locality].empty? || !self.value[:region].empty? || !self.value[:code].empty? || !self.value[:country].empty?
        ret += ";#{Text.listencode self.value[:street]}" if !self.value[:street].empty? || !self.value[:locality].empty? || !self.value[:region].empty? || !self.value[:code].empty? || !self.value[:country].empty?
        ret += ";#{Text.listencode self.value[:locality]}" if !self.value[:locality].empty? || !self.value[:region].empty? || !self.value[:code].empty? || !self.value[:country].empty?
        ret += ";#{Text.listencode self.value[:region]}" if !self.value[:region].empty? || !self.value[:code].empty? || !self.value[:country].empty?
        ret += ";#{Text.listencode self.value[:code]}" if !self.value[:code].empty? || !self.value[:country].empty?
        ret += ";#{Text.listencode self.value[:country]}" if !self.value[:country].empty?
        ret
      end

      def to_hash
        self.value
      end

    end

    class Textlist < Vobject::PropertyValue
      def initialize(val)
        self.value = val
        self.type = "textlist"
      end

      def to_s
        self.value.map { |m| Text.escape m}.join(",")
      end

      def to_hash
        self.value
      end

    end

    class Agent < Vobject::PropertyValue
      def initialize(val)
        val[:VCARD].delete(:VERSION)
        self.value = val
        self.type = "agent"
      end

      def to_hash
        ret = {}
        self.value.each{ |k, v|
          ret[k] = {}
          v.each{ |k1, v1|
            if v1.is_a?(Hash)
              ret[k][k1] = {	}
              v1.each { |k2, v2|
                ret[k][k1][k2] = v2.to_hash
              }
            else
              ret[k][k1] = v1
            end
          }
        }
        ret
      end

      def to_s
        ret = Vobject::Component.new(:VCARD, self.value[:VCARD], []).to_s
        # spec says that colons must be expected, but none of the examples do
        ret.gsub(/\n/,"\\n").gsub(/,/,"\\,").gsub(/;/,"\\;")
        #ret.gsub(/\n/,"\\n").gsub(/:/,"\\:")
      end

    end

  end

end
