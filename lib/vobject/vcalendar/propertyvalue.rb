require "vobject"
require "vobject/propertyvalue"

module Vobject
  module Vcalendar
    module PropertyValue

      class Text < Vobject::PropertyValue

        class << self
          def escape x
            # temporarily escape \\ as \u007f, which is banned from text
            x.gsub(/\\/, "\u007f").gsub(/\n/, "\\n").gsub(/,/, "\\,").gsub(/;/, "\\;").gsub(/\u007f/, "\\\\\\\\")
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

      class TranspValue < Text
        def initialize(val)
          self.value = val
          self.type = "transpvalue"
        end

        def to_hash
          self.value
        end

      end

      class ActionValue < Text
        def initialize(val)
          self.value = val
          self.type = "actionvalue"
        end

        def to_hash
          self.value
        end

      end

      class MethodValue < Text
        def initialize(val)
          self.value = val
          self.type = "methodvalue"
        end

        def to_hash
          self.value
        end

      end

      class Busytype < Text
        def initialize(val)
          self.value = val
          self.type = "busytype"
        end

        def to_hash
          self.value
        end

      end

      class Color < Text
        def initialize(val)
          self.value = val
          self.type = "color"
        end

        def to_hash
          self.value
        end

      end

      class EventStatus < Text
        def initialize(val)
          self.value = val
          self.type = "eventstatus"
        end

        def to_hash
          self.value
        end

      end

      class Todostatus < Text
        def initialize(val)
          self.value = val
          self.type = "todostatus"
        end

        def to_hash
          self.value
        end

      end

      class Journalstatus < Text
        def initialize(val)
          self.value = val
          self.type = "journalstatus"
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

      class Uri < Text
        def initialize(val)
          self.value = val
          self.type = "uri"
        end

        def to_hash
          self.value
        end

      end

      class Calscale < Vobject::PropertyValue

        def initialize(val)
          self.value = val
          self.type = "calscale"
        end

        def to_s
          self.value
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

      class PercentComplete < Integer

        def initialize(val)
          self.value = val
          self.type = "percentcomplete"
        end

        def to_hash
          self.value
        end

      end

      class Priority < Integer

        def initialize(val)
          self.value = val
          self.type = "priority"
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
          sprintf("%04d%02d%02d", self.value.year, self.value.month, self.value.day)
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
          self.value = val
          # val consists of :time && :zone values. If :zone is empty, floating local time (i.e. system local time) is assumed
          self.type = "datetimeLocal"
        end

        def to_s
          if !self.value[:zone].empty?
            tz = TZInfo::Timezone.get(self.value[:zone])
            localtime = tz.utc_to_local(self.value[:time])
          else
            localtime = self.value[:time]
          end
          sprintf("%04d%02d%02dT%02d%02d%02d", localtime.year, localtime.month, localtime.day,
                  localtime.hour, localtime.min, localtime.sec)
        end


        def to_hash
          self.value
        end

      end

      class DateTimeUTC < Vobject::PropertyValue
        include Comparable
        def <=>(anOther)
          self.value[:time] <=> anOther.value[:time]
        end

        def initialize(val)
          self.value = val
          self.type = "datetimeUTC"
        end


        def to_s
          utc = self.value[:time]
          sprintf("%04d%02d%02dT%02d%02d%02dZ", utc.year, utc.month, utc.day,
                  utc.hour, utc.min, utc.sec)
        end

        def to_hash
          self.value
        end

      end

      class Boolean < Vobject::PropertyValue

        def initialize(val)
          self.value = val
          self.type = "boolean"
        end

        def to_s
          ret = self.value
        end

        def to_hash
          self.value
        end

      end

      class Duration < Vobject::PropertyValue

        def initialize(val)
          self.value = val
          self.type = "duration"
        end

        def to_s
          ret = "P"
          ret = self.value[:sign] + ret if self.value[:sign]
          ret = ret + "#{self.value[:weeks]}W" if self.value[:weeks]
          ret = ret + "#{self.value[:days]}D" if self.value[:days]
          ret = ret + "T" if self.value[:hours] || self.value[:minutes] || self.value[:seconds]
          ret = ret + "#{self.value[:hours]}H" if self.value[:hours]
          ret = ret + "#{self.value[:minutes]}M" if self.value[:minutes]
          ret = ret + "#{self.value[:seconds]}S" if self.value[:seconds]
          ret
        end

        def to_hash
          self.value
        end

      end

      class Time < Vobject::PropertyValue

        def initialize(val)
          self.value = val
          self.type = "time"
        end

        def to_s
          ret = "#{self.value[:hour]}#{self.value[:min]}#{self.value[:sec]}"
          ret = ret + "Z" if self.value[:utc]
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
          ret = "#{self.value[:sign]}#{self.value[:hr]}#{self.value[:min]}"
          ret += self.value[:sec] if self.value[:sec]
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
          self.value.join(";")
        end

        def to_hash
          if self.value.length == 1
            self.value[0]
          else
            self.value
          end
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

      class Periodlist < Vobject::PropertyValue
        def initialize(val)
          self.value = val
          self.type = "periodlist"
        end

        def to_s
          self.value.map { |m|
            ret = m[:start].to_s + "/"
            ret += m[:end].to_s if m.has_key? :end
            ret += m[:duration].to_s if m.has_key? :duration
            ret
          }.join(",")
        end

        def to_hash
          self.value.map { |m| m.each { |k, v| m[k] = v.to_hash }}
        end

      end

      class Datelist < Vobject::PropertyValue
        def initialize(val)
          self.value = val
          self.type = "datelist"
        end

        def to_s
          self.value.map { |m| m.to_s}.join(",")
        end

        def to_hash
          self.value.map { |m| m.to_hash}
        end

      end

      class Datetimelist < Vobject::PropertyValue
        def initialize(val)
          self.value = val
          self.type = "datetimelist"
        end

        def to_s
          self.value.map { |m| m.to_s}.join(",")
        end

        def to_hash
          self.value.map { |m| m.to_hash}
        end

      end

      class Datetimeutclist < Vobject::PropertyValue
        def initialize(val)
          self.value = val
          self.type = "datetimeutclist"
        end

        def to_s
          self.value.map { |m| m.to_s}.join(",")
        end

        def to_hash
          self.value.map { |m| m.to_hash}
        end

      end

      class Requeststatusvalue < Vobject::PropertyValue
        def initialize(val)
          self.value = val
          self.type = "requeststatusvalue"
        end

        def to_s
          ret = "#{self.value[:statcode]};#{self.value[:statdesc]}"
          ret += ";#{self.value[:extdata]}" if self.value[:extdata]
          ret
        end

        def to_hash
          self.value
        end

      end

      class Recur < Vobject::PropertyValue
        def initialize(val)
          self.value = val
          self.type = "recur"
        end

        def to_s
          ret = []
          self.value.each { |k, v|
            ret << "#{k.to_s.upcase}=#{valencode(k,v)}"
          }
          ret.join(";")
        end

        def to_hash
          ret = {}
          self.value.each{ |k, v|
            if v.respond_to?(:to_hash)
              ret[k] = v.to_hash
            else
              ret[k] = v
            end
          }
          ret
        end

        private

        def valencode(k, v)
          case k
          when :bysetpos, :byyearday
            return v.map { |x|
              ret = x[:ordyrday]
              ret = x[:sign] + ret if x[:sign]
              ret
            }.join(",")
          when :byweekno
            return v.map { |x|
              ret = x[:ordwk]
              ret = x[:sign] + ret if x[:sign]
              ret
            }.join(",")
          when :bymonthday
            return v.map { |x|
              ret = x[:ordmoday]
              ret = x[:sign] + ret if x[:sign]
              ret
            }.join(",")
          when :byday
            return v.map { |x|
              ret = x[:weekday]
              ret = x[:ordwk] + ret if x[:ordwk]
              ret = x[:sign] + ret if x[:sign]
              ret
            }.join(",")
          when :bymonth, :byhour, :byminute, :bysecond
            return v.join(",")
          when :enddate
            return v.to_s
          else
            return v
          end
        end

      end

    end
  end
end
