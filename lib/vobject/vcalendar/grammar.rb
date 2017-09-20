require "rsec"
require "set"
require "uri"
require "date"
require "tzinfo"
include Rsec::Helpers
require_relative "../../c"
require_relative "../../error"
require "vobject"
require "vobject/vcalendar/typegrammars"
require "vobject/vcalendar/paramcheck"

module Vobject::Vcalendar
  class Grammar
    include C
    attr_accessor :strict, :errors

    class << self
      # RFC 6868
      def rfc6868decode(x)
        x.gsub(/\^n/, "\n").gsub(/\^\^/, "^").gsub(/\^'/, '"')
      end

      def unfold(str)
        str.gsub(/(\r|\n|\r\n)[ \t]/, "")
      end
    end

    def vobject_grammar
      # properties with value cardinality 1
      @cardinality1 = {}
      @cardinality1[:ICAL] = Set.new [:PRODID, :VERSION, :CALSCALE, :METHOD, :UID, :LAST_MOD, :URL,
                                      :REFRESH_INTERVAL, :SOURCE, :COLOR]
      @cardinality1[:EVENT] = Set.new [:UID, :DTSTAMP, :DTSTART, :CLASS, :CREATED, :DESCRIPTION, :GEO, :LAST_MOD,
                                       :LOCATION, :ORGANIZER, :PRIORITY, :SEQ, :STATUS, :TRANSP, :URL, :RECURID, :COLOR]
      @cardinality1[:TODO] = Set.new [:UID, :DTSTAMP, :CLASS, :COMPLETED, :CREATED, :DESCRIPTION, :DTSTART, :GEO, :LAST_MOD,
                                      :LOCATION, :ORGANIZER, :PERCENT_COMPLETE, :PRIORITY, :SEQ, :STATUS, :SUMMARY, :URL, :RECURID, :COLOR]
      @cardinality1[:JOURNAL] = Set.new [:UID, :DTSTAMP, :CLASS, :CREATED, :DTSTART, :LAST_MOD,
                                         :ORGANIZER, :SEQ, :STATUS, :SUMMARY, :URL, :RECURID, :COLOR]
      @cardinality1[:FREEBUSY] = Set.new [:UID, :DTSTAMP, :CONTACT, :DTSTART, :DTEND, :ORGANIZER, :URL]
      @cardinality1[:TIMEZONE] = Set.new [:TZID, :LAST_MOD, :TZURL]
      @cardinality1[:TZ] = Set.new [:DTSTART, :TZOFFSETTTO, :TZOFFSETFROM]
      @cardinality1[:ALARM] = Set.new [:ACTION, :TRIGGER, :DURATION, :REPEAT, :DESCRIPTION, :SUMMARY]
      @cardinality1[:VAVAILABILITY] = Set.new [:UID, :DTSTAMP, :DTSTART, :BUSYTYPE, :CLASS, :CREATED, :DESCRIPTION, :LAST_MOD,
                                               :LOCATION, :ORGANIZER, :PRIORITY, :SEQ, :SUMMARY, :URL]
      @cardinality1[:AVAILABLE] = Set.new [:DTSTAMP, :DTSTART, :UID, :CREATED, :DESCRIPTION, :LAST_MOD, :LOCATION,
                                           :RECURID, :RRULE, :SUMMARY]
      @cardinality1[:PARAM] = Set.new [:FMTTYPE, :LANGUAGE, :ALTREP, :FBTYPE, :TRANSP, :CUTYPE, :MEMBER, :ROLE, :PARTSTAT, :RSVP, :DELEGATED_TO,
                                       :DELEGATED_FROM, :SENT_BY, :CN, :DIR, :RANGE, :RELTYPE, :RELATED, :DISPLAY, :FEATURE, :LABEL]

      group = C::IANATOKEN
      linegroup = group <<  "."
      beginend = /BEGIN/i.r | /END/i.r

      # parameters && parameter types
      paramname = /ALTREP/i.r | /CN/i.r | /CUTYPE/i.r | /DELEGATED-FROM/i.r | /DELEGATED-TO/i.r |
        /DIR/i.r | /ENCODING/i.r | /FMTTYPE/i.r | /FBTYPE/i.r | /LANGUAGE/i.r |
        /MEMBER/i.r | /PARTSTAT/i.r | /RANGE/i.r | /RELATED/i.r | /RELTYPE/i.r |
        /ROLE/i.r | /RSVP/i.r | /SENT-BY/i.r | /TZID/i.r | /RSCALE/i.r | /DISPLAY/i.r |
        /FEATURE/i.r | /LABEL/i.r | /EMAIL/i.r
      otherparamname = C::XNAME_VCAL | seq("".r ^ paramname, C::IANATOKEN)[1]
      paramvalue = C::QUOTEDSTRING_VCAL.map { |s| self.class.rfc6868decode s } |
        C::PTEXT_VCAL.map { |s| self.class.rfc6868decode(s) }
      quotedparamvalue = C::QUOTEDSTRING_VCAL.map { |s| self.class.rfc6868decode s }
      cutypevalue = /INDIVIDUAL/i.r | /GROUP/i.r | /RESOURCE/i.r | /ROOM/i.r | /UNKNOWN/i.r |
        C::XNAME_VCAL | C::IANATOKEN.map
      encodingvalue = /8BIT/i.r | /BASE64/i.r
      fbtypevalue = /FREE/i.r | /BUSY/i.r | /BUSY-UNAVAILABLE/i.r | /BUSY-TENTATIVE/i.r |
        C::XNAME_VCAL | C::IANATOKEN
      partstatevent = /NEEDS-ACTION/i.r | /ACCEPTED/i.r | /DECLINED/i.r | /TENTATIVE/i.r |
        /DELEGATED/i.r | C::XNAME_VCAL | C::IANATOKEN
      partstattodo = /NEEDS-ACTION/i.r | /ACCEPTED/i.r | /DECLINED/i.r | /TENTATIVE/i.r |
        /DELEGATED/i.r | /COMPLETED/i.r | /IN-PROCESS/i.r | C::XNAME_VCAL | C::IANATOKEN
      partstatjour = /NEEDS-ACTION/i.r | /ACCEPTED/i.r | /DECLINED/i.r | C::XNAME_VCAL | C::IANATOKEN
      partstatvalue = partstatevent | partstattodo | partstatjour
      rangevalue = /THISANDFUTURE/i.r
      relatedvalue = /START/i.r | /END/i.r
      reltypevalue = /PARENT/i.r | /CHILD/i.r | /SIBLING/i.r | C::XNAME_VCAL | C::IANATOKEN
      tzidvalue = seq("/".r._?, C::PTEXT_VCAL).map { |_, val| val }
      valuetype = /BINARY/i.r | /BOOLEAN/i.r | /CAL-ADDRESS/i.r | /DATE-TIME/i.r | /DATE/i.r |
        /DURATION/i.r | /FLOAT/i.r | /INTEGER/i.r | /PERIOD/i.r | /RECUR/i.r | /TEXT/i.r |
        /TIME/i.r | /URI/i.r | /UTC-OFFSET/i.r | C::XNAME_VCAL | C::IANATOKEN
      rolevalue = /CHAIR/i.r | /REQ-PARTICIPANT/i.r | /OPT-PARTICIPANT/i.r | /NON-PARTICIPANT/i.r |
        C::XNAME_VCAL | C::IANATOKEN
      pvalue_list = (seq(paramvalue << ",".r, lazy { pvalue_list }) & /[;:]/.r).map do |e, list|
        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n"), list].flatten
      end | (paramvalue & /[;:]/.r).map do |e|
        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")]
      end
      quoted_string_list = (seq(C::QUOTEDSTRING_VCAL << ",".r, lazy { quoted_string_list }) & /[;:]/.r).map do |e, list|
        [self.class.rfc6868decode(e.sub(Regexp.new("^\"(.+)\"$"), "\1").gsub(/\\n/, "\n")), list].flatten
      end | (C::QUOTEDSTRING_VCAL & /[;:]/.r).map do |e|
        [self.class.rfc6868decode(e.sub(Regexp.new("^\"(.+)\"$"), "\1").gsub(/\\n/, "\n"))]
      end

      rfc4288regname = /[A-Za-z0-9!#$&.+^+-]{1,127}/.r
      rfc4288typename = rfc4288regname
      rfc4288subtypename = rfc4288regname
      fmttypevalue = seq(rfc4288typename, "/", rfc4288subtypename).map(&:join)

      # RFC 7986
      displayval = /BADGE/i.r | /GRAPHIC/i.r | /FULLSIZE/i.r | /THUMBNAIL/i.r | C::XNAME_VCAL | C::IANATOKEN
      displayvallist = seq(displayval << ",".r, lazy { displayvallist }) do |d, l|
        [d, l].flatten
      end | displayval.map { |d| [d] }
      featureval = /AUDIO/i.r | /CHAT/i.r | /FEED/i.r | /MODERATOR/i.r | /PHONE/i.r | /SCREEN/i.r |
        /VIDEO/i.r | C::XNAME_VCAL | C::IANATOKEN
      featurevallist = seq(featureval << ",".r, lazy { featurevallist }) do |d, l|
        [d, l].flatten
      end | featureval.map { |d| [d] }

      param = seq(/ALTREP/i.r, "=", quotedparamvalue) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/CN/i.r, "=", paramvalue) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/CUTYPE/i.r, "=", cutypevalue) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val.upcase }
      end | seq(/DELEGATED-FROM/i.r, "=", quoted_string_list) do |name, _, val|
        val = val[0] if val.length == 1
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/DELEGATED-TO/i.r, "=", quoted_string_list) do |name, _, val|
        val = val[0] if val.length == 1
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/DIR/i.r, "=", quotedparamvalue) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/ENCODING/i.r, "=", encodingvalue) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val.upcase }
      end | seq(/FMTTYPE/i.r, "=", fmttypevalue) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val.downcase }
      end | seq(/FBTYPE/i.r, "=", fbtypevalue) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val.upcase }
      end | seq(/LANGUAGE/i.r, "=", C::RFC5646LANGVALUE) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val.upcase }
      end | seq(/MEMBER/i.r, "=", quoted_string_list) do |name, _, val|
        val = val[0] if val.length == 1
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/PARTSTAT/i.r, "=", partstatvalue) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val.upcase }
      end | seq(/RANGE/i.r, "=", rangevalue) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val.upcase }
      end | seq(/RELATED/i.r, "=", relatedvalue) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val.upcase }
      end | seq(/RELTYPE/i.r, "=", reltypevalue) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val.upcase }
      end | seq(/ROLE/i.r, "=", rolevalue) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val.upcase }
      end | seq(/RSVP/i.r, "=", C::BOOLEAN) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/SENT-BY/i.r, "=", quotedparamvalue) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/TZID/i.r, "=", tzidvalue) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/VALUE/i.r, "=", valuetype) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val }
        # RFC 7986
      end | seq(/DISPLAY/i.r, "=", displayvallist) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/FEATURE/i.r, "=", featurevallist) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/EMAIL/i.r, "=", paramvalue) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/LABEL/i.r, "=", paramvalue) do |name, _, val|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(otherparamname, "=", pvalue_list) do |name, _, val|
        val = val[0] if val.length == 1
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(paramname, "=", pvalue_list) do |name, _, val|
        parse_err("Violated format of parameter value #{name} = #{val}")
      end

      params = seq(";".r >> param & ";", lazy { params }) do |p, ps|
        p.merge(ps) do |key, old, new|
          if @cardinality1[:PARAM].include?(key)
            parse_err("Violated cardinality of parameter #{key}")
          end
          [old, new].flatten
          # deal with duplicate properties
        end
      end | seq(";".r >> param).map { |e| e[0] }

      contentline = seq(linegroup._?, C::NAME_VCAL, params._? << ":".r,
                        C::VALUE, /(\r|\n|\r\n)/) do |g, name, p, value, _|
        key =  name.upcase.tr("-", "_").to_sym
        hash = { key => { value: value } }
        hash[key][:group] = g[0] unless g.empty?
        errors << Paramcheck.paramcheck(strict, key, p.empty? ? {} : p[0], @ctx)
        hash[key][:params] = p[0] unless p.empty?
        hash
      end

      props = ("".r & beginend).map { {} } |
        seq(contentline, lazy { props }) do |c, rest|
        k = c.keys[0]
        c[k][:value], errors1 = Typegrammars.typematch(strict, k, c[k][:params], :GENERIC, c[k][:value], @ctx)
        errors << errors1
        c.merge(rest) do |_, old, new|
          [old, new].flatten
          # deal with duplicate properties
        end
      end
      alarmprops = ("".r & beginend).map { {} } |
        seq(contentline, lazy { alarmprops }) do |c, rest|
        k = c.keys[0]
        c[k][:value], errors1 = Typegrammars.typematch(strict, k, c[k][:params], :ALARM, c[k][:value], @ctx)
        errors << errors1
        c.merge(rest) do |key, old, new|
          if @cardinality1[:ALARM].include?(key.upcase)
            parse_err("Violated cardinality of property #{key}")
          end
          [old, new].flatten
        end
      end
      fbprops = ("".r & beginend).map { {} } |
        seq(contentline, lazy { fbprops }) do |c, rest|
        k = c.keys[0]
        c[k][:value], errors1 = Typegrammars.typematch(strict, k, c[k][:params], :FREEBUSY, c[k][:value], @ctx)
        errors << errors1
        c.merge(rest) do |key, old, new|
          if @cardinality1[:FREEBUSY].include?(key.upcase)
            parse_err("Violated cardinality of property #{key}")
          end
          [old, new].flatten
        end
      end
      journalprops = ("".r & beginend).map { {} } |
        seq(contentline, lazy { journalprops }) do |c, rest|
        k = c.keys[0]
        c[k][:value], errors1 = Typegrammars.typematch(strict, k, c[k][:params], :JOURNAL, c[k][:value], @ctx)
        errors << errors1
        c.merge(rest) do |key, old, new|
          if @cardinality1[:JOURNAL].include?(key.upcase)
            parse_err("Violated cardinality of property #{key}")
          end
          [old, new].flatten
        end
      end
      tzprops = ("".r & beginend).map { {} } |
        seq(contentline, lazy { tzprops }) do |c, rest|
        k = c.keys[0]
        c[k][:value], errors1 = Typegrammars.typematch(strict, k, c[k][:params], :TZ, c[k][:value], @ctx)
        errors << errors1
        c.merge(rest) do |key, old, new|
          if @cardinality1[:TZ].include?(key.upcase)
            parse_err("Violated cardinality of property #{key}")
          end
          [old, new].flatten
        end
      end
      standardc = seq(/BEGIN:STANDARD(\r|\n|\r\n)/i.r, tzprops, /END:STANDARD(\r|\n|\r\n)/i.r) do |_, e, _|
        parse_err("Missing DTSTART property") unless e.has_key?(:DTSTART)
        parse_err("Missing TZOFFSETTO property") unless e.has_key?(:TZOFFSETTO)
        parse_err("Missing TZOFFSETFROM property") unless e.has_key?(:TZOFFSETFROM)
        { STANDARD: { component: [e] } }
      end
      daylightc = seq(/BEGIN:DAYLIGHT(\r|\n|\r\n)/i.r, tzprops, /END:DAYLIGHT(\r|\n|\r\n)/i.r) do |_, e, _|
        parse_err("Missing DTSTART property") unless e.has_key?(:DTSTART)
        parse_err("Missing TZOFFSETTO property") unless e.has_key?(:TZOFFSETTO)
        parse_err("Missing TZOFFSETFROM property") unless e.has_key?(:TZOFFSETFROM)
        { DAYLIGHT: { component: [e] } }
      end
      timezoneprops =
        seq(standardc, lazy { timezoneprops }) do |e, rest|
        e.merge(rest) { |_, old, new| { component: [old[:component], new[:component]].flatten } }
        end | seq(daylightc, lazy { timezoneprops }) do |e, rest|
          e.merge(rest) { |_, old, new| { component: [old[:component], new[:component]].flatten } }
        end | seq(contentline, lazy { timezoneprops }) do |e, rest|
          k = e.keys[0]
          e[k][:value], errors1 = Typegrammars.typematch(strict, k, e[k][:params], :TIMEZONE, e[k][:value], @ctx)
          errors << errors1
          e.merge(rest) do |key, old, new|
            if @cardinality1[:TIMEZONE].include?(key.upcase)
              parse_err("Violated cardinality of property #{key}")
            end
            [old, new].flatten
          end
        end |
        ("".r & beginend).map { {} }
        todoprops = ("".r & beginend).map { {} } |
          seq(contentline, lazy { todoprops }) do |c, rest|
          k = c.keys[0]
          c[k][:value], errors1 = Typegrammars.typematch(strict, k, c[k][:params], :TODO, c[k][:value], @ctx)
          errors << errors1
          c.merge(rest) do |key, old, new|
            if @cardinality1[:TODO].include?(key.upcase)
              parse_err("Violated cardinality of property #{key}")
            end
            [old, new].flatten
          end
        end
        eventprops = seq(contentline, lazy { eventprops }) do |c, rest|
          k = c.keys[0]
          c[k][:value], errors1 = Typegrammars.typematch(strict, k, c[k][:params], :EVENT, c[k][:value], @ctx)
          errors << errors1
          c.merge(rest) do |key, old, new|
            if @cardinality1[:EVENT].include?(key.upcase)
              parse_err("Violated cardinality of property #{key}")
            end
            [old, new].flatten
          end
        end |
        ("".r & beginend).map { {} }
        alarmc = seq(/BEGIN:VALARM(\r|\n|\r\n)/i.r, alarmprops, /END:VALARM(\r|\n|\r\n)/i.r) do |_, e, _|
          parse_err("Missing ACTION property") unless e.has_key?(:ACTION)
          parse_err("Missing TRIGGER property") unless e.has_key?(:TRIGGER)
          if e.has_key?(:DURATION) && !e.has_key?(:REPEAT) || !e.has_key?(:DURATION) && e.has_key?(:REPEAT)
            parse_err("Missing DURATION && REPEAT properties")
          end
          if e[:ACTION] == "AUDIO"
            parse_err("Multiple ATTACH properties") if e.has_key?(:ATTACH) && e[:ATTACH].is_a?(Array)
            parse_err("Invalid DESCRIPTION property") if e.has_key?(:DESCRIPTION)
            parse_err("Invalid SUMMARY property") if e.has_key?(:SUMMARY)
            parse_err("Invalid ATTENDEE property") if e.has_key?(:ATTENDEE)
          elsif e[:ACTION] == "DISP"
            parse_err("Missing DESCRIPTION property") unless e.has_key?(:DESCRIPTION)
            parse_err("Invalid ATTACH property") if e.has_key?(:ATTACH)
            parse_err("Invalid SUMMARY property") if e.has_key?(:SUMMARY)
            parse_err("Invalid ATTENDEE property") if e.has_key?(:ATTENDEE)
          elsif e[:ACTION] == "EMAIL"
            parse_err("Missing DESCRIPTION property") unless e.has_key?(:DESCRIPTION)
          end
          { VALARM: { component: [e] } }
        end
        freebusyc = seq(/BEGIN:VFREEBUSY(\r|\n|\r\n)/i.r, fbprops, /END:VFREEBUSY(\r|\n|\r\n)/i.r) do |_, e, _|
          parse_err("Missing DTSTAMP property") unless e.has_key?(:DTSTAMP)
          parse_err("Missing UID property") unless e.has_key?(:UID)
          parse_err("DTEND before DTSTART") if e.has_key?(:DTEND) && e.has_key?(:DTSTART) &&
            e[:DTEND][:value] < e[:DTSTART][:value]
          { VFREEBUSY: { component: [e] } }
        end
        journalc = seq(/BEGIN:VJOURNAL(\r|\n|\r\n)/i.r, journalprops, /END:VJOURNAL(\r|\n|\r\n)/i.r) do |_, e, _|
          parse_err("Missing DTSTAMP property") unless e.has_key?(:DTSTAMP)
          parse_err("Missing UID property") unless e.has_key?(:UID)
          parse_err("Missing DTSTART property with RRULE property") if e.has_key?(:RRULE) && !e.has_key?(:DTSTART)
          { VJOURNAL: { component: [e] } }
        end
        timezonec = seq(/BEGIN:VTIMEZONE(\r|\n|\r\n)/i.r, timezoneprops, /END:VTIMEZONE(\r|\n|\r\n)/i.r) do |_, e, _|
          parse_err("Missing STANDARD || DAYLIGHT property") unless e.has_key?(:STANDARD) || e.has_key?(:DAYLIGHT)
          { VTIMEZONE: { component: [e] } }
        end
        todoc = seq(/BEGIN:VTODO(\r|\n|\r\n)/i.r, todoprops, alarmc.star, /END:VTODO(\r|\n|\r\n)/i.r) do |_, e, a, _|
          parse_err("Missing DTSTAMP property") unless e.has_key?(:DTSTAMP)
          parse_err("Missing UID property") unless e.has_key?(:UID)
          parse_err("Coocurring DUE && DURATION properties") if e.has_key?(:DUE) && e.has_key?(:DURATION)
          parse_err("Missing DTSTART property with DURATION property") if e.has_key?(:DURATION) && !e.has_key?(:DTSTART)
          parse_err("Missing DTSTART property with RRULE property") if e.has_key?(:RRULE) && !e.has_key?(:DTSTART)
          parse_err("DUE before DTSTART") if e.has_key?(:DUE) &&
            e.has_key?(:DTSTART) &&
            e[:DUE][:value] < e[:DTSTART][:value]
          # TODO not doing constraint that due && dtstart are both || neither local time
          # TODO not doing constraint that recurrence-id && dtstart are both || neither local time
          # TODO not doing constraint that recurrence-id && dtstart are both || neither date
          a.each do |x|
            e = e.merge(x) { |_, old, new| { component: [old[:component], new[:component]].flatten } }
          end
          { VTODO: { component: [e] } }
        end
        eventc = seq(/BEGIN:VEVENT(\r|\n|\r\n)/i.r, eventprops, alarmc.star, /END:VEVENT(\r|\n|\r\n)/i.r) do |_, e, a, _|
          parse_err("Missing DTSTAMP property") unless e.has_key?(:DTSTAMP)
          parse_err("Missing UID property") unless e.has_key?(:UID)
          parse_err("Coocurring DTEND && DURATION properties") if e.has_key?(:DTEND) && e.has_key?(:DURATION)
          parse_err("Missing DTSTART property with RRULE property") if e.has_key?(:RRULE) && !e.has_key?(:DTSTART)
          parse_err("DTEND before DTSTART") if e.has_key?(:DTEND) &&
            e.has_key?(:DTSTART) &&
            e[:DTEND][:value] < e[:DTSTART][:value]
          # TODO not doing constraint that dtend && dtstart are both || neither local time
          a.each do |x|
            e = e.merge(x) { |_, old, new| { component: [old[:component], new[:component]].flatten } }
          end
          { VEVENT: { component: [e] } }
        end
        xcomp	= seq(/BEGIN:/i.r, C::XNAME_VCAL, /(\r|\n|\r\n)/i.r, props, /END:/i.r, C::XNAME_VCAL, /(\r|\n|\r\n)/i.r) do |_, n, _, p, _, n1, _|
          n = n.upcase
          n1 = n1.upcase
          parse_err("Mismatch BEGIN:#{n}, END:#{n1}") if n != n1
          { n1.to_sym => { component: [p] } }
        end
        ianacomp = seq(/BEGIN:/i.r ^ C::ICALPROPNAMES, C::IANATOKEN, /(\r|\n|\r\n)/i.r, props, /END:/i.r ^ C::ICALPROPNAMES, C::IANATOKEN, /(\r|\n|\r\n)/i.r) do |_, n, _, p, _, n1, _|
          n = n.upcase
          n1 = n1.upcase
          parse_err("Mismatch BEGIN:#{n}, END:#{n1}") if n != n1
          { n1.to_sym => { component: [p] } }
        end
        # RFC 7953
        availableprops = seq(contentline, lazy { availableprops }) do |c, rest|
          k = c.keys[0]
          c[k][:value], errors1 = Typegrammars.typematch(strict, k, c[k][:params], :AVAILABLE, c[k][:value], @ctx)
          errors << errors1
          c.merge(rest) do |key, old, new|
            if @cardinality1[:AVAILABLE].include?(key.upcase)
              parse_err("Violated cardinality of property #{key}")
            end
            [old, new].flatten
          end
        end | ("".r & beginend).map { {} }
        availablec = seq(/BEGIN:AVAILABLE(\r|\n|\r\n)/i.r, availableprops, /END:AVAILABLE(\r|\n|\r\n)/i.r) do |_, e, _|
          # parse_err("Missing DTSTAMP property") unless e.has_key?(:DTSTAMP) # required in spec, but not in examples
          parse_err("Missing DTSTART property") unless e.has_key?(:DTSTART)
          parse_err("Missing UID property") unless e.has_key?(:UID)
          parse_err("Coocurring DTEND && DURATION properties") if e.has_key?(:DTEND) && e.has_key?(:DURATION)
          { AVAILABLE: { component: [e] } }
        end
        availabilityprops = seq(contentline, lazy { availabilityprops }) do |c, rest|
          k = c.keys[0]
          c[k][:value], errors1 = Typegrammars.typematch(strict, k, c[k][:params], :VAVAILABILITY, c[k][:value], @ctx)
          errors << errors1
          c.merge(rest) do |key, old, new|
            if @cardinality1[:VAVAILABILITY].include?(key.upcase)
              parse_err("Violated cardinality of property #{key}")
            end
            [old, new].flatten
          end
        end | ("".r & beginend).map { {} }
        vavailabilityc = seq(/BEGIN:VAVAILABILITY(\r|\n|\r\n)/i.r, availabilityprops, availablec.star, /END:VAVAILABILITY(\r|\n|\r\n)/i.r) do |_, e, a, _|
          parse_err("Missing DTSTAMP property") unless e.has_key?(:DTSTAMP)
          parse_err("Missing UID property") unless e.has_key?(:UID)
          parse_err("Coocurring DTEND && DURATION properties") if e.has_key?(:DTEND) && e.has_key?(:DURATION)
          parse_err("Missing DTSTART property with DURATION property") if e.has_key?(:DURATION) && !e.has_key?(:DTSTART)
          parse_err("DTEND before DTSTART") if e.has_key?(:DTEND) && e.has_key?(:DTSTART) && e[:DTEND][:value] < e[:DTSTART][:value]
          # TODO not doing constraint that dtend && dtstart are both || neither local time
          # TODO not doing constraint that each TZID param must have matching VTIMEZONE component
          a.each do |x|
            e = e.merge(x) { |_key, old, new| { component: [old[:component], new[:component]].flatten } }
          end
          { VAVAILABILITY: { component: [e] } }
        end

        component = eventc | todoc | journalc | freebusyc | timezonec | ianacomp | xcomp | vavailabilityc
        components = seq(component, lazy { components }) do |c, r|
          c.merge(r) do |_key, old, new|
            { component: [old[:component], new[:component]].flatten }
          end
        end | component

        calpropname = /CALSCALE/i.r | /METHOD/i.r | /PRODID/i.r | /VERSION/i.r |
          /UID/i.r | /LAST-MOD/i.r | /URL/i.r | /REFRESH/i.r | /SOURCE/i.r | /COLOR/i.r | # RFC 7986
          /NAME/i.r | /DESCRIPTION/i.r | /CATEGORIES/i.r | /IMAGE/i.r | # RFC 7986
          C::XNAME_VCAL | C::IANATOKEN
        calprop = seq(calpropname, params._? << ":".r, C::VALUE, /(\r|\n|\r\n)/) do |key, p, value, _|
          key = key.upcase.tr("-", "_").to_sym
          val, errors1 = Typegrammars.typematch(strict, key, p[0], :CALENDAR, value, @ctx)
          errors << errors1
          hash = { key => { value: val } }
          errors << Paramcheck.paramcheck(strict, key, p.empty? ? {} : p[0], @ctx)
          hash[key][:params] = p[0] unless p.empty?
          hash
          # TODO not doing constraint that each description must be in a different language
        end
        calprops = ("".r & beginend).map { {} } |
          seq(calprop, lazy { calprops }) do |c, rest|
          c.merge(rest) do |key, old, new|
            if @cardinality1[:ICAL].include?(key.upcase)
              parse_err("Violated cardinality of property #{key}")
            end
            [old, new].flatten
          end
        end
        vobject = seq(/BEGIN:VCALENDAR(\r|\n|\r\n)/i.r, calprops, components, /END:VCALENDAR(\r|\n|\r\n)/i.r) do |_b, v, rest, _e|
          parse_err("Missing PRODID attribute") unless v.has_key?(:PRODID)
          parse_err("Missing VERSION attribute") unless v.has_key?(:VERSION)
          rest.delete(:END)
          if !v.has_key?(:METHOD) && rest.has_key?(:VEVENT)
            rest[:VEVENT][:component].each do |e1|
              parse_err("Missing DTSTART property from VEVENT component") if !e1.has_key?(:DTSTART)
            end
          end
          tidyup(VCALENDAR: v.merge(rest), errors: errors.flatten)
        end
        vobject.eof
    end

    # any residual tidying of object
    def tidyup(v)
      # adjust any VTIMEZONE.{STANDARD|DAYLIGHT}.{DTSTART|RDATE} times from floating local to the time within the timezone component
      if !v[:VCALENDAR].has_key?(:VTIMEZONE) || v[:VCALENDAR][:VTIMEZONE][:component].nil? || v[:VCALENDAR][:VTIMEZONE][:component].empty?
        return v
      elsif v[:VCALENDAR][:VTIMEZONE][:component].is_a?(Array)
        v[:VCALENDAR][:VTIMEZONE][:component].map do |x|
          timezoneadjust x
        end
      else
        v[:VCALENDAR][:VTIMEZONE][:component] = timezoneadjust v[:VCALENDAR][:VTIMEZONE][:component]
      end
      v
    end

    def timezoneadjust(x)
      if x[:TZID].nil? || x[:TZID].empty?
        return x
      end
      # TODO deal with unregistered timezones
      begin
        tz = TZInfo::Timezone.get(x[:TZID][:value].value)
      rescue
        return x
      end
      [:STANDARD, :DAYLIGHT].each do |k|
        next unless x.has_key?(k)
        if x[k][:component].is_a?(Array)
          x[k][:component].each do |y|
            # subtracting a minute to avoid PeriodNotFound exceptions on the boundary between daylight saving && standard time
            # if that doesn't work either, we'll rescue to floating localtime
            # TODO lookup offsets applicable by parsing dates && offsets in the ical. I'd rather not.
            y[:DTSTART][:value].value = { time: tz.local_to_utc(y[:DTSTART][:value].value[:time] - 60, true) + 60, zone: x[:TZID][:value].value } rescue y[:DTSTART][:value].value
            next unless y.has_key?(:RDATE)
            if y[:RDATE].is_a?(Array)
              y[:RDATE].each do |z|
                z[:value].value.each do |w|
                  w.value = { time: tz.local_to_utc(w.value[:time] - 60, true) + 60, zone: x[:TZID][:value].value } rescue w.value
                end
              end
            else
              y[:RDATE][:value].value = { time: tz.local_to_utc(y[:RDATE].value[:time] - 60, true) + 60, zone: x[:TZID][:value].value } rescue y[:RDATE][:value].value
            end
          end
        else
          x[k][:component][:DTSTART][:value].value = { time: tz.local_to_utc(x[k][:component][:DTSTART][:value].value[:time] - 60, true) + 60, zone: x[:TZID][:value].value } rescue x[k][:component][:DTSTART][:value].value
          next unless x[k][:component].has_key?(:RDATE)
          if x[k][:component][:RDATE].is_a?(Array)
            x[k][:component][:RDATE].each do |z|
              z[:value].value.each do |w|
                w.value = { time: tz.local_to_utc(w.value[:time] - 60, true) + 60, zone: x[:TZID][:value].value } rescue w.value
              end
            end
          else
            x[k][:component][:RDATE][:value].value = { time: tz.local_to_utc(x[k][:component][:RDATE][:value].value[:time] - 60, true) + 60, zone: x[:TZID][:value].value } rescue x[k][:component][:RDATE][:value].value
          end
        end
      end
      x
    end

    def initialize(strict)
      self.strict = strict
      self.errors = []
    end

    def parse(vobject)
      @ctx = Rsec::ParseContext.new self.class.unfold(vobject), "source"
      ret = vobject_grammar._parse @ctx
      if !ret || Rsec::INVALID[ret]
        parse_err(@ctx.generate_error("source"))
        ret = { VCALENDAR: nil, errors: errors.flatten }
      end
      Rsec::Fail.reset
      ret
    end

    private

    def parse_err(msg)
      if strict
        raise @ctx.report_error msg, "source"
      else
        errors << @ctx.report_error(msg, "source")
      end
    end
  end
end
