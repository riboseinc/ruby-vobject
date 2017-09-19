require "rsec"
require "set"
require "uri"
require "date"
#require "tzinfo"
include Rsec::Helpers
require "vobject/vcard/version"
require "vobject"
require_relative './propertyvalue'

module Vcard::V3_0
  class Typegrammars

    class << self

      # property value types, each defining their own parser

      def binary
        binary = seq(/[a-zA-Z0-9+\/]*/.r, /={0,2}/.r) { |b, q|
          ( (b.length + q.length) % 4 == 0 ) ? PropertyValue::Binary.new(b + q)
          : {error: 'Malformed binary coding'}
        }
        binary.eof
      end

      def phoneNumber
        # This is on the lax side; there should be up to 15 digits
        # Will allow letters
        phoneNumber = /[0-9() +A-Z-]+/i.r.map { |p| PropertyValue::Phonenumber.new p}
        phoneNumber.eof
      end

      def geovalue
        float      = prim(:double)
        geovalue = seq(float << ";".r, float) { |a, b|
          ( a <= 180.0 && a >= -180.0 && b <= 180 && b > -180 ) ?
            PropertyValue::Geovalue.new(lat: a, long: b) :
            {error: 'Latitude/Longitude outside of range -180..180'}
        }
        geovalue.eof
      end


      def classvalue 
        iana_token = /[a-zA-Z\d\-]+/.r
        xname = seq( '[xX]-', /[a-zA-Z0-9-]+/.r).map(&:join)
        classvalue = (/PUBLIC/i.r | /PRIVATE/i.r | /CONFIDENTIAL/i.r | iana_token | xname).map { |m|
          PropertyValue::ClassValue.new m }
        classvalue.eof
      end

      def integer 
        integer = prim(:int32).map { |i| PropertyValue::Integer.new i }
        integer.eof
      end

      def floatT
        floatT 	 = prim(:double).map { |f| PropertyValue::Float.new f }
        floatT.eof
      end

      def iana_token
        iana_token = /[a-zA-Z\d\-]+/.r.map { |x| PropertyValue::Ianatoken.new x }
        iana_token.eof
      end

      def versionvalue
        versionvalue = "3.0".r.map { |v| PropertyValue::Version.new v}
        versionvalue.eof
      end

      def profilevalue
        profilevalue = /VCARD/i.r.map { |v| PropertyValue::Profilevalue.new v}
        profilevalue.eof
      end

      def uri
        uri    = /\S+/.r.map { |s|
          s =~ URI::regexp ? PropertyValue::Uri.new(s) :
            {error: 'Invalid URI'}
        }
        uri.eof
      end

      def textT
        textT = C::TEXT3.map { |t| PropertyValue::Text.new(unescape t) }
        textT.eof
      end

      def textlist
        text = C::TEXT3
        textlist1 =
          seq(text << ",".r, lazy {textlist1}) { |a, b| [unescape(a), b].flatten } |
          text.map { |t| [unescape(t)]}
        textlist = textlist1.map { |m| PropertyValue::Textlist.new m }
        textlist.eof
      end

      def org
        text = C::TEXT3
        org1 =
          seq(text << ";".r, lazy {org1}) { |a, b| [unescape(a), b].flatten } |
          text.map { |t| [unescape(t)]}
        org	 = org1.map { |o| PropertyValue::Org.new o }
        org.eof
      end

      def dateT
        dateT = seq(/[0-9]{4}/.r, /-/.r._? >> /[0-9]{2}/.r, /-/.r._? >> /[0-9]{2}/.r) { |yy, mm, dd|
          PropertyValue::Date.new(year: yy, month: mm, day: dd)
        }
        dateT.eof
      end

      def time_t	
        utc_offset = seq(C::SIGN, /[0-9]{2}/.r << /:/.r._?, /[0-9]{2}/.r) do |s, h, m|
          { sign: s, hour: h, min: m }
        end
        zone = utc_offset.map { |u| u } |
          /Z/i.r.map { |z| "Z" }
        hour = /[0-9]{2}/.r
        minute = /[0-9]{2}/.r
        second = /[0-9]{2}/.r
        secfrac = seq(",".r >> /[0-9]+/)
        time_t = seq(hour, /:/._?, minute, /:/._?, second, secfrac._?, zone._?) do |h, _, m, _, s, f, z|
          h = { hour: h, min: m, sec: s }
          h[:zone] = z[0] unless z.empty?
          h[:secfrac] = f[0] unless f.empty?
          PropertyValue::Time.new(h)
        end
        time_t.eof
      end

      def date_time
        utc_offset = seq(C::SIGN, /[0-9]{2}/.r << /:/.r._?, /[0-9]{2}/.r) do |s, h, m|
          { sign: s, hour: h, min: m }
        end
        zone = utc_offset.map { |u| u } |
          /Z/i.r.map { "Z" }
        hour = /[0-9]{2}/.r
        minute = /[0-9]{2}/.r
        second = /[0-9]{2}/.r
        secfrac = seq(",".r >> /[0-9]+/)
        date = seq(/[0-9]{4}/.r, /-/.r._?, /[0-9]{2}/.r, /-/.r._?, /[0-9]{2}/.r) do |yy, _, mm, _, dd|
          { year: yy, month: mm, day: dd }
        end
        time = seq(hour << /:/.r._?, minute << /:/.r._?, second, secfrac._?, zone._?) do |h, m, s, f, z|
          h = { hour: h, min: m, sec: s }
          h[:zone] = if z.empty?
                       ""
                     else
                       z[0]
                     end
          h[:secfrac] = f[0] unless f.empty?
          h
        end
        date_time = seq(date << "T".r, time) do |d, t|
          PropertyValue::DateTimeLocal.new(d.merge(t))
        end
        date_time.eof
      end

      def date_or_date_time
        utc_offset = seq(C::SIGN, /[0-9]{2}/.r << /:/.r._?, /[0-9]{2}/.r) do |s, h, m|
          { sign: s, hour: h, min: m }
        end
        zone = utc_offset.map { |u| u } |
          /Z/i.r.map { "Z" }
        hour = /[0-9]{2}/.r
        minute = /[0-9]{2}/.r
        second = /[0-9]{2}/.r
        secfrac = seq(",".r >> /[0-9]+/)
        date = seq(/[0-9]{4}/.r << /-/.r._?, /[0-9]{2}/.r << /-/.r._?, /[0-9]{2}/.r) do |yy, mm, dd|
          { year: yy, month: mm, day: dd }
        end
        time = seq(hour << /:/.r._?, minute << /:/.r._?, second, secfrac._?, zone._?) do |h, m, s, f, z|
          h = { hour: h, min: m, sec: s }
          h[:zone] = z[0] unless z.empty?
          h[:secfrac] = f[0] unless f.empty?
          h
        end
        date_or_date_time = seq(date << "T".r, time) do |d, t|
          PropertyValue::DateTimeLocal.new(d.merge(t))
        end | date.map { |d| PropertyValue::Date.new(d) }
        date_or_date_time.eof
      end

      def utc_offset
        utc_offset = seq(C::SIGN, /[0-9]{2}/.r, /:/.r._?, /[0-9]{2}/.r) do |s, h, _, m|
          PropertyValue::Utcoffset.new(sign: s, hour: h, min: m)
        end
        utc_offset.eof
      end

      def kindvalue
        iana_token = /[a-zA-Z\d\-]+/.r
        xname = seq(/[xX]-/, /[a-zA-Z0-9-]+/.r).map(&:join)
        kindvalue = (/individual/i.r | /group/i.r | /org/i.r | /location/i.r |
                     iana_token | xname).map do |k|
          PropertyValue::Kindvalue.new(k)
        end
        kindvalue.eof
      end

      def fivepartname
        text = C::TEXT3
        component = seq(text << ",".r, lazy { component }) do |a, b|
          [unescape(a), b].flatten
        end | text.map { |t| [unescape(t)] }
        fivepartname1 = seq(component << ";".r, component << ";".r, component << ";".r,
                            component << ";".r, component) do |a, b, c, d, e|
          a = a[0] if a.length == 1
          b = b[0] if b.length == 1
          c = c[0] if c.length == 1
          d = d[0] if d.length == 1
          e = e[0] if e.length == 1
          { surname: a, givenname: b, middlename: c, honprefix: d, honsuffix: e }
        end | seq(component << ";".r, component << ";".r, component << ";".r, component) do |a, b, c, d|
          a = a[0] if a.length == 1
          b = b[0] if b.length == 1
          c = c[0] if c.length == 1
          d = d[0] if d.length == 1
          { surname: a, givenname: b, middlename: c, honprefix: d, honsuffix: "" }
        end | seq(component << ";".r, component << ";".r, component) do |a, b, c|
          a = a[0] if a.length == 1
          b = b[0] if b.length == 1
          c = c[0] if c.length == 1
          { surname: a, givenname: b, middlename: c, honprefix: "", honsuffix: "" }
        end | seq(component << ";".r, component) do |a, b|
          a = a[0] if a.length == 1
          b = b[0] if b.length == 1
          { surname: a, givenname: b, middlename: "", honprefix: "", honsuffix: "" }
        end | component.map do |a|
          a = a[0] if a.length == 1
          { surname: a, givenname: "", middlename: "", honprefix: "", honsuffix: "" }
        end
        fivepartname = fivepartname1.map { |n| PropertyValue::Fivepartname.new(n) }
        fivepartname.eof
      end

      def address
        text = C::TEXT3
        component = seq(text << ",".r, lazy { component }) do |a, b|
          [unescape(a), b].flatten
        end | text.map { |t| [unescape(t)] }
        address1 = seq(component << ";".r, component << ";".r, component << ";".r, component << ";".r,
                       component << ";".r, component << ";".r, component) do |a, b, c, d, e, f, g|
          a = a[0] if a.length == 1
          b = b[0] if b.length == 1
          c = c[0] if c.length == 1
          d = d[0] if d.length == 1
          e = e[0] if e.length == 1
          f = f[0] if f.length == 1
          g = g[0] if g.length == 1
          { pobox: a, ext: b, street: c,
            locality: d, region: e, code: f, country: g }
        end | seq(component << ";".r, component << ";".r, component << ";".r, component << ";".r,
                  component << ";".r, component) do |a, b, c, d, e, f|
          a = a[0] if a.length == 1
          b = b[0] if b.length == 1
          c = c[0] if c.length == 1
          d = d[0] if d.length == 1
          e = e[0] if e.length == 1
          f = f[0] if f.length == 1
          { pobox: a, ext: b, street: c,
            locality: d, region: e, code: f, country: "" }
        end | seq(component << ";".r, component << ";".r, component << ";".r,
                  component << ";".r, component) do |a, b, c, d, e|
          a = a[0] if a.length == 1
          b = b[0] if b.length == 1
          c = c[0] if c.length == 1
          d = d[0] if d.length == 1
          e = e[0] if e.length == 1
          { pobox: a, ext: b, street: c,
            locality: d, region: e, code: "", country: "" }
        end | seq(component << ";".r, component << ";".r, component << ";".r, component) do |a, b, c, d|
          a = a[0] if a.length == 1
          b = b[0] if b.length == 1
          c = c[0] if c.length == 1
          d = d[0] if d.length == 1
          { pobox: a, ext: b, street: c,
            locality: d, region: "", code: "", country: "" }
        end | seq(component << ";".r, component << ";".r, component) do |a, b, c|
          a = a[0] if a.length == 1
          b = b[0] if b.length == 1
          c = c[0] if c.length == 1
          { pobox: a, ext: b, street: c,
            locality: "", region: "", code: "", country: "" }
        end | seq(component << ";".r, component) do |a, b|
          a = a[0] if a.length == 1
          b = b[0] if b.length == 1
          { pobox: a, ext: b, street: "",
            locality: "", region: "", code: "", country: "" }
        end | component.map do |a|
          a = a[0] if a.length == 1
          { pobox: a, ext: "", street: "",
            locality: "", region: "", code: "", country: "" }
        end
        address = address1.map { |n| PropertyValue::Address.new(n) }
        address.eof
      end

      def registered_propname
        registered_propname = C::NAME_VCARD
        registered_propname.eof
      end

      def registered_propname?(x)
        p = registered_propname.parse(x)
        not(Rsec::INVALID[p])
      end

      # text escapes: \\ \; \, \N \n
      def unescape(x)
        # temporarily escape \\ as \007f, which is disallowed in any text
        x.gsub(/\\\\/, "\u007f").gsub(/\\;/, ";").gsub(/\\,/, ",").gsub(/\\[Nn]/, "\n").tr("\u007f", "\\")
      end

      # Enforce type restrictions on values of particular properties.
      # If successful, return typed interpretation of string
      def typematch(strict, key, params, _component, value, ctx)
        errors = []
        params[:VALUE] = params[:VALUE].downcase if params && params[:VALUE]
        ctx1 = Rsec::ParseContext.new value, "source"
        case key
        when :VERSION
          ret = versionvalue._parse ctx1
        when :SOURCE, :URL, :IMPP, :FBURL, :CALURI, :CALADRURI, :CAPURI
          ret = uri._parse ctx1
          # not imposing filename restrictions on calendar URIs
        when :NAME, :FN, :LABEL, :EMAIL, :MAILER, :TITLE, :ROLE, :NOTE, :PRODID, :SORT_STRING, :UID
          ret = textT._parse ctx1
        when :CLASS
          ret = classvalue._parse ctx1
        when :CATEGORIES, :NICKNAME
          ret = textlist._parse ctx1
        when :ORG
          ret = org._parse ctx1
        when :PROFILE
          ret = profilevalue._parse ctx1
        when :N
          ret = fivepartname._parse ctx1
        when :PHOTO, :LOGO, :SOUND
          ret = if params && params[:VALUE] == "uri"
                  uri._parse ctx1
                else
                  binary._parse ctx1
                end
        when :KEY
          ret = if params && params[:ENCODING] == "b"
                  binary._parse ctx1
                else
                  textT._parse ctx1
                end
        when :BDAY
          ret = if params && params[:VALUE] == "date-time"
                  date_time._parse ctx1
                elsif params && params[:VALUE] == "date"
                  dateT._parse ctx1
                else
                  # unlike VCARD 4, can have either date || date_time without explicit value switch
                  date_or_date_time._parse ctx1
                end
        when :REV
          ret = if params && params[:VALUE] == "date"
                  dateT._parse ctx1
                elsif params && params[:VALUE] == "date-time"
                  date_time._parse ctx1
                else
                  # unlike VCARD 4, can have either date || date_time without explicit value switch
                  ret = date_or_date_time._parse ctx1
                end
        when :ADR
          ret = address._parse ctx1
        when :TEL
          ret = phoneNumber._parse ctx1
        when :TZ
          ret = if params && params[:VALUE] == "text"
                  textT._parse ctx1
                else
                  utc_offset._parse ctx1
                end
        when :GEO
          ret = geovalue._parse ctx1
        when :AGENT
          if params && params[:VALUE] == "uri"
            ret = uri._parse ctx1
          else
            # unescape
            value = value.gsub(/\\n/, "\n").gsub(/\\;/, ";").gsub(/\\,/, ",").gsub(/\\:/, ":")
            # spec says that colons need to be escaped, but none of the examples do so
            value = value.gsub(/BEGIN:VCARD\n/, "BEGIN:VCARD\nVERSION:3.0\n") unless value =~ /\nVERSION:3\.0/
            ctx1 = Rsec::ParseContext.new value, "source"
            ret = PropertyValue::Agent.new(Grammar.new(strict).vobject_grammar._parse(ctx1))
            # TODO same strictness as grammar
          end
        else
          ret = textT._parse ctx1
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
