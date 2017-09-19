require 'vobject'
require 'vobject/propertyvalue'

module Vcard::V4_0
  module PropertyValue

    class Text < Vobject::PropertyValue

      class << self 
        def escape x
          # temporarily escape \\ as \u007f, which is banned from text
          x.gsub(/\\/, "\u007f").gsub(/\n/, "\\n").gsub(/,/, "\\,").gsub(/\u007f/, "\\\\")
        end
        def escape_component x
          # temporarily escape \\ as \u007f, which is banned from text
          x.gsub(/\\/, "\u007f").gsub(/\n/, "\\n").gsub(/,/, "\\,").gsub(/;/, "\\;").gsub(/\u007f/, "\\\\")
        end
        def listencode x
          if x.kind_of?(Array)
            ret = x.map{|m| Text.escape_component m}.join(',')
          elsif x.nil? or x.empty? 
            ret = ''
          else
            ret = Text.escape_component x
          end
          ret
        end
      end

      def initialize val
        self.value = val
        self.type = 'text'
      end

      def to_s
        Text.escape self.value
      end

      def to_hash
        self.value
      end

    end

    class Kindvalue < Text
      def initialize val
        self.value = val
        self.type = 'kindvalue'
      end

      def to_hash
        self.value
      end

    end

    class Lang < Text
      def initialize val
        self.value = val
        self.type = 'lang'
      end

      def to_hash
        self.value
      end

    end

    class Ianatoken < Text
      def initialize val
        self.value = val
        self.type = 'ianatoken'
      end

      def to_hash
        self.value
      end

    end

    class Uri < Text
      def initialize val
        self.value = val
        self.type = 'uri'
      end

      def to_hash
        self.value
      end

      def to_s
        self.value
      end

    end

    class Clientpidmap < Text
      def initialize val
        self.value = val
        self.type = 'clientpidmap'
      end

      def to_s
        "#{self.value[:pid]};#{self.value[:uri]}"
      end

      def to_hash
        self.value
      end

    end

    class Float < Vobject::PropertyValue
      include Comparable
      def <=>(anOther)
        self.value <=> anOther.value
      end

      def initialize val
        self.value = val
        self.type = 'float'
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

      def initialize val
        self.value = val
        self.type = 'integer'
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
        self.value[:date] <=> anOther.value[:date]
      end

      def initialize val
        self.value = val.clone
        self.type = 'date'
        # fill in unspecified month and year and date; only for purposes of comparison
        val[:year] = sprintf("%04d", ::Date.today().year) unless val.has_key?(:year)
        val[:month] = sprintf("%02d",::Date.today().month) unless val.has_key?(:month)
        val[:day] = sprintf("%02d",::Date.today().day) unless val.has_key?(:day)
        self.value[:date] = ::Time.utc(val[:year], val[:month], val[:day])
      end

      def to_s
        ret = ""
        if self.value[:year]
          ret << self.value[:year] 
        else
          ret << "--"
        end
        if self.value[:month]
          ret << self.value[:month] 
        elsif self.value[:day]
          ret << "-"
        end
        if self.value[:day]
          ret << self.value[:day] 
        end
        ret
      end

      def to_hash
        ret = {}
        ret[:year] = self.value[:year] if self.value[:year]
        ret[:month] = self.value[:month] if self.value[:month]
        ret[:day] = self.value[:day] if self.value[:day]
        ret
      end

    end

    class DateTimeLocal < Vobject::PropertyValue
      include Comparable
      def <=>(anOther)
        self.value[:time] <=> anOther.value[:time]
      end

      def initialize val
        self.value = val.clone
        # val consists of :time and :zone values. If :zone is empty, floating local time (i.e. system local time) is assumed
        self.type = 'datetimeLocal'
        # fill in unspecified month and year and date; only for purposes of comparison
        val[:year] = sprintf("%04d",::Date.today().year) unless val.has_key?(:year)
        val[:month] = sprintf("%02d",::Date.today().month) unless val.has_key?(:month)
        val[:day] = sprintf("%02d",::Date.today().day) unless val.has_key?(:day)
        val[:hour] = 0 unless val.has_key?(:hour)
        val[:min] = 0 unless val.has_key?(:min)
        val[:sec] = 0 unless val.has_key?(:sec)
        if val[:zone].empty?
          self.value[:time] = ::Time.utc(val[:year], val[:month], val[:day], val[:hour], val[:min], val[:sec])
        else
          self.value[:time] = ::Time.local(val[:year], val[:month], val[:day], val[:hour], val[:min], val[:sec])
        end
        if val[:zone] and val[:zone] != 'Z'
          offset = val[:zone][:hour]*3600 + val[:zone][:min]*60
          offset += val[:zone][:sec] if val[:zone][:sec]
          offset = -offset if val[:sign] == '-'
          self.value[:time] += offset.to_i
        end
      end

      def to_s
        ret = ""
        if self.value[:year]
          ret << self.value[:year] 
        else
          ret << "--"
        end
        if self.value[:month]
          ret << self.value[:month] 
        elsif self.value[:day]
          ret << "-"
        end
        if self.value[:day]
          ret << self.value[:day] 
        end
        ret << "T"
        ret << self.value[:hour] if self.value[:hour]
        ret << self.value[:min] if self.value[:min]
        ret << self.value[:sec] if self.value[:sec]
        ret << self.value[:zone] if self.value[:zone] == 'Z'
        if self.value[:zone].kind_of?(Hash)
          ret << self.value[:zone][:sign]
          ret << self.value[:zone][:hour]
          ret << self.value[:zone][:min]
          ret << self.value[:zone][:sec]  if self.value[:zone][:sec]
        end
        ret
      end

      def to_hash
        ret = {}
        ret[:year] = self.value[:year] if self.value[:year]
        ret[:month] = self.value[:month] if self.value[:month]
        ret[:day] = self.value[:day] if self.value[:day]
        ret[:hour] = self.value[:hour] if self.value[:hour]
        ret[:min] = self.value[:min] if self.value[:min]
        ret[:sec] = self.value[:sec] if self.value[:sec]
        ret[:zone] = self.value[:zone] if self.value[:zone]
        ret
      end

    end

    class Time < Vobject::PropertyValue

      def initialize val
        self.value = val
        self.type = 'time'
      end

      def to_s
        ret = ""
        ret << self.value[:hour] if self.value[:hour]
        ret << self.value[:min] if self.value[:min]
        ret << self.value[:sec] if self.value[:sec]
        ret << self.value[:zone] if self.value[:zone]
        ret
      end

      def to_hash
        self.value
      end

    end

    class Utcoffset < Vobject::PropertyValue

      def initialize val
        self.value = val
        self.type = 'utcoffset'
      end

      def to_s
        ret = "#{self.value[:sign]}#{self.value[:hr]}#{self.value[:min]}"
        ret += self.value[:sec] if self.value[:sec]
        ret
      end

      def to_hash
        self.value
      end

    end

    class Version < Vobject::PropertyValue

      def initialize val
        self.value = val
        self.type = 'version'
      end

      def to_s
        self.value
      end

      def to_hash
        self.value
      end

    end

    class Gender < Vobject::PropertyValue

      def initialize val
        self.value = val
        self.type = 'gender'
      end

      def to_s
        ret = self.value[:sex]
        ret << ";#{self.value[:gender]}" if !self.value[:gender].empty?
        ret
      end

      def to_hash
        self.value
      end

    end

    class Textlist < Vobject::PropertyValue
      def initialize val
        self.value = val
        self.type = 'textlist'
      end

      def to_s
        self.value.map{|m| Text.escape m}.join(',')
      end

      def to_hash
        self.value
      end

    end

    class Org < Vobject::PropertyValue
      def initialize val
        self.value = val
        self.type = 'org'
      end

      def to_s
        self.value.map{|m| Text.escape_component m}.join(';')
      end

      def to_hash
        self.value
      end

    end


    class Fivepartname < Vobject::PropertyValue
      def initialize val
        self.value = val
        self.type = 'fivepartname'
      end

      def to_s
        ret = Text.listencode self.value[:surname]
        ret += ";#{Text.listencode self.value[:givenname]}" 
        ret += ";#{Text.listencode self.value[:additionalname]}" 
        ret += ";#{Text.listencode self.value[:honprefix]}" 
        ret += ";#{Text.listencode self.value[:honsuffix]}" 
        ret
      end

      def to_hash
        self.value
      end

    end

    class Address < Vobject::PropertyValue
      def initialize val
        self.value = val
        self.type = 'address'
      end

      def to_s
        ret = Text.listencode self.value[:pobox]
        ret += ";#{Text.listencode self.value[:ext]}"
        ret += ";#{Text.listencode self.value[:street]}"
        ret += ";#{Text.listencode self.value[:locality]}"
        ret += ";#{Text.listencode self.value[:region]}"
        ret += ";#{Text.listencode self.value[:code]}"
        ret += ";#{Text.listencode self.value[:country]}"
        ret
      end

      def to_hash
        self.value
      end

    end





  end
end
