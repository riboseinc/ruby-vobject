require "rsec"
require "set"
require "uri"
require "date"
include Rsec::Helpers
require "vobject"
require_relative "./propertyvalue"

module Vcard::V4_0
  class Typegrammars
    class << self
      # property value types, each defining their own parser
      def integer
        integer = prim(:int32).map { |i| PropertyValue::Integer.new i }
        integer.eof
      end

      def float_t
        float_t = prim(:double).map { |f| PropertyValue::Float.new f }
        float_t.eof
      end

      def iana_token
        iana_token = C::IANATOKEN.map { |x| PropertyValue::Ianatoken.new x }
        iana_token.eof
      end

      def versionvalue
        versionvalue = "4.0".r.map { |v| PropertyValue::Version.new v }
        versionvalue.eof
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

      def clientpidmap
        uri = /\S+/.r.map do |s|
          if s =~ URI::DEFAULT_PARSER.make_regexp
            s
          else
            { error: "Invalid URI" }
          end
        end
        clientpidmap = seq(/[0-9]/.r << ";".r, uri) do |(a, b)|
          PropertyValue::Clientpidmap.new(pid: a, uri: b)
        end
        clientpidmap.eof
      end

      def text_t
        text_t = C::TEXT4.map { |t| PropertyValue::Text.new(unescape(t)) }
        text_t.eof
      end

      def textlist
        textlist1 =
          seq(C::TEXT4 << ",".r, lazy { textlist1 }) { |(a, b)| [unescape(a), b].flatten } |
          C::TEXT4.map { |t| [unescape(t)] }
        textlist = textlist1.map { |m| PropertyValue::Textlist.new m }
        textlist.eof
      end

      def date_t
        date_t1 = seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) do |(yy, mm, dd)|
          { year: yy, month: mm, day: dd }
        end | seq(/[0-9]{4}/.r << "-".r, /[0-9]{2}/.r) do |(yy, dd)|
          { year: yy, day: dd }
        end | /[0-9]{4}/.r do |yy|
          { year: yy }
        end | seq("--".r >> /[0-9]{2}/.r, /[0-9]{2}/.r) do |(mm, dd)|
          { month: mm, day: dd }
        end | seq("--".r >> /[0-9]{2}/.r) do |mm|
          { month: mm }
        end | seq("--", "-", /[0-9]{2}/.r) do |(_, _, dd)|
          { day: dd }
        end
        date_t = date_t1.map { |d| PropertyValue::Date.new d }
        date_t.eof
      end

      def date_noreduc
        date_noreduc1 = seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) do |(yy, mm, dd)|
          { year: yy, month: mm, day: dd }
        end | seq("--".r >> /[0-9]{2}/.r, /[0-9]{2}/.r) do |(mm, dd)|
          { month: mm, day: dd }
        end | seq("--", "-", /[0-9]{2}/.r) do |(_, _, dd)|
          { day: dd }
        end
        date_noreduc = date_noreduc1.map { |d| PropertyValue::Date.new d }
        date_noreduc.eof
      end

      def date_complete
        date_complete1 = seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) do |(yy, mm, dd)|
          { year: yy, month: mm, day: dd }
        end
        date_complete = date_complete1.map { |d| PropertyValue::Date.new d }
        date_complete.eof
      end

      def time_t
        hour = /[0-9]{2}/.r
        minute = /[0-9]{2}/.r
        second = /[0-9]{2}/.r
        time1 = seq(hour, minute, second, C::ZONE._?) do |(h, m, s, z)|
          h = { hour: h, min: m, sec: s }
          h[:zone] = z[0] unless z.empty?
          h
        end | seq(hour, minute, C::ZONE._?) do |(h, m, z)|
          h = { hour: h, min: m }
          h[:zone] = z[0] unless z.empty?
          h
        end | seq(hour, C::ZONE._?) do |(h, z)|
          h = { hour: h }
          h[:zone] = z[0] unless z.empty?
          h
          # } | seq("-", minute, second, C::ZONE._?) { |(m, s, z)|
          # errata: remove zones from truncated times
        end | seq("-".r >> minute, second) do |(m, s)|
          { min: m, sec: s }
          # } | seq("-", minute, C::ZONE._?) { |(m, z)|
          # errata: remove zones from truncated times
        end | seq("-".r >> minute) do |m|
          { min: m }
          # } | seq("-", "-", second, C::ZONE._?) do |(s, z)|
          # errata: remove zones from truncated times
        end | seq("-", "-", second) do |(_, _, s)|
          h = { sec: s }
          h
        end
        time = time1.map { |d| PropertyValue::Time.new d }
        time.eof
      end

      def time_notrunc
        time_notrunc1 = seq(hour, minute, second, C::ZONE._?) do |(h, m, s, z)|
          h = { hour: h, min: m, sec: s }
          h[:zone] = z[0] unless z.empty?
          h
        end | seq(hour, minute, C::ZONE._?) do |(h, m, z)|
          h = { hour: h, min: m }
          h[:zone] = z[0] unless z.empty?
          h
        end | seq(hour, C::ZONE._?) do |(h, z)|
          h = { hour: h }
          h[:zone] = z[0] unless z.empty?
          h
        end
        time_notrunc = time_notrunc1.map { |d| PropertyValue::Time.new d }
        time_notrunc.eof
      end

      def time_complete
        time_complete1 = seq(hour, minute, second, C::ZONE._?) do |(h, m, s, z)|
          h = { hour: h, min: m, sec: s }
          h[:zone] = z[0] unless z.empty?
          h
        end
        time_complete = time_complete1.map { |d| PropertyValue::Time.new d }
        time_complete.eof
      end

      def date_time
        hour = /[0-9]{2}/.r
        minute = /[0-9]{2}/.r
        second = /[0-9]{2}/.r
        time_notrunc = seq(hour, minute, second, C::ZONE._?) do |(h, m, s, z)|
          h = { hour: h, min: m, sec: s }
          h[:zone] = z[0] unless z.empty?
          h
        end | seq(hour, minute, C::ZONE._?) do |(h, m, z)|
          h = { hour: h, min: m }
          h[:zone] = z[0] unless z.empty?
          h
        end | seq(hour, C::ZONE._?) do |(h, z)|
          h = { hour: h }
          h[:zone] = z[0] unless z.empty?
          h
        end
        date_noreduc = seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) do |(yy, mm, dd)|
          { year: yy, month: mm, day: dd }
        end | seq("--".r >> /[0-9]{2}/.r, /[0-9]{2}/.r) do |(mm, dd)|
          { month: mm, day: dd }
        end | seq("--", "-", /[0-9]{2}/.r) do |(_, _, dd)|
          { day: dd }
        end
        date_time = seq(date_noreduc << "T".r, time_notrunc) do |(d, t)|
          d = d.merge t
          PropertyValue::DateTimeLocal.new d
        end
        date_time.eof
      end

      def timestamp
        date_complete = seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) do |(yy, mm, dd)|
          { year: yy, month: mm, day: dd }
        end
        hour = /[0-9]{2}/.r
        minute = /[0-9]{2}/.r
        second = /[0-9]{2}/.r
        time_complete = seq(hour, minute, second, C::ZONE._?) do |(h, m, s, z)|
          h = { hour: h, min: m, sec: s }
          h[:zone] = z[0] unless z.empty?
          h
        end
        timestamp = seq(date_complete << "T".r, time_complete) do |(d, t)|
          ret = PropertyValue::DateTimeLocal.new(d.merge(t))
          ret.type = 'timestamp'
          ret
        end
        timestamp.eof
      end

      def date_and_or_time
        hour = /[0-9]{2}/.r
        minute = /[0-9]{2}/.r
        second = /[0-9]{2}/.r
        time_notrunc = seq(hour, minute, second, C::ZONE._?) do |(h, m, s, z)|
          h = { hour: h, min: m, sec: s }
          h[:zone] = z[0] unless z.empty?
          h
        end | seq(hour, minute, C::ZONE._?) do |(h, m, z)|
          h = { hour: h, min: m }
          h[:zone] = z[0] unless z.empty?
          h
        end | seq(hour, C::ZONE._?) do
          h = { hour: h }
          h[:zone] = z[0] unless z.empty?
          h
        end
        date_noreduc = seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) do |(yy, mm, dd)|
          { year: yy, month: mm, day: dd }
        end | seq("--", /[0-9]{2}/.r, /[0-9]{2}/.r) do |(_, mm, dd)|
          { month: mm, day: dd }
        end | seq("--", "-", /[0-9]{2}/.r) { |(_, _, dd)| { day: dd } }
        date_time = seq(date_noreduc << "T".r, time_notrunc) { |(d, t)| d.merge t }
        date = seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) do |(yy, mm, dd)|
          { year: yy, month: mm, day: dd }
        end | seq(/[0-9]{4}/.r << "-".r, /[0-9]{2}/.r) do |(yy, dd)|
          { year: yy, day: dd }
        end | /[0-9]{4}/.r do |yy|
          { year: yy }
        end | seq("--", /[0-9]{2}/.r, /[0-9]{2}/.r) do |(_, mm, dd)|
          { month: mm, day: dd }
        end | seq("--", /[0-9]{2}/.r) do |(_, mm)|
          { month: mm }
        end | seq("--", "-", /[0-9]{2}/.r) do |(_, _, dd)|
          { day: dd }
        end
        time = seq(hour, minute, second, C::ZONE._?) do |(h, m, s, z)|
          h = { hour: h, min: m, sec: s }
          h[:zone] = z[0] unless z.empty?
          h
        end | seq(hour, minute, C::ZONE._?) do |(h, m, z)|
          h = { hour: h, min: m }
          h[:zone] = z[0] unless z.empty?
          h
        end | seq(hour, C::ZONE._?) do |(h, z)|
          h = { hour: h }
          h[:zone] = z[0] unless z.empty?
          h
          # } | seq("-", minute, second, C::ZONE._?) { |(m, s, z)|
          # errata: remove zones from truncated times
        end | seq("-".r >> minute, second) do |(m, s)|
          { min: m, sec: s }
          # } | seq("-", minute, C::ZONE._?) { |(m, z)|
          # errata: remove zones from truncated times
        end | seq("-".r >> minute) do |m|
          { min: m }
          # } | seq("-", "-", second, C::ZONE._?) { |(s, z)|
          # errata: remove zones from truncated times
        end | seq("-", "-", second) do |(_, _, s)|
          { sec: s }
        end
        date_and_or_time = date_time.map do |d| 
          ret = PropertyValue::DateTimeLocal.new d 
          ret.type = "date-and-or-time"
          ret
        end | date.map do |d| 
          ret = PropertyValue::Date.new d 
          ret.type = "date-and-or-time"
          ret
        end | seq("T".r >> time).map do |t| 
          ret = PropertyValue::Time.new t 
          ret.type = "date-and-or-time"
          ret
        end
        date_and_or_time.eof
      end

      def utc_offset
        utc_offset = C::UTC_OFFSET.map { |u| PropertyValue::Utcoffset.new u }
        utc_offset.eof
      end

      def kindvalue
        kindvalue = (/individual/i.r | /group/i.r | /org/i.r | /location/i.r |
                     /application/i.r | C::IANATOKEN |
                     C::XNAME_VCARD).map { |v| PropertyValue::Kindvalue.new v }
        kindvalue.eof
      end

      def fivepartname
        component = seq(C::COMPONENT4 << ",".r, lazy { component }) do |(a, b)|
          [unescape_component(a), b].flatten
        end | C::COMPONENT4.map { |t| [unescape_component(t)] }
        fivepartname = seq(component << ";".r, component << ";".r,
                           component << ";".r, component << ";".r,
                           component) do |(a, b, c, d, e)|
                             a = a[0] if a.length == 1
                             b = b[0] if b.length == 1
                             c = c[0] if c.length == 1
                             d = d[0] if d.length == 1
                             e = e[0] if e.length == 1
                             PropertyValue::Fivepartname.new(surname: a, givenname: b,
                                                             additionalname: c, honprefix: d, honsuffix: e)
                           end
        fivepartname.eof
      end

      def address
        component = seq(C::COMPONENT4 << ",".r, lazy { component }) do |(a, b)|
          [unescape_component(a), b].flatten
        end | C::COMPONENT4.map { |t| [unescape_component(t)] }
        address = seq(component << ";".r, component << ";".r,
                      component << ";".r, component << ";".r,
                      component << ";".r, component << ";".r,
                      component) do |(a, b, c, d, e, f, g)|
                        a = a[0] if a.length == 1
                        b = b[0] if b.length == 1
                        c = c[0] if c.length == 1
                        d = d[0] if d.length == 1
                        e = e[0] if e.length == 1
                        f = f[0] if f.length == 1
                        g = g[0] if g.length == 1
                        PropertyValue::Address.new(pobox: a, ext: b,
                                                   street: c,
                                                   locality: d, region: e, code: f,
                                                   country: g)
                      end
        address.eof
      end

      def gender
        gender1 = seq(/[MFONU]/.r._? << ";", C::TEXT4) do |(sex, gender)|
          sex = sex[0] unless sex.empty?
          { sex: sex, gender: gender }
        end | /[MFONU]/.r.map { |sex| { sex: sex, gender: "" } }
        gender = gender1.map { |g| PropertyValue::Gender.new g }
        gender.eof
      end

      def org
        text = C::COMPONENT4
        org1 =
          seq(text, ";", lazy { org1 }) { |(a, _, b)| [unescape_component(a), b].flatten } |
          text.map { |t| [unescape_component(t)] }
        org = org1.map { |g| PropertyValue::Org.new g }
        org.eof
      end

      def lang
        lang = C::RFC5646LANGVALUE.map { |l| PropertyValue::Lang.new l }
        lang.eof
      end

      def typeparamtel1list
        typeparamtel1 = /TEXT/i.r | /VOICE/i.r | /FAX/i.r | /CELL/i.r | /VIDEO/i.r |
          /PAGER/i.r | /TEXTPHONE/i.r | C::IANATOKEN | C::XNAME_VCARD
        typeparamtel1list = seq(typeparamtel1 << ",".r,
                                lazy { typeparamtel1list }) do |(a, b)|
          [a, b].flatten
        end | typeparamtel1.map { |t| [t] }
        typeparamtel1list.eof
      end

      def typerelatedlist
        typeparamrelated = /CONTACT/i.r | /ACQUAINTANCE/i.r | /FRIEND/i.r |
          /MET/i.r | /CO-WORKER/i.r | /COLLEAGUE/i.r | /CO-RESIDENT/i.r |
          /NEIGHBOR/i.r | /CHILD/i.r | /PARENT/i.r | /SIBLING/i.r | /SPOUSE/i.r |
          /KIN/i.r | /MUSE/i.r | /CRUSH/i.r | /DATE/i.r | /SWEETHEART/i.r |
          /ME/i.r | /AGENT/i.r | /EMERGENCY/i.r
        typerelatedlist =
          seq(typeparamrelated << ";".r,
              lazy { typerelatedlist }) { |(a, b)| [a, b].flatten } |
          typeparamrelated.map { |t| [t] }
        typerelatedlist.eof
      end

      # text escapes: \\ \; \, \N \n
      def unescape(x)
        # temporarily escape \\ as \007f, which is disallowed in any text
        x.gsub(/\\\\/, "\u007f").gsub(/\\,/, ",").gsub(/\\[Nn]/, "\n").
          tr("\u007f", "\\")
      end

      # also escape semicolon for compound types
      def unescape_component(x)
        # temporarily escape \\ as \007f, which is disallowed in any text
        x.gsub(/\\\\/, "\u007f").gsub(/\\;/, ";").gsub(/\\,/, ",").
          gsub(/\\[Nn]/, "\n").tr("\u007f", "\\")
      end

      # Enforce type restrictions on values of particular properties.
      # If successful, return typed interpretation of string
      def typematch(strict, key, params, _component, value)
        errors = []
        ctx1 = Rsec::ParseContext.new value, "source"
        case key
        when :VERSION
          ret = versionvalue._parse ctx1
        when :SOURCE, :PHOTO, :IMPP, :GEO, :LOGO, :MEMBER, :SOUND, :URL, :FBURL,
          :CALADRURI, :CALURI, :ORG_DIRECTORY
          ret = uri._parse ctx1
        when :KIND
          ret = kindvalue._parse ctx1
        when :XML, :FN, :EMAIL, :TITLE, :ROLE, :NOTE, :EXPERTISE, :HOBBY,
          :INTEREST
          ret = text_t._parse ctx1
        when :NICKNAME, :CATEGORIES
          ret = textlist._parse ctx1
        when :ORG
          ret = org._parse ctx1
        when :N
          ret = fivepartname._parse ctx1
        when :ADR
          ret = address._parse ctx1
        when :BDAY, :ANNIVERSARY
          if params && params[:VALUE] == "text"
            if params[:CALSCALE]
              parse_err(strict, errors,
                        "Specified CALSCALE within property #{key} as text", ctx1)
            end
            ret = text_t._parse ctx1
          else
            if params && params[:CALSCALE] && /^T/ =~ value
              parse_err(strict, errors,
                        "Specified CALSCALE within property #{key} as time", ctx1)
            end
            ret = date_and_or_time._parse ctx1
          end
        when :DEATHDATE
          ret = if params && params[:VALUE] == "text"
                  text_t._parse ctx1
                else
                  date_and_or_time._parse ctx1
                end
        when :TEL
          if params && params[:TYPE]
            typestr = params[:TYPE].is_a?(Array) ? params[:TYPE].join(",") : params[:TYPE]
            ret1 = typeparamtel1list.parse typestr
            if !ret1 || Rsec::INVALID[ret1]
              parse_err(strict, errors,
                        "Specified illegal TYPE parameter #{typestr} within property #{key}", ctx1)
            end
          end
          ret = if params && params[:VALUE] == "uri"
                  uri._parse ctx1
                else
                  text_t._parse ctx1
                end
        when :BIRTHPLACE, :DEATHPLACE
          ret = if params && params[:VALUE] == "uri"
                  uri._parse ctx1
                else
                  text_t._parse ctx1
                end
        when :RELATED
          if params && params[:TYPE]
            typestr = params[:TYPE].is_a?(Array) ? params[:TYPE].join(";") : params[:TYPE]
            ret1 = typerelatedlist.parse typestr
            if !ret1 || Rsec::INVALID[ret1]
              parse_err(strict, errors,
                        "Specified illegal TYPE parameter #{typestr} within property #{key}", ctx1)
            end
          end
          ret = if params && params[:VALUE] == "uri"
                  uri._parse ctx1
                else
                  text_t._parse ctx1
                end
        when :UID, :KEY
          ret = if params && params[:VALUE] == "text"
                  text_t._parse ctx1
                else
                  uri._parse ctx1
                end
        when :GENDER
          ret = gender._parse ctx1
        when :LANG
          ret = lang._parse ctx1
        when :TZ
          ret = if params && params[:VALUE] == "uri"
                  uri._parse ctx1
                elsif params && params[:VALUE] == "utc_offset"
                  utc_offset._parse ctx1
                else
                  text_t._parse ctx1
                end
        when :REV
          ret = timestamp._parse ctx1
        when :CLIENTPIDMAP
          if params && params[:PID]
            parse_err(strict, errors, "Specified PID parameter in CLIENTPIDMAP property", @ctx)
          end
          ret = clientpidmap._parse ctx1
        else
          # left completely open in spec
          ret = Vobject::PropertyValue.new value
        end
        if ret.is_a?(Hash) && ret[:error]
          parse_err(strict, errors, "#{ret[:error]} for property #{key}, value #{value}", ctx1)
        end
        if Rsec::INVALID[ret]
          parse_err(strict, errors, "Type mismatch for property #{key}, value #{value}", ctx1)
        end
        ret
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
