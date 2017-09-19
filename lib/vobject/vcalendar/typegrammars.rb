require "rsec"
require "set"
require "uri"
require "date"
require "tzinfo"
include Rsec::Helpers
require_relative "../../c"
require_relative "../../error"
require_relative "./propertyparent"
require "vobject"
require_relative "./propertyvalue"

module Vobject::Vcalendar
  class Typegrammars
    class << self
      # property value types, each defining their own parser
      def recur
        freq = /SECONDLY/i.r | /MINUTELY/i.r | /HOURLY/i.r | /DAILY/i.r |
          /WEEKLY/i.r | /MONTHLY/i.r | /YEARLY/i.r
        enddate = C::DATE_TIME | C::DATE
        seconds = /[0-9]{1,2}/.r
        byseclist = seq(seconds << ",".r, lazy { byseclist }) do |s, l|
          [s, l].flatten
        end | seconds.map { |s| [s] }
        minutes = /[0-9]{1,2}/.r
        byminlist = seq(minutes << ",".r, lazy { byminlist }) do |m, l|
          [m, l].flatten
        end | minutes.map { |m| [m] }
        hours = /[0-9]{1,2}/.r
        byhrlist = seq(hours << ",".r, lazy { byhrlist }) do |h, l|
          [h, l].flatten
        end | hours.map { |h| [h] }
        ordwk = /[0-9]{1,2}/.r
        weekday = /SU/i.r | /MO/i.r | /TU/i.r | /WE/i.r | /TH/i.r | /FR/i.r | /SA/i.r
        weekdaynum1 = seq(C::SIGN._?, ordwk) do |s, o|
          h = { ordwk: o }
          h[:sign] = s[0] unless s.empty?
          h
        end
        weekdaynum = seq(weekdaynum1._?, weekday) do |a, b|
          h = { weekday: b }
          h = h.merge a[0] unless a.empty?
          h
        end
        bywdaylist = seq(weekdaynum << ",".r, lazy { bywdaylist }) do |w, l|
          [w, l].flatten
        end | weekdaynum.map { |w| [w] }
        ordmoday = /[0-9]{1,2}/.r
        monthdaynum = seq(C::SIGN._?, ordmoday) do |s, o|
          h = { ordmoday: o }
          h[:sign] = s[0] unless s.empty?
          h
        end
        bymodaylist = seq(monthdaynum << ",".r, lazy { bymodaylist }) do |m, l|
          [m, l].flatten
        end | monthdaynum.map { |m| [m] }
        ordyrday = /[0-9]{1,3}/.r
        yeardaynum = seq(C::SIGN._?, ordyrday) do |s, o|
          h = { ordyrday: o }
          h[:sign] = s[0] unless s.empty?
          h
        end
        byyrdaylist = seq(yeardaynum << ",".r, lazy { byyrdaylist }) do |y, l|
          [y, l].flatten
        end | yeardaynum.map { |y| [y] }
        weeknum = seq(C::SIGN._?, ordwk) do |s, o|
          h = { ordwk: o }
          h[:sign] = s[0] unless s.empty?
          h
        end
        bywknolist = seq(weeknum << ",".r, lazy { bywknolist }) do |w, l|
          [w, l].flatten
        end | weeknum.map { |w| [w] }
        # monthnum = /[0-9]{1,2}/.r
        # RFC 7529 add leap month indicator
        monthnum = /[0-9]{1,2}L?/i.r
        bymolist = seq(monthnum << ",".r, lazy { bymolist }) do |m, l|
          [m, l].flatten
        end | monthnum.map { |m| [m] }
        setposday = yeardaynum
        bysplist = seq(setposday << ",".r, lazy { bysplist }) do |s, l|
          [s, l].flatten
        end | setposday.map { |s| [s] }
        # http://www.unicode.org/repos/cldr/tags/latest/common/bcp47/calendar.xml
        rscale = C::XNAME_VCAL | /buddhist/i.r | /chinese/i.r | /coptic/i.r | /dangi/i.r |
          /ethioaa/i.r | /ethiopic-amete-alem/i.r | /ethiopic/i.r |
          /gregory/i.r | /hebrew/i.r | /indian/i.r | /islamic/i.r |
          /islamic-umalqura/i.r | /islamic-tbla/i.r | /islamic-civil/i.r |
          /islamic-rgsa/i.r | /iso8601/i.r | /japanese/i.r | /persian/i.r |
          /roc/i.r | /islamicc/i.r | /gregorian/i.r
        skip = /OMIT/i.r | /BACKWARD/i.r | /FORWARD/i.r
        recur_rule_part = 	seq(/FREQ/i.r << "=".r, freq) { |_k, v| { freq: v } } |
          seq(/UNTIL/i.r << "=".r, enddate) { |_k, v| { until: v } } |
          seq(/COUNT/i.r << "=".r, /[0-9]+/i.r) { |_k, v| { count: v } } |
          seq(/INTERVAL/i.r << "=".r, /[0-9]+/i.r) { |_k, v| { interval: v } } |
          seq(/BYSECOND/i.r << "=".r, byseclist) { |_k, v| { bysecond: v } } |
          seq(/BYMINUTE/i.r << "=".r, byminlist) { |_k, v| { byminute: v } } |
          seq(/BYHOUR/i.r << "=".r, byhrlist) { |_k, v| { byhour: v } } |
          seq(/BYDAY/i.r << "=".r, bywdaylist) { |_k, v| { byday: v } } |
          seq(/BYMONTHDAY/i.r << "=".r, bymodaylist) { |_k, v| { bymonthday: v } } |
          seq(/BYYEARDAY/i.r << "=".r, byyrdaylist) { |_k, v| { byyearday: v } } |
          seq(/BYWEEKNO/i.r << "=".r, bywknolist) { |_k, v| { byweekno: v } } |
          seq(/BYMONTH/i.r << "=".r, bymolist) { |_k, v| { bymonth: v } } |
          seq(/BYSETPOS/i.r << "=".r, bysplist) { |_k, v| { bysetpos: v } } |
          seq(/WKST/i.r << "=".r, weekday) { |_k, v| { wkst: v } } |
          # RFC 7529
          seq(/RSCALE/i.r << "=".r, rscale) { |_k, v| { rscale: v } } |
          seq(/SKIP/i.r << "=".r, skip) { |_k, v| { skip: v } }
        recur1 = seq(recur_rule_part, ";", lazy { recur1 }) { |h, _, r| h.merge r } |
          recur_rule_part
        recur = recur1.map { |r| PropertyValue::Recur.new r }
        recur.eof
      end

      def integer
        integer = prim(:int32).map { |i| PropertyValue::Integer.new i }
        integer.eof
      end

      def percent_complete
        integer = prim(:int32).map do |a|
          if a >= 0 && a <= 100
            PropertyValue::PercentComplete.new a
          else
            { error: "Percentage outside of range 0..100" }
          end
        end
        integer.eof
      end

      def priority
        integer = prim(:int32).map do |a|
          if a >= 0 && a <= 9
            PropertyValue::Priority.new a
          else
            { error: "Percentage outside of range 0..100" }
          end
        end
        integer.eof
      end

      def float_t
        float_t = prim(:double).map { |f| PropertyValue::Float.new f }
        float_t.eof
      end

      def time_t
        time_t = C::TIME.map { |t| PropertyValue::Time.new t }
        time_t.eof
      end

      def geovalue
        float = prim(:double)
        geovalue = seq(float << ";".r, float) do |a, b|
          if a <= 180.0 && a >= -180.0 && b <= 180 && b > -180
            PropertyValue::Geovalue.new(lat: a, long: b)
          else
            { error: "Latitude/Longitude outside of range -180..180" }
          end
        end
        geovalue.eof
      end

      def calscalevalue
        calscalevalue = /GREGORIAN/i.r.map { PropertyValue::Calscale.new "GREGORIAN" }
        calscalevalue.eof
      end

      def iana_token
        iana_token = C::IANATOKEN.map { |x| PropertyValue::Ianatoken.new x }
        iana_token.eof
      end

      def versionvalue
        versionvalue = seq(prim(:double) << ";".r,
                           prim(:double)) do |x, y|
          PropertyValue::Version.new [x, y]
        end | "2.0".r.map do
          PropertyValue::Version.new ["2.0"]
        end | prim(:double).map do |v|
          PropertyValue::Version.new v
        end
        versionvalue.eof
      end

      def binary
        binary = seq(/[a-zA-Z0-9+\/]*/.r, /={0,2}/.r) do |b, q|
          if (b.length + q.length) % 4 == 0
            PropertyValue::Binary.new(b + q)
          else
            { error: "Malformed binary coding" }
          end
        end
        binary.eof
      end

      def uri
        uri = /\S+/.r.map do |s|
          if s =~ URI::DEFAULT_PARSER.make_regexp
            PropertyValue::Uri.new(s)
          else
            { error: "Invalid URI" }
          end
        end
        uri.eof
      end

      def text_t
        text_t = C::TEXT.map { |t| PropertyValue::Text.new(unescape(t)) }
        text_t.eof
      end

      def textlist
        textlist1 =
          seq(C::TEXT << ",".r, lazy { textlist1 }) { |a, b| [unescape(a), b].flatten } |
          C::TEXT.map { |t| [unescape(t)] }
        textlist = textlist1.map { |m| PropertyValue::Textlist.new m }
        textlist.eof
      end

      def request_statusvalue
        @req_status = Set.new %w{2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 2.10 2.11 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 3.10 3.11 3.12 3.13 3.14 4.0 5.0 5.1 5.2 5.3}
        extdata = seq(";".r, C::TEXT) { |_, t| t }
        request_statusvalue = seq(/[0-9](\.[0-9]){1,2}/.r << ";".r, C::TEXT, extdata._?) do |n, t1, t2|
          return { error: "Invalid request status #{n}" } unless @req_status.include?(n) # RFC 5546
          hash = { statcode: n, statdesc: t1 }
          hash[:extdata] = t2[0] unless t2.empty?
          Vobject::Vcalendar::PropertyValue::Requeststatusvalue.new hash
        end
        request_statusvalue.eof
      end

      def classvalue
        classvalue = (/PUBLIC/i.r | /PRIVATE/i.r | /CONFIDENTIAL/i.r | C::XNAME_VCAL | C::IANATOKEN).map do |m|
          PropertyValue::ClassValue.new m
        end
        classvalue.eof
      end

      def eventstatus
        eventstatus = (/TENTATIVE/i.r | /CONFIRMED/i.r | /CANCELLED/i.r).map do |m|
          PropertyValue::EventStatus.new m
        end
        eventstatus.eof
      end

      def todostatus
        todostatus = (/NEEDS-ACTION/i.r | /COMPLETED/i.r | /IN-PROCESS/i.r | /CANCELLED/i.r).map do |m|
          PropertyValue::Todostatus.new m
        end
        todostatus.eof
      end

      def journalstatus
        journalstatus = (/DRAFT/i.r | /FINAL/i.r | /CANCELLED/i.r).map do |m|
          PropertyValue::Journalstatus.new m
        end
        journalstatus.eof
      end

      def date_t
        date_t = C::DATE
        date_t.eof
      end

      def datelist
        datelist1 = seq(C::DATE << ",".r, lazy { datelist1 }) do |d, l|
          [d, l].flatten
        end | C::DATE.map { |d| [d] }
        datelist = datelist1.map { |m| PropertyValue::Datelist.new m }
        datelist.eof
      end

      def date_time_t
        C::DATE_TIME.eof
      end

      def date_timelist
        date_timelist1 = seq(C::DATE_TIME << ",".r,
                             lazy { date_timelist1 }) do |d, l|
          [d, l].flatten
        end | C::DATE_TIME.map { |d| [d] }
        date_timelist = date_timelist1.map do |m|
          PropertyValue::Datetimelist.new m
        end
        date_timelist.eof
      end

      def date_time_utc_t
        date_time_utc_t = C::DATE_TIME_UTC
        date_time_utc_t.eof
      end

      def date_time_utclist
        date_time_utclist1 = seq(C::DATE_TIME_UTC << ",".r, lazy { date_time_utclist1 }) do |d, l|
          [d, l].flatten
        end | C::DATE_TIME_UTC.map { |d| [d] }
        date_time_utclist = date_time_utclist1.map do |m|
          PropertyValue::Datetimeutclist.new m
        end
        date_time_utclist.eof
      end

      def duration_t
        duration = C::DURATION.map { |d| PropertyValue::Duration.new d }
        duration.eof
      end

      def periodlist
        period_explicit = seq(C::DATE_TIME << "/".r, C::DATE_TIME) do |s, e|
          { start: s, end: e }
        end
        period_start = seq(C::DATE_TIME << "/".r, C::DURATION) do |s, d|
          { start: s, duration: PropertyValue::Duration.new(d) }
        end
        period = period_explicit | period_start
        periodlist1 = seq(period << ",".r, lazy { periodlist1 }) do |p, l|
          [p, l].flatten
        end | period.map { |p| [p] }
        periodlist = periodlist1.map { |m| PropertyValue::Periodlist.new m }
        periodlist.eof
      end

      def transpvalue
        transpvalue = (/OPAQUE/i.r | /TRANSPARENT/i.r).map do |m|
          PropertyValue::TranspValue.new m
        end
        transpvalue.eof
      end

      def utc_offset
        utc_offset = seq(C::SIGN, /[0-9]{2}/.r, /[0-9]{2}/.r,
                         /[0-9]{2}/.r._?) do |sign, h, m, sec|
          hash = { sign: sign, hr: h, min: m }
          hash[:sec] = sec[0] unless sec.empty?
          PropertyValue::Utcoffset.new hash
        end
        utc_offset.eof
      end

      def actionvalue
        actionvalue = (/AUDIO/i.r | /DISPLAY/i.r | /EMAIL/i.r | C::IANATOKEN |
                       C::XNAME_VCAL).map { |m| PropertyValue::ActionValue.new m }
        actionvalue.eof
      end

      def boolean
        boolean = C::BOOLEAN.map { |b| PropertyValue::Boolean.new b }
        boolean.eof
      end

      # RFC 5546
      def methodvalue
        methodvalue = (/PUBLISH/i.r | /REQUEST/i.r | /REPLY/i.r | /ADD/i.r |
                       /CANCEL/i.r | /REFRESH/i.r | /COUNTER/i.r |
                       /DECLINECOUNTER/i.r).map { |m| PropertyValue::MethodValue.new m }
        methodvalue.eof
      end

      # RFC 7953
      def busytype
        busytype = (/BUSY-UNAVAILABLE/i.r | /BUSY-TENTATIVE/i.r | /BUSY/i.r |
                    C::IANATOKEN |
                    C::XNAME_VCAL).map { |m| PropertyValue::BusyType.new m }
        busytype.eof
      end

      # https://www.w3.org/TR/2011/REC-css3-color-20110607/#svg-color
      def color
        color = C::COLOR.map { |m| PropertyValue::Color.new m }
        color.eof
      end

      # text escapes: \\ \; \, \N \n
      def unescape(x)
        # temporarily escape \\ as \007f, which is disallowed in any text
        x.gsub(/\\\\/, "\u007f").gsub(/\\;/, ";").gsub(/\\,/, ",").
          gsub(/\\[Nn]/, "\n").tr("\u007f", "\\")
      end

      def registered_propname
        registered_propname = C::NAME_VCAL
        registered_propname.eof
      end

      def registered_propname?(x)
        p = registered_propname.parse(x)
        not(Rsec::INVALID[p])
      end

      # Enforce type restrictions on values of particular properties.
      # If successful, return typed interpretation of string
      def typematch(strict, key, params, component, value, ctx)
        errors = []
        errors << property_parent(strict, key, component, value, ctx)
        ctx1 = Rsec::ParseContext.new value, "source"
        case key
        when :CALSCALE
          ret = calscalevalue._parse ctx1
        when :METHOD
          ret = methodvalue._parse ctx1
        when :VERSION
          ret = versionvalue._parse ctx1
        when :ATTACH
          ret = if params[:VALUE] == "BINARY"
                  binary._parse ctx1
                else
                  uri._parse ctx1
                end
        when :IMAGE
          parse_err(strict, errors, "No VALUE parameter specified for property #{key}", ctx1) if params.empty?
          parse_err(strict, errors, "No VALUE parameter specified for property #{key}", ctx1) unless params[:VALUE]
          if params[:VALUE] == "BINARY"
            parse_err(strict, errors, "No ENCODING parameter specified for property #{key}", ctx1) unless params[:ENCODING]
            parse_err(strict, errors, "Incorrect ENCODING parameter specified for property #{key}", ctx1) unless params[:ENCODING] == "BASE64"
            ret = binary._parse ctx1
          elsif params[:VALUE] == "URI"
            ret = uri._parse ctx1
          else
            parse_err(strict, errors, "Incorrect VALUE parameter specified for property #{key}", ctx1)
          end
        when :CATEGORIES, :RESOURCES
          ret = textlist._parse ctx1
        when :CLASS
          ret = classvalue._parse ctx1
        when :COMMENT, :DESCRIPTION, :LOCATION, :SUMMARY, :TZID, :TZNAME,
          :CONTACT, :RELATED_TO, :UID, :PRODID, :NAME
          ret = text_t._parse ctx1
        when :GEO
          ret = geovalue._parse ctx1
        when :PERCENT_COMPLETE
          ret = percent_complete._parse ctx1
        when :PRIORITY
          ret = priority._parse ctx1
        when :STATUS
          ret = case component
                when :EVENT
                  eventstatus._parse ctx1
                when :TODO
                  todostatus._parse ctx1
                when :JOURNAL
                  journalstatus._parse ctx1
                else
                  text_t._parse ctx1
                end
        when :COMPLETED, :CREATED, :DTSTAMP, :LAST_MODIFIED
          ret = date_time_utc_t._parse ctx1
        when :DTEND, :DTSTART, :DUE, :RECURRENCE_ID
          if params && params[:VALUE] == "DATE"
            ret = date_t._parse ctx1
          elsif component == :FREEBUSY
            ret = date_time_utc_t._parse ctx1
          elsif params && params[:TZID]
            if [:STANDARD || :DAYLIGHT].include? component
              parse_err(strict, errors, "Specified TZID within property #{key} in #{component}", ctx1)
            end
            begin
              tz = TZInfo::Timezone.get(params[:TZID])
              ret = date_time_t._parse ctx1
              # note that we use the registered tz information to map to UTC, rather than look up the values witin the VTIMEZONE component
              ret.value = { time: tz.local_to_utc(ret.value[:time]), zone: params[:TZID] }
            rescue
              # undefined timezone: default to floating local
              ret = date_time_t._parse ctx1
            end
          else
            ret = date_time_t._parse ctx1
          end
        when :EXDATE
          if params && params[:VALUE] == "DATE"
            ret = datelist._parse ctx1
          elsif params && params[:TZID]
            if [:STANDARD || :DAYLIGHT].include? component
              parse_err(strict, errors, "Specified TZID within property #{key} in #{component}", ctx1)
            end
            tz = TZInfo::Timezone.get(params[:TZID])
            ret = date_timelist._parse ctx1
            ret.value.each do |x|
              x.value = { time: tz.local_to_utc(x.value[:time]), zone: params[:TZID] }
            end
          else
            ret = date_timelist._parse ctx1
          end
        when :RDATE
          if params && params[:VALUE] == "DATE"
            ret = datelist._parse ctx1
          elsif params && params[:VALUE] == "PERIOD"
            ret = periodlist._parse ctx1
          elsif params && params[:TZID]
            if [:STANDARD || :DAYLIGHT].include? component
              parse_err(strict, errors, "Specified TZID within property #{key} in #{component}", ctx1)
            end
            tz = TZInfo::Timezone.get(params[:TZID])
            ret = date_timelist._parse ctx1
            ret.value.each do |x|
              x.value = { time: tz.local_to_utc(x.value[:time]), zone: params[:TZID] }
            end
          else
            ret = date_timelist._parse ctx1
          end
        when :TRIGGER
          if params && params[:VALUE] == "DATE-TIME" || /^\d{8}T/.match(value)
            if params && params[:RELATED]
              parse_err(strict, errors, "Specified RELATED within property #{key} as date-time", ctx1)
            end
            ret = date_time_utc_t._parse ctx1
          else
            ret = duration_t._parse ctx1
          end
        when :FREEBUSY
          ret = periodlist._parse ctx1
        when :TRANSP
          ret = transpvalue._parse ctx1
        when :TZOFFSETFROM, :TZOFFSETTO
          ret = utc_offset._parse ctx1
        when :TZURI, :URL, :SOURCE, :CONFERENCE
          if key == :CONFERENCE
            parse_err(strict, errors, "Missing URI VALUE parameter", ctx1) if params.empty?
            parse_err(strict, errors, "Missing URI VALUE parameter", ctx1) if !params[:VALUE]
            parse_err(strict, errors, "report_error Type mismatch of VALUE parameter #{params[:VALUE]} for property #{key}", ctx1) if params[:VALUE] != "URI"
          end
          ret = uri._parse ctx1
        when :ATTENDEE, :ORGANIZER
          ret = uri._parse ctx1
        when :RRULE
          ret = recur._parse ctx1
        when :ACTION
          ret = actionvalue._parse ctx1
        when :REPEAT, :SEQUENCE
          ret = integer._parse ctx1
        when :REQUEST_STATUS
          ret = request_statusvalue._parse ctx1
          # RFC 7953
        when :BUSYTYPE
          ret = busytype._parse ctx1
          # RFC 7986
        when :REFRESH_INTERVAL
          parse_err(strict, errors, "Missing VALUE parameter for property #{key}", ctx1) if params.empty?
          parse_err(strict, errors, "Missing VALUE parameter for property #{key}", ctx1) if !params[:VALUE]
          parse_err(strict, errors, "Type mismatch of VALUE parameter #{params[:VALUE]} for property #{key}", ctx1) if params[:VALUE] != "DURATION"
          ret = duration_t._parse ctx1
          # RFC 7986
        when :COLOR
          ret = color._parse ctx1
        else
          if params && params[:VALUE]
            case params[:VALUE]
            when "BOOLEAN"
              ret = boolean._parse ctx1
            when "BINARY"
              ret = binary._parse ctx1
            when "CAL-ADDRESS"
              ret = uri._parse ctx1
            when "DATE-TIME"
              ret = date_time_t._parse ctx1
            when "DATE"
              ret = date_t._parse ctx1
            when "DURATION"
              ret = duration_t._parse ctx1
            when "FLOAT"
              ret = float_t._parse ctx1
            when "INTEGER"
              ret = integer._parse ctx1
            when "PERIOD"
              ret = period._parse ctx1
            when "RECUR"
              ret = recur._parse ctx1
            when "TEXT"
              ret = text_t._parse ctx1
            when "TIME"
              ret = time_t._parse ctx1
            when "URI"
              ret = uri._parse ctx1
            when "UTC-OFFSET"
              ret = utc_offset._parse ctx1
            end
          else
            ret = text_t._parse ctx1
          end
        end
        if ret.is_a?(Hash) && ret[:error]
          parse_err(strict, errors, "#{ret[:error]} for property #{key}, value #{value}", ctx)
        end
        if Rsec::INVALID[ret]
          parse_err(strict, errors, "Type mismatch for property #{key}, value #{value}", ctx)
        end
        Rsec::Fail.reset
        [ret, errors]
      end

      private

      def parse_err(strict, errors, msg, ctx)
        if strict
          raise ctx.report_error msg, "source"
        else
          errors << ctx.report_error(msg, "source")
        end
      end
    end
  end
end
