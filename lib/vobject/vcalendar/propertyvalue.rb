require "vobject"
require "vobject/propertyvalue"

module Vobject
  module Vcalendar
    module PropertyValue
      class Text < Vobject::PropertyValue
        class << self
          def escape(x)
            # temporarily escape \\ as \u007f, which is banned from text
            x.tr("\\", "\u007f").gsub(/\n/, "\\n").gsub(/,/, "\\,").
              gsub(/;/, "\\;").gsub(/\u007f/, "\\\\\\\\")
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

      class TranspValue < Text
        def initialize(val)
          self.value = val
          self.type = "transpvalue"
        end

        def to_hash
          value
        end
      end

      class ActionValue < Text
        def initialize(val)
          self.value = val
          self.type = "actionvalue"
        end

        def to_hash
          value
        end
      end

      class MethodValue < Text
        def initialize(val)
          self.value = val
          self.type = "methodvalue"
        end

        def to_hash
          value
        end
      end

      class Busytype < Text
        def initialize(val)
          self.value = val
          self.type = "busytype"
        end

        def to_hash
          value
        end
      end

      class Color < Text
        def initialize(val)
          self.value = val
          self.type = "color"
        end

        def to_hash
          value
        end
      end

      class EventStatus < Text
        def initialize(val)
          self.value = val
          self.type = "eventstatus"
        end

        def to_hash
          value
        end
      end

      class Todostatus < Text
        def initialize(val)
          self.value = val
          self.type = "todostatus"
        end

        def to_hash
          value
        end
      end

      class Journalstatus < Text
        def initialize(val)
          self.value = val
          self.type = "journalstatus"
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

      class Uri < Text
        def initialize(val)
          self.value = val
          self.type = "uri"
        end

        def to_hash
          value
        end
      end

      class Calscale < Vobject::PropertyValue
        def initialize(val)
          self.value = val
          self.type = "calscale"
        end

        def to_s
          value
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
          value.to_s
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

      class PercentComplete < Integer
        def initialize(val)
          self.value = val
          self.type = "percentcomplete"
        end

        def to_hash
          value
        end
      end

      class Priority < Integer
        def initialize(val)
          self.value = val
          self.type = "priority"
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
          sprintf("%04d%02d%02d", value.year, value.month, value.day)
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
          value[:time] = if val[:zone].nil? || val[:zone].empty?
                           ::Time.local(val[:year], val[:month], val[:day], val[:hour], val[:min], val[:sec])
                         else
                           ::Time.utc(val[:year], val[:month], val[:day], val[:hour], val[:min], val[:sec])
                         end
          value[:origtime] = value[:time]
        end

        def to_s
          localtime = value[:origtime]
          ret = sprintf("%04d%02d%02dT%02d%02d%02d", localtime.year, localtime.month, localtime.day,
                        localtime.hour, localtime.min, localtime.sec)
          zone = "Z" if value[:zone] && value[:zone] == "Z"
          ret = ret + zone if !zone.nil?
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

      class DateTimeUTC < Vobject::PropertyValue
        include Comparable
        def <=>(another)
          value[:time] <=> another.value[:time]
        end

        def initialize(val)
          self.value = val.clone
          value[:time] =  ::Time.utc(val[:year], val[:month], val[:day], val[:hour], val[:min], val[:sec])
          value[:origtime] = value[:time]
        end

        def to_s
          localtime = value[:origtime]
          ret = sprintf("%04d%02d%02dT%02d%02d%02dZ", localtime.year, localtime.month, localtime.day,
                        localtime.hour, localtime.min, localtime.sec)
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
          ret
        end
      end

      class Boolean < Vobject::PropertyValue
        def initialize(val)
          self.value = val
          self.type = "boolean"
        end

        def to_s
          value.to_s
        end

        def to_hash
          value
        end
      end

      class Duration < Vobject::PropertyValue
        def initialize(val)
          self.value = val
          self.type = "duration"
        end

        def to_s
          ret = "P"
          ret = value[:sign] + ret if value[:sign]
          ret = ret + "#{value[:weeks]}W" if value[:weeks]
          ret = ret + "#{value[:days]}D" if value[:days]
          ret = ret + "T" if value[:hours] || value[:minutes] || value[:seconds]
          ret = ret + "#{value[:hours]}H" if value[:hours]
          ret = ret + "#{value[:minutes]}M" if value[:minutes]
          ret = ret + "#{value[:seconds]}S" if value[:seconds]
          ret
        end

        def to_hash
          value
        end
      end

      class Time < Vobject::PropertyValue
        def initialize(val)
          self.value = val
          self.type = "time"
        end

        def to_s
          ret = "#{value[:hour]}#{value[:min]}#{value[:sec]}"
          ret = ret + "Z" if value[:utc]
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
          ret = "#{value[:sign]}#{value[:hr]}#{value[:min]}"
          ret += value[:sec] if value[:sec]
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
          value.join(";")
        end

        def to_hash
          if value.length == 1
            value[0]
          else
            value
          end
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

      class Periodlist < Vobject::PropertyValue
        def initialize(val)
          self.value = val
          self.type = "periodlist"
        end

        def to_s
          value.map do |m|
            ret = m[:start].to_s + "/"
            ret += m[:end].to_s if m.has_key? :end
            ret += m[:duration].to_s if m.has_key? :duration
            ret
          end.join(",")
        end

        def to_hash
          value.map { |m| m.each { |k, v| m[k] = v.to_hash } }
        end
      end

      class Datelist < Vobject::PropertyValue
        def initialize(val)
          self.value = val
          self.type = "datelist"
        end

        def to_s
          value.map(&:to_s).join(",")
        end

        def to_hash
          value.map(&:to_hash)
        end
      end

      class Datetimelist < Vobject::PropertyValue
        def initialize(val)
          self.value = val
          self.type = "datetimelist"
        end

        def to_s
          value.map(&:to_s).join(",")
        end

        def to_hash
          value.map(&:to_hash)
        end
      end

      class Datetimeutclist < Vobject::PropertyValue
        def initialize(val)
          self.value = val
          self.type = "datetimeutclist"
        end

        def to_s
          value.map(&:to_s).join(",")
        end

        def to_hash
          value.map(&:to_hash)
        end
      end

      class Requeststatusvalue < Vobject::PropertyValue
        def initialize(val)
          self.value = val
          self.type = "requeststatusvalue"
        end

        def to_s
          ret = "#{value[:statcode]};#{value[:statdesc]}"
          ret += ";#{value[:extdata]}" if value[:extdata]
          ret
        end

        def to_hash
          value
        end
      end

      class Recur < Vobject::PropertyValue
        def initialize(val)
          self.value = val
          self.type = "recur"
        end

        def to_s
          ret = []
          value.each do |k, v|
            ret << "#{k.to_s.upcase}=#{valencode(k, v)}"
          end
          ret.join(";")
        end

        def to_hash
          ret = {}
          value.each do |k, v|
            ret[k] = if v.respond_to?(:to_hash)
                       v.to_hash
                     else
                       v
                     end
          end
          ret
        end

        private

        def valencode(k, v)
          case k
          when :bysetpos, :byyearday
            v.map do |x|
              ret = x[:ordyrday]
              ret = x[:sign] + ret if x[:sign]
              ret
            end.join(",")
          when :byweekno
            v.map do |x|
              ret = x[:ordwk]
              ret = x[:sign] + ret if x[:sign]
              ret
            end.join(",")
          when :bymonthday
            v.map do |x|
              ret = x[:ordmoday]
              ret = x[:sign] + ret if x[:sign]
              ret
            end.join(",")
          when :byday
            v.map do |x|
              ret = x[:weekday]
              ret = x[:ordwk] + ret if x[:ordwk]
              ret = x[:sign] + ret if x[:sign]
              ret
            end.join(",")
          when :bymonth, :byhour, :byminute, :bysecond
            v.join(",")
          when :enddate
            v.to_s
          else
            v
          end
        end
      end
    end
  end
end
