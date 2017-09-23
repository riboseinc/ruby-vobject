require "vobject"
require "vobject/propertyvalue"

module Vcard::V4_0
  module PropertyValue
    class Text < Vobject::PropertyValue
      class << self
        def escape(x)
          # temporarily escape \\ as \u007f, which is banned from text
          x.tr("\\", "\u007f").gsub(/\n/, "\\n").gsub(/,/, "\\,").gsub(/\u007f/, "\\\\")
        end

        def escape_component(x)
          # temporarily escape \\ as \u007f, which is banned from text
          x.tr("\\", "\u007f").gsub(/\n/, "\\n").gsub(/,/, "\\,").gsub(/;/, "\\;").gsub(/\u007f/, "\\\\")
        end

        def listencode(x)
          ret = if x.is_a?(Array)
                  x.map { |m| Text.escape_component m }.join(",")
                elsif x.nil? || x.empty?
                  ""
                else
                  Text.escape_component x
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

    class Kindvalue < Text
      def initialize(val)
        self.value = val
        self.type = "text"
      end

      def to_hash
        value
      end
    end

    class Lang < Text
      def initialize(val)
        self.value = val
        self.type = "language-tag"
      end

      def to_hash
        value
      end
    end

    class Ianatoken < Text
      def initialize(val)
        self.value = val
        self.type = "text"
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

    class Clientpidmap < Text
      def initialize(val)
        self.value = val
        # not explicitly specified in spec
        self.type = "text"
      end

      def to_s
        "#{value[:pid]};#{value[:uri]}"
      end

      def to_hash
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
        value[:date] <=> another.value[:date]
      end

      def initialize(val)
        self.value = val.clone
        self.type = "date"
        # fill in unspecified month && year && date; only for purposes of comparison
        val[:year] = sprintf("%04d", ::Date.today.year) unless val.has_key?(:year)
        val[:month] = sprintf("%02d", ::Date.today.month) unless val.has_key?(:month)
        val[:day] = sprintf("%02d", ::Date.today.day) unless val.has_key?(:day)
        value[:date] = ::Time.utc(val[:year], val[:month], val[:day])
      end

      def to_s
        ret = ""
        ret << if value[:year]
                 value[:year]
               else
                 "--"
               end
        if value[:month]
          ret << value[:month]
        elsif value[:day]
          ret << "-"
        end
        if value[:day]
          ret << value[:day]
        end
        ret
      end

      def to_hash
        ret = {}
        ret[:year] = value[:year] if value[:year]
        ret[:month] = value[:month] if value[:month]
        ret[:day] = value[:day] if value[:day]
        ret
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
        self.type = "date-time"
        # fill in unspecified month && year && date; only for purposes of comparison
        val[:year] = sprintf("%04d", ::Date.today.year) unless val.has_key?(:year)
        val[:month] = sprintf("%02d", ::Date.today.month) unless val.has_key?(:month)
        val[:day] = sprintf("%02d", ::Date.today.day) unless val.has_key?(:day)
        val[:hour] = 0 unless val.has_key?(:hour)
        val[:min] = 0 unless val.has_key?(:min)
        val[:sec] = 0 unless val.has_key?(:sec)
        value[:time] = if val[:zone].empty?
                         ::Time.utc(val[:year], val[:month], val[:day], val[:hour], val[:min], val[:sec])
                       else
                         ::Time.local(val[:year], val[:month], val[:day], val[:hour], val[:min], val[:sec])
                       end
        if val[:zone] && val[:zone] != "Z"
          offset = val[:zone][:hour] * 3600 + val[:zone][:min] * 60
          offset += val[:zone][:sec] if val[:zone][:sec]
          offset = -offset if val[:sign] == "-"
          value[:time] += offset.to_i
        end
      end

      def to_s
        ret = ""
        ret << if value[:year]
                 value[:year]
               else
                 "--"
               end
        if value[:month]
          ret << value[:month]
        elsif value[:day]
          ret << "-"
        end
        if value[:day]
          ret << value[:day]
        end
        ret << "T"
        ret << value[:hour] if value[:hour]
        ret << value[:min] if value[:min]
        ret << value[:sec] if value[:sec]
        ret << value[:zone] if value[:zone] == "Z"
        if value[:zone].is_a?(Hash)
          ret << value[:zone][:sign]
          ret << value[:zone][:hour]
          ret << value[:zone][:min]
          ret << value[:zone][:sec] if value[:zone][:sec]
        end
        ret
      end

      def to_hash
        ret = {}
        ret[:year] = value[:year] if value[:year]
        ret[:month] = value[:month] if value[:month]
        ret[:day] = value[:day] if value[:day]
        ret[:hour] = value[:hour] if value[:hour]
        ret[:min] = value[:min] if value[:min]
        ret[:sec] = value[:sec] if value[:sec]
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
        ret = ""
        ret << value[:hour] if value[:hour]
        ret << value[:min] if value[:min]
        ret << value[:sec] if value[:sec]
        ret << value[:zone] if value[:zone]
        ret
      end

      def to_hash
        value
      end
    end

    class Utcoffset < Vobject::PropertyValue
      def initialize(val)
        self.value = val
        self.type = "utc-offset"
      end

      def to_s
        ret = "#{value[:sign]}#{value[:hr]}#{value[:min]}"
        ret += value[:sec] if value[:sec]
        ret
      end

      def to_hash
        value
      end
    end

    class Version < Vobject::PropertyValue
      def initialize(val)
        self.value = val
        self.type = "text"
      end

      def to_s
        value
      end

      def to_hash
        value
      end
    end

    class Gender < Vobject::PropertyValue
      def initialize(val)
        self.value = val
        self.type = "text"
      end

      def to_s
        ret = value[:sex]
        ret << ";#{value[:gender]}" if !value[:gender].empty?
        ret
      end

      def to_hash
        value
      end
    end

    class Textlist < Vobject::PropertyValue
      def initialize(val)
        self.value = val
        self.type = "text"
      end

      def to_s
        value.map { |m| Text.escape m }.join(",")
      end

      def to_hash
        value
      end
    end

    class Org < Vobject::PropertyValue
      def initialize(val)
        self.value = val
        self.type = "text"
      end

      def to_s
        value.map { |m| Text.escape_component m }.join(";")
      end

      def to_hash
        value
      end
    end

    class Fivepartname < Vobject::PropertyValue
      def initialize(val)
        self.value = val
        self.type = "text"
      end

      def to_s
        ret = Text.listencode value[:surname]
        ret += ";#{Text.listencode value[:givenname]}"
        ret += ";#{Text.listencode value[:additionalname]}"
        ret += ";#{Text.listencode value[:honprefix]}"
        ret += ";#{Text.listencode value[:honsuffix]}"
        ret
      end

      def to_hash
        value
      end
    end

    class Address < Vobject::PropertyValue
      def initialize(val)
        self.value = val
        self.type = "text"
      end

      def to_s
        ret = Text.listencode value[:pobox]
        ret += ";#{Text.listencode value[:ext]}"
        ret += ";#{Text.listencode value[:street]}"
        ret += ";#{Text.listencode value[:locality]}"
        ret += ";#{Text.listencode value[:region]}"
        ret += ";#{Text.listencode value[:code]}"
        ret += ";#{Text.listencode value[:country]}"
        ret
      end

      def to_hash
        value
      end
    end
  end
end
