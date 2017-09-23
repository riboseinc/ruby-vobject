require "vobject"
require "vobject/propertyvalue"

module Vcard::V3_0
  module PropertyValue
    class Text < Vobject::PropertyValue
      class << self
        def escape(x)
          # temporarily escape \\ as \u007f, which is banned from text
          x.tr("\\", "\u007f").gsub(/\n/, "\\n").gsub(/,/, "\\,").gsub(/;/, "\\;").gsub(/\u007f/, "\\\\")
        end

        def listencode(x)
          ret = if x.is_a?(Array)
                  x.map { |m| Text.escape m }.join(",")
                elsif x.nil? || x.empty?
                  ""
                else
                  Text.escape x
                end
          ret
        end
      end

      def initialize(val)
        self.value = val
        self.type = "text"
      end

      def to_s
        Text.escape value
      end

      def to_hash
        value
      end
    end

    class ClassValue < Text
      def initialize(val)
        self.value = val
        self.type = "classvalue"
      end

      def to_hash
        value
      end
    end

    class Profilevalue < Text
      def initialize(val)
        self.value = val
        self.type = "profilevalue"
      end

      def to_hash
        value
      end
    end

    class Kindvalue < Text
      def initialize(val)
        self.value = val
        self.type = "kindvalue"
      end

      def to_hash
        value
      end
    end

    class Ianatoken < Text
      def initialize(val)
        self.value = val
        self.type = "ianatoken"
      end

      def to_hash
        value
      end
    end

    class Binary < Text
      def initialize(val)
        self.value = val
        self.type = "binary"
      end

      def to_hash
        value
      end
    end

    class Phonenumber < Text
      def initialize(val)
        self.value = val
        self.type = "phonenumber"
      end

      def to_hash
        value
      end
    end

    class Uri < Text
      def initialize(val)
        self.value = val
        self.type = "uri"
      end

      def to_hash
        value
      end

      def to_s
        value
      end
    end

    class Float < Vobject::PropertyValue
      include Comparable
      def <=>(another)
        value <=> another.value
      end

      def initialize(val)
        self.value = val
        self.type = "float"
      end

      def to_s
        value
      end

      def to_hash
        value
      end
    end

    class Integer < Vobject::PropertyValue
      include Comparable
      def <=>(another)
        value <=> another.value
      end

      def initialize(val)
        self.value = val
        self.type = "integer"
      end

      def to_s
        value.to_s
      end

      def to_hash
        value
      end
    end

    class Date < Vobject::PropertyValue
      include Comparable
      def <=>(another)
        value <=> another.value
      end

      def initialize(val)
        self.value = val
        self.type = "date"
      end

      def to_s
        sprintf("%04d-%02d-%02d", value[:year].to_i, value[:month].to_i, value[:day].to_i)
      end

      def to_hash
        value
      end
    end

    class DateTimeLocal < Vobject::PropertyValue
      include Comparable
      def <=>(another)
        value[:time] <=> another.value[:time]
      end

      def initialize(val)
        self.value = val.clone
        # val consists of :time && :zone values. If :zone is empty, floating local time (i.e. system local time) is assumed
        self.type = "datetimeLocal"
        val[:sec] += (val[:secfrac].to_f / (10**val[:secfrac].length)) if !val[:secfrac].nil? && !val[:secfrac].empty?
        value[:time] = if val[:zone].nil? || val[:zone].empty?
                         ::Time.local(val[:year], val[:month], val[:day], val[:hour], val[:min], val[:sec])
                       else
                         ::Time.utc(val[:year], val[:month], val[:day], val[:hour], val[:min], val[:sec])
                       end
        value[:origtime] = value[:time]
        if val[:zone] && val[:zone] != "Z"
          offset = val[:zone][:hour].to_i * 3600 + val[:zone][:min].to_i * 60
          offset += val[:zone][:sec].to_i if val[:zone][:sec]
          offset = -offset if val[:sign] == "-"
          value[:time] += offset.to_i
        end
      end

      def to_s
        # ret = sprintf("%04d-%02d-%02dT%02d:%02d:%02d", value[:year], value[:month], value[:day], value[:hour], value[:min], value[:sec])
        ret = sprintf("%s-%s-%sT%s:%s:%s", value[:year], value[:month], value[:day], value[:hour], value[:min], value[:sec])
        ret = ret + ",#{value[:secfrac]}" if value[:secfrac]
        zone = "Z" if value[:zone] && value[:zone] == "Z"
        zone = "#{value[:zone][:sign]}#{value[:zone][:hour]}:#{value[:zone][:min]}" if value[:zone] && value[:zone].is_a?(Hash)
        ret = ret + zone
        ret
      end

      def to_hash
        ret = {
          year: value[:year],
          month: value[:month],
          day: value[:day],
          hour: value[:hour],
          min: value[:min],
          sec: value[:sec],
        }
        ret[:zone] = value[:zone] if value[:zone]
        ret
      end
    end

    class Time < Vobject::PropertyValue
      def initialize(val)
        self.value = val
        self.type = "time"
      end

      def to_s
        ret = "#{value[:hour]}:#{value[:min]}:#{value[:sec]}"
        ret = ret + ".#{value[:secfrac]}" if value[:secfrac]
        zone = ""
        zone = "Z" if value[:zone] && value[:zone] == "Z"
        zone = "#{value[:zone][:sign]}#{value[:zone][:hour]}:#{value[:zone][:min]}" if value[:zone] && value[:zone].is_a?(Hash)
        ret = ret + zone
        ret
      end

      def to_hash
        value
      end
    end

    class Utcoffset < Vobject::PropertyValue
      def initialize(val)
        self.value = val
        self.type = "utcoffset"
      end

      def to_s
        ret = "#{value[:sign]}#{value[:hour]}:#{value[:min]}"
        # ret += self.value[:sec] if self.value[:sec]
        ret
      end

      def to_hash
        value
      end
    end

    class Geovalue < Vobject::PropertyValue
      def initialize(val)
        self.value = val
        self.type = "geovalue"
      end

      def to_s
        ret = "#{value[:lat]};#{value[:long]}"
        ret
      end

      def to_hash
        value
      end
    end

    class Version < Vobject::PropertyValue
      def initialize(val)
        self.value = val
        self.type = "version"
      end

      def to_s
        value
      end

      def to_hash
        value
      end
    end

    class Org < Vobject::PropertyValue
      def initialize(val)
        self.value = val
        self.type = "org"
      end

      def to_s
        value.map { |m| Text.escape m }.join(";")
      end

      def to_hash
        value
      end
    end

    class Fivepartname < Vobject::PropertyValue
      def initialize(val)
        self.value = val
        self.type = "fivepartname"
      end

      def to_s
        ret = Text.listencode value[:surname]
        ret += ";#{Text.listencode value[:givenname]}" if !value[:givenname].empty? || !value[:middlename].empty? || !value[:honprefix].empty? || !value[:honsuffix].empty?
        ret += ";#{Text.listencode value[:middlename]}" if !value[:middlename].empty? || !value[:honprefix].empty?
        ret += ";#{Text.listencode value[:honprefix]}" if !value[:honprefix].empty? || !value[:honsuffix].empty?
        ret += ";#{Text.listencode value[:honsuffix]}" if !value[:honsuffix].empty?
        ret
      end

      def to_hash
        value
      end
    end

    class Address < Vobject::PropertyValue
      def initialize(val)
        self.value = val
        self.type = "address"
      end

      def to_s
        ret = Text.listencode value[:pobox]
        ret += ";#{Text.listencode value[:ext]}" if !value[:ext].empty? || !value[:street].empty? || !value[:locality].empty? || !value[:region].empty? || !value[:code].empty? || !value[:country].empty?
        ret += ";#{Text.listencode value[:street]}" if !value[:street].empty? || !value[:locality].empty? || !value[:region].empty? || !value[:code].empty? || !value[:country].empty?
        ret += ";#{Text.listencode value[:locality]}" if !value[:locality].empty? || !value[:region].empty? || !value[:code].empty? || !value[:country].empty?
        ret += ";#{Text.listencode value[:region]}" if !value[:region].empty? || !value[:code].empty? || !value[:country].empty?
        ret += ";#{Text.listencode value[:code]}" if !value[:code].empty? || !value[:country].empty?
        ret += ";#{Text.listencode value[:country]}" if !value[:country].empty?
        ret
      end

      def to_hash
        value
      end
    end

    class Textlist < Vobject::PropertyValue
      def initialize(val)
        self.value = val
        self.type = "textlist"
      end

      def to_s
        value.map { |m| Text.escape m }.join(",")
      end

      def to_hash
        value
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
        value.each do |k, v|
          ret[k] = {}
          v.each do |k1, v1|
            if v1.is_a?(Hash)
              ret[k][k1] = {}
              v1.each { |k2, v2| ret[k][k1][k2] = v2.to_hash }
            else
              ret[k][k1] = v1
            end
          end
        end
        ret
      end

      def to_s
        ret = Vobject::Component.new(:VCARD, value[:VCARD], []).to_s
        # spec says that colons must be expected, but none of the examples do
        ret.gsub(/\n/, "\\n").gsub(/,/, "\\,").gsub(/;/, "\\;")
        # ret.gsub(/\n/,"\\n").gsub(/:/,"\\:")
      end
    end
  end
end
