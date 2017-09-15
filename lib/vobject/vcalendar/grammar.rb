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


	 class << self
  def vobjectGrammar
    attr_accessor :ctx

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

    group 	= C::IANATOKEN
    linegroup 	= group <<  '.' 
    beginend 	= /BEGIN/i.r | /END/i.r


# parameters and parameter types
    paramname 	= /ALTREP/i.r | /CN/i.r | /CUTYPE/i.r | /DELEGATED-FROM/i.r | /DELEGATED-TO/i.r |
	    		/DIR/i.r | /ENCODING/i.r | /FMTTYPE/i.r | /FBTYPE/i.r | /LANGUAGE/i.r |
			/MEMBER/i.r | /PARTSTAT/i.r | /RANGE/i.r | /RELATED/i.r | /RELTYPE/i.r |
			/ROLE/i.r | /RSVP/i.r | /SENT-BY/i.r | /TZID/i.r | /RSCALE/i.r | /DISPLAY/i.r |
			/FEATURE/i.r | /LABEL/i.r | /EMAIL/i.r
    otherparamname = C::XNAME | seq(''.r ^ paramname, C::IANATOKEN )[1]
    paramvalue 	= C::QUOTEDSTRING.map {|s| rfc6868decode s } | C::PTEXT.map {|s| (rfc6868decode(s)) }
    quotedparamvalue 	= C::QUOTEDSTRING.map {|s| rfc6868decode s } 
    cutypevalue	= /INDIVIDUAL/i.r | /GROUP/i.r | /RESOURCE/i.r | /ROOM/i.r | /UNKNOWN/i.r |
	    		C::XNAME | C::IANATOKEN.map 
    encodingvalue = /8BIT/i.r | /BASE64/i.r
    fbtypevalue	= /FREE/i.r | /BUSY/i.r | /BUSY-UNAVAILABLE/i.r | /BUSY-TENTATIVE/i.r | 
	    		C::XNAME | C::IANATOKEN
    partstatevent = /NEEDS-ACTION/i.r | /ACCEPTED/i.r | /DECLINED/i.r | /TENTATIVE/i.r |
	    		/DELEGATED/i.r | C::XNAME | C::IANATOKEN
    partstattodo = /NEEDS-ACTION/i.r | /ACCEPTED/i.r | /DECLINED/i.r | /TENTATIVE/i.r |
	    		/DELEGATED/i.r | /COMPLETED/i.r | /IN-PROCESS/i.r | C::XNAME | C::IANATOKEN
    partstatjour = /NEEDS-ACTION/i.r | /ACCEPTED/i.r | /DECLINED/i.r | C::XNAME | C::IANATOKEN
    partstatvalue = partstatevent | partstattodo | partstatjour
    rangevalue 	= /THISANDFUTURE/i.r
    relatedvalue = /START/i.r | /END/i.r
    reltypevalue = /PARENT/i.r | /CHILD/i.r | /SIBLING/i.r | C::XNAME | C::IANATOKEN
    tzidvalue 	= seq("/".r._?, C::PTEXT).map {|_, val| val}
    valuetype 	= /BINARY/i.r | /BOOLEAN/i.r | /CAL-ADDRESS/i.r | /DATE-TIME/i.r | /DATE/i.r |
	    	/DURATION/i.r | /FLOAT/i.r | /INTEGER/i.r | /PERIOD/i.r | /RECUR/i.r | /TEXT/i.r |
		/TIME/i.r | /URI/i.r | /UTC-OFFSET/i.r | C::XNAME | C::IANATOKEN
    rolevalue 	= /CHAIR/i.r | /REQ-PARTICIPANT/i.r | /OPT-PARTICIPANT/i.r | /NON-PARTICIPANT/i.r | 
	    		C::XNAME | C::IANATOKEN
    pvalueList 	= (seq(paramvalue, ','.r, lazy{pvalueList}) & /[;:]/.r).map {|e, _, list|
			[e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n") , list].flatten
		} | (paramvalue & /[;:]/.r).map {|e|
                        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")]
               }
    quotedStringList = (seq(C::QUOTEDSTRING, ','.r, lazy{quotedStringList}) & /[;:]/.r).map {|e, _, list|
                         [rfc6868decode(e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")), list].flatten
		} | (C::QUOTEDSTRING & /[;:]/.r).map {|e|
                        [rfc6868decode(e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n"))]
                }

    rfc4288regname 	= /[A-Za-z0-9!#$&.+^+-]{1,127}/.r
    rfc4288typename 	= rfc4288regname
    rfc4288subtypename 	= rfc4288regname
    fmttypevalue 	= seq(rfc4288typename, "/", rfc4288subtypename).map(&:join)

    # RFC 7986
    displayval		= /BADGE/i.r | /GRAPHIC/i.r | /FULLSIZE/i.r | /THUMBNAIL/i.r | C::XNAME | C::IANATOKEN
    displayvallist	= seq(displayval, ',', lazy{displayvallist}) {|d,_,l|
	    			[d, l].flatten
			} | displayval.map {|d| [d] }
    featureval		= /AUDIO/i.r | /CHAT/i.r | /FEED/i.r | /MODERATOR/i.r | /PHONE/i.r | /SCREEN/i.r |
	    			/VIDEO/i.r | C::XNAME | C::IANATOKEN
    featurevallist	= seq(featureval, ',', lazy{featurevallist}) {|d,_,l|
	    			[d, l].flatten
			} | featureval.map {|d| [d] }
    			
    param 	= seq(/ALTREP/i.r, '=', quotedparamvalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
    		} | seq(/CN/i.r, '=', paramvalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
    		} | seq(/CUTYPE/i.r, '=', cutypevalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val.upcase}
    		} | seq(/DELEGATED-FROM/i.r, '=', quotedStringList) {|name, _, val|
	    		val = val[0] if val.length == 1
			{name.upcase.gsub(/-/,"_").to_sym => val}
    		} | seq(/DELEGATED-TO/i.r, '=', quotedStringList) {|name, _, val|
	    		val = val[0] if val.length == 1
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | seq(/DIR/i.r, '=', quotedparamvalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
    		} | seq(/ENCODING/i.r, '=', encodingvalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val.upcase}
    		} | seq(/FMTTYPE/i.r, '=', fmttypevalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val.downcase}
    		} | seq(/FBTYPE/i.r, '=', fbtypevalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val.upcase}
    		} | seq(/LANGUAGE/i.r, '=', C::RFC5646LANGVALUE) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val.upcase}
    		} | seq(/MEMBER/i.r, '=', quotedStringList) {|name, _, val|
	    		val = val[0] if val.length == 1
			{name.upcase.gsub(/-/,"_").to_sym => val}
    		} | seq(/PARTSTAT/i.r, '=', partstatvalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val.upcase}
    		} | seq(/RANGE/i.r, '=', rangevalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val.upcase}
    		} | seq(/RELATED/i.r, '=', relatedvalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val.upcase}
    		} | seq(/RELTYPE/i.r, '=', reltypevalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val.upcase}
    		} | seq(/ROLE/i.r, '=', rolevalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val.upcase}
    		} | seq(/RSVP/i.r, '=', C::BOOLEAN) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | seq(/SENT-BY/i.r, '=', quotedparamvalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | seq(/TZID/i.r, '=', tzidvalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | seq(/VALUE/i.r, '=', valuetype) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
		# RFC 7986
		} | seq(/DISPLAY/i.r, '=', displayvallist) {|name, _, val| 
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | seq(/FEATURE/i.r, '=', featurevallist) {|name, _, val| 
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | seq(/EMAIL/i.r, '=', paramvalue) {|name, _, val| 
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | seq(/LABEL/i.r, '=', paramvalue) {|name, _, val| 
			{name.upcase.gsub(/-/,"_").to_sym => val}
    		} | seq(otherparamname, '=', pvalueList) {|name, _, val|
	    		val = val[0] if val.length == 1
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | seq(paramname, '=', pvalueList) {|name, _, val|
			parse_err("Violated format of parameter value #{name} = #{val}")
		}

    params	= 
		seq(';'.r >> param & ';', lazy{params} ) {|p, ps|
			p.merge(ps) {|key, old, new|
				if @cardinality1[:PARAM].include?(key)
						parse_err("Violated cardinality of parameter #{key}")
				end
				[old,  new].flatten
				# deal with duplicate properties
			}
		} |
	    	seq(';'.r >> param ).map {|e| e[0] } 

    contentline = seq(linegroup._?, C::NAME, params._?, ':', 
		      C::VALUE, /(\r|\n|\r\n)/) {|group, name, params, _, value, _|
			key =  name.upcase.gsub(/-/,"_").to_sym
			hash = { key => {:value => value} }
			hash[key][:group] = group[0]  unless group.empty?
			Vobject::Vcalendar::Paramcheck.paramcheck(key, params.empty? ? {} : params[0], @ctx)
			hash[key][:params] = params[0] unless params.empty?
			hash
		}

        props	= (''.r & beginend).map {|e| {}   } | 
		seq(contentline, lazy{props}) {|c, rest|
			k = c.keys[0]
			c[k][:value] = Vobject::Vcalendar::Typegrammars.typematch(k, c[k][:params], :GENERIC, c[k][:value], @ctx)
			c.merge( rest ) { | key, old, new|
				[old,  new].flatten
				# deal with duplicate properties
			}
			}
        alarmprops	= (''.r & beginend).map {|e| {}   } | 
		seq(contentline, lazy{alarmprops}) {|c, rest|
			k = c.keys[0]
			c[k][:value] = Vobject::Vcalendar::Typegrammars.typematch(k, c[k][:params], :ALARM, c[k][:value], @ctx)
			c.merge( rest ) { | key, old, new|
				if @cardinality1[:ALARM].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
			}
			}
        fbprops		= (''.r & beginend).map {|e| {}   } | 
		seq(contentline, lazy{fbprops}) {|c, rest|
			k = c.keys[0]
			c[k][:value] = Vobject::Vcalendar::Typegrammars.typematch(k, c[k][:params], :FREEBUSY, c[k][:value], @ctx)
			c.merge( rest ) { | key, old, new|
				if @cardinality1[:FREEBUSY].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
			}
			}
        journalprops	= (''.r & beginend).map {|e| {}   } | 
		seq(contentline, lazy{journalprops}) {|c, rest|
			k = c.keys[0]
			c[k][:value] = Vobject::Vcalendar::Typegrammars.typematch(k, c[k][:params], :JOURNAL, c[k][:value], @ctx)
			c.merge( rest ) { | key, old, new|
				if @cardinality1[:JOURNAL].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
			}
			}
        tzprops		= (''.r & beginend).map {|e| {}   } | 
		seq(contentline, lazy{tzprops}) {|c, rest|
			k = c.keys[0]
			c[k][:value] = Vobject::Vcalendar::Typegrammars.typematch(k, c[k][:params], :TZ, c[k][:value], @ctx)
			c.merge( rest ) { | key, old, new|
				if @cardinality1[:TZ].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
			}
			}
	standardc	= seq(/BEGIN:STANDARD(\r|\n|\r\n)/i.r, tzprops, /END:STANDARD(\r|\n|\r\n)/i.r) {|_, e, _|
				parse_err("Missing DTSTART property") unless e.has_key?(:DTSTART)
				parse_err("Missing TZOFFSETTO property") unless e.has_key?(:TZOFFSETTO)
				parse_err("Missing TZOFFSETFROM property") unless e.has_key?(:TZOFFSETFROM)
				{ :STANDARD => {:component => [e] }}
			}
	daylightc	= seq(/BEGIN:DAYLIGHT(\r|\n|\r\n)/i.r, tzprops, /END:DAYLIGHT(\r|\n|\r\n)/i.r) {|_, e, _|
				parse_err("Missing DTSTART property") unless e.has_key?(:DTSTART)
				parse_err("Missing TZOFFSETTO property") unless e.has_key?(:TZOFFSETTO)
				parse_err("Missing TZOFFSETFROM property") unless e.has_key?(:TZOFFSETFROM)
				{ :DAYLIGHT => {:component => [e] }}
			}
	timezoneprops	= 
			seq(standardc, lazy{timezoneprops}) {|e, rest|
				e.merge(rest) {|key, old, new| {:component => [old[:component], new[:component]].flatten} }
	                } | seq(daylightc, lazy{timezoneprops}) {|e, rest|
				e.merge(rest) {|key, old, new| {:component => [old[:component], new[:component]].flatten} }
			} | seq(contentline, lazy{timezoneprops}) {|e, rest|
			k = e.keys[0]
			e[k][:value] = Vobject::Vcalendar::Typegrammars.typematch(k, e[k][:params], :TIMEZONE, e[k][:value], @ctx)
			e.merge( rest ) { | key, old, new|
				if @cardinality1[:TIMEZONE].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
				}
			} |
			(''.r & beginend).map {|e| {} } 
        todoprops	= (''.r & beginend).map {|e| {}   } | 
			seq(contentline, lazy{todoprops}) {|c, rest|
			k = c.keys[0]
			c[k][:value] = Vobject::Vcalendar::Typegrammars.typematch(k, c[k][:params], :TODO, c[k][:value], @ctx)
				c.merge( rest ) { | key, old, new|
				if @cardinality1[:TODO].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
				}
			}
        eventprops	= seq(contentline, lazy{eventprops}) {|c, rest|
			k = c.keys[0]
			c[k][:value] = Vobject::Vcalendar::Typegrammars.typematch(k, c[k][:params], :EVENT, c[k][:value], @ctx)
				c.merge( rest ) { | key, old, new|
				if @cardinality1[:EVENT].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
				}
			} |
			(''.r & beginend).map {|e| {}   } 
	alarmc		= seq(/BEGIN:VALARM(\r|\n|\r\n)/i.r, alarmprops, /END:VALARM(\r|\n|\r\n)/i.r) {|_, e, _|
				parse_err("Missing ACTION property") unless e.has_key?(:ACTION)
				parse_err("Missing TRIGGER property") unless e.has_key?(:TRIGGER)
				if e.has_key?(:DURATION) and !e.has_key?(:REPEAT) or !e.has_key?(:DURATION) and e.has_key?(:REPEAT)
				 	parse_err("Missing DURATION and REPEAT properties") 
				end
				if e[:ACTION] == 'AUDIO'
					parse_err("Multiple ATTACH properties") if e.has_key?(:ATTACH) and e[:ATTACH].kind_of?(Array)
					parse_err("Invalid DESCRIPTION property") if e.has_key?(:DESCRIPTION) 
					parse_err("Invalid SUMMARY property") if e.has_key?(:SUMMARY) 
					parse_err("Invalid ATTENDEE property") if e.has_key?(:ATTENDEE) 
				elsif e[:ACTION] == 'DISP'
					parse_err("Missing DESCRIPTION property") unless e.has_key?(:DESCRIPTION)
					parse_err("Invalid ATTACH property") if e.has_key?(:ATTACH) 
					parse_err("Invalid SUMMARY property") if e.has_key?(:SUMMARY) 
					parse_err("Invalid ATTENDEE property") if e.has_key?(:ATTENDEE) 
				elsif e[:ACTION] == 'EMAIL'
					parse_err("Missing DESCRIPTION property") unless e.has_key?(:DESCRIPTION)
				end
				{ :VALARM => {:component => [e] }}
			}
	freebusyc	= seq(/BEGIN:VFREEBUSY(\r|\n|\r\n)/i.r, fbprops, /END:VFREEBUSY(\r|\n|\r\n)/i.r) {|_, e, _|
				parse_err("Missing DTSTAMP property") unless e.has_key?(:DTSTAMP)
				parse_err("Missing UID property") unless e.has_key?(:UID)
				parse_err("DTEND before DTSTART") if e.has_key?(:DTEND) and e.has_key?(:DTSTART) and 
					e[:DTEND][:value] < e[:DTSTART][:value]
				{ :VFREEBUSY => {:component => [e] }}
			}
	journalc	= seq(/BEGIN:VJOURNAL(\r|\n|\r\n)/i.r, journalprops, /END:VJOURNAL(\r|\n|\r\n)/i.r) {|_, e, _|
				parse_err("Missing DTSTAMP property") unless e.has_key?(:DTSTAMP)
				parse_err("Missing UID property") unless e.has_key?(:UID)
				parse_err("Missing DTSTART property with RRULE property") if e.has_key?(:RRULE) and !e.has_key?(:DTSTART)
				{ :VJOURNAL => {:component => [e] }}
			}
	timezonec	= seq(/BEGIN:VTIMEZONE(\r|\n|\r\n)/i.r, timezoneprops, /END:VTIMEZONE(\r|\n|\r\n)/i.r) {|_, e, _|
				parse_err("Missing STANDARD or DAYLIGHT property") unless e.has_key?(:STANDARD) or e.has_key?(:DAYLIGHT)
				{ :VTIMEZONE => {:component => [e] }}
			}
	todoc		= seq(/BEGIN:VTODO(\r|\n|\r\n)/i.r, todoprops, alarmc.star, /END:VTODO(\r|\n|\r\n)/i.r) {|_, e, a, _|
				parse_err("Missing DTSTAMP property") unless e.has_key?(:DTSTAMP)
				parse_err("Missing UID property") unless e.has_key?(:UID)
				parse_err("Coocurring DUE and DURATION properties") if e.has_key?(:DUE) and e.has_key?(:DURATION)
				parse_err("Missing DTSTART property with DURATION property") if e.has_key?(:DURATION) and !e.has_key?(:DTSTART)
				parse_err("Missing DTSTART property with RRULE property") if e.has_key?(:RRULE) and !e.has_key?(:DTSTART)
				parse_err("DUE before DTSTART") if e.has_key?(:DUE) and e.has_key?(:DTSTART) and 
					e[:DUE][:value] < e[:DTSTART][:value]
				# TODO not doing constraint that due and dtstart are both or neither local time
				# TODO not doing constraint that recurrence-id and dtstart are both or neither local time
				# TODO not doing constraint that recurrence-id and dtstart are both or neither date
				a.each do |x|
					e = e.merge(x) {|key, old, new| {:component => [old[:component], new[:component]].flatten} }
				end
				{ :VTODO => {:component => [e] }}
			}
	eventc		= seq(/BEGIN:VEVENT(\r|\n|\r\n)/i.r, eventprops, alarmc.star, /END:VEVENT(\r|\n|\r\n)/i.r) {|_, e, a, _|
				parse_err("Missing DTSTAMP property") unless e.has_key?(:DTSTAMP)
				parse_err("Missing UID property") unless e.has_key?(:UID)
				parse_err("Coocurring DTEND and DURATION properties") if e.has_key?(:DTEND) and e.has_key?(:DURATION)
				parse_err("Missing DTSTART property with RRULE property") if e.has_key?(:RRULE) and !e.has_key?(:DTSTART)
				parse_err("DTEND before DTSTART") if e.has_key?(:DTEND) and e.has_key?(:DTSTART) and 
					e[:DTEND][:value] < e[:DTSTART][:value]
				# TODO not doing constraint that dtend and dtstart are both or neither local time
				a.each do |x|
					e = e.merge(x) {|key, old, new| {:component => [old[:component], new[:component]].flatten} }
				end
				{ :VEVENT => {:component => [e] }}
			}
	xcomp		= seq(/BEGIN:/i.r, C::XNAME, /(\r|\n|\r\n)/i.r, props, /END:/i.r, C::XNAME, /(\r|\n|\r\n)/i.r) {|_, n, _, p, _, n1, _|
				n = n.upcase
				n1 = n1.upcase
				parse_err("Mismatch BEGIN:#{n}, END:#{n1}") if n != n1
				{ n1.to_sym => {:component => [p]} }
			}
	ianacomp	= seq(/BEGIN:/i.r ^ C::ICALPROPNAMES, C::IANATOKEN, /(\r|\n|\r\n)/i.r, props, /END:/i.r ^ C::ICALPROPNAMES, C::IANATOKEN, /(\r|\n|\r\n)/i.r) {|_, n, _, p, _, n1, _|
				n = n.upcase
				n1 = n1.upcase
				parse_err("Mismatch BEGIN:#{n}, END:#{n1}") if n != n1
				{ n1.to_sym => {:component => [p]} }
			}
	# RFC 7953
        availableprops	= seq(contentline, lazy{availableprops}) {|c, rest|
			k = c.keys[0]
			c[k][:value] = Vobject::Vcalendar::Typegrammars.typematch(k, c[k][:params], :AVAILABLE, c[k][:value], @ctx)
				c.merge( rest ) { | key, old, new|
				if @cardinality1[:AVAILABLE].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
				}
			} |
			(''.r & beginend).map {|e| {}   } 
	availablec		= seq(/BEGIN:AVAILABLE(\r|\n|\r\n)/i.r, availableprops, /END:AVAILABLE(\r|\n|\r\n)/i.r) {|_, e, _|
				#parse_err("Missing DTSTAMP property") unless e.has_key?(:DTSTAMP) # required in spec, but not in examples
				parse_err("Missing DTSTART property") unless e.has_key?(:DTSTART)
				parse_err("Missing UID property") unless e.has_key?(:UID)
				parse_err("Coocurring DTEND and DURATION properties") if e.has_key?(:DTEND) and e.has_key?(:DURATION)
				{ :AVAILABLE => {:component => [e]} }
			}
        availabilityprops	= seq(contentline, lazy{availabilityprops}) {|c, rest|
			k = c.keys[0]
			c[k][:value] = Vobject::Vcalendar::Typegrammars.typematch(k, c[k][:params], :VAVAILABILITY, c[k][:value], @ctx)
				c.merge( rest ) { | key, old, new|
				if @cardinality1[:VAVAILABILITY].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
				}
			} |
			(''.r & beginend).map {|e| {}   } 
	vavailabilityc		= seq(/BEGIN:VAVAILABILITY(\r|\n|\r\n)/i.r, availabilityprops, availablec.star, /END:VAVAILABILITY(\r|\n|\r\n)/i.r) {|_, e, a, _|
				parse_err("Missing DTSTAMP property") unless e.has_key?(:DTSTAMP)
				parse_err("Missing UID property") unless e.has_key?(:UID)
				parse_err("Coocurring DTEND and DURATION properties") if e.has_key?(:DTEND) and e.has_key?(:DURATION)
				parse_err("Missing DTSTART property with DURATION property") if e.has_key?(:DURATION) and !e.has_key?(:DTSTART)
				parse_err("DTEND before DTSTART") if e.has_key?(:DTEND) and e.has_key?(:DTSTART) and 
					e[:DTEND][:value] < e[:DTSTART][:value]
				# TODO not doing constraint that dtend and dtstart are both or neither local time
				# TODO not doing constraint that each TZID param must have matching VTIMEZONE component
				a.each do |x|
					e = e.merge(x) {|key, old, new| {:component => [old[:component], new[:component]].flatten} }
				end
				{ :VAVAILABILITY => {:component => [e]} }
			}

	component	= eventc | todoc | journalc | freebusyc | timezonec | ianacomp | xcomp | vavailabilityc
	components 	= seq(component, lazy{components}) {|c, r|
				c.merge(r) {|key, old, new| {:component => [old[:component], new[:component]].flatten} }
			} | component

	calpropname = /CALSCALE/i.r | /METHOD/i.r | /PRODID/i.r | /VERSION/i.r |
			/UID/i.r | /LAST-MOD/i.r | /URL/i.r | /REFRESH/i.r | /SOURCE/i.r | /COLOR/i.r | # RFC 7986
			/NAME/i.r | /DESCRIPTION/i.r | /CATEGORIES/i.r | /IMAGE/i.r | # RFC 7986
	                C::XNAME | C::IANATOKEN
	calprop     = seq(calpropname, params._?, ':', C::VALUE, /(\r|\n|\r\n)/) {|key, params, _, value, _|
	    		key = key.upcase.gsub(/-/,"_").to_sym
	    		hash = { key => {:value => Vobject::Vcalendar::Typegrammars.typematch(key, params[0], :CALENDAR, value, @ctx) }}
			Vobject::Vcalendar::Paramcheck.paramcheck(key, params.empty? ? {} : params[0], @ctx)
			hash[key][:params] = params[0] unless params.empty?
			hash
			# TODO not doing constraint that each description must be in a different language
	}
	calprops    = (''.r & beginend).map { {} } | 
		seq(calprop, lazy{calprops} ) {|c, rest|
	        c.merge( rest) {|key, old, new|
		if @cardinality1[:ICAL].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
		end
	            [old, new].flatten
	        }
	}
    vobject 	= seq(/BEGIN:VCALENDAR(\r|\n|\r\n)/i.r, calprops, components, /END:VCALENDAR(\r|\n|\r\n)/i.r) { |(b, v, rest, e)|
			parse_err("Missing PRODID attribute") unless v.has_key?(:PRODID)
			parse_err("Missing VERSION attribute") unless v.has_key?(:VERSION)
			rest.delete(:END)
			if !v.has_key?(:METHOD) and rest.has_key?(:VEVENT)
				rest[:VEVENT][:component].each {|e|
					parse_err("Missing DTSTART property from VEVENT component")  if ( !e.has_key?(:DTSTART) )
				}
			end
	            	tidyup({ :VCALENDAR => v.merge( rest ) })
		}
    vobject.eof 
  end 

  # any residual tidying of object
  def tidyup(v)
	  # adjust any VTIMEZONE.{STANDARD|DAYLIGHT}.{DTSTART|RDATE} times from floating local to the time within the timezone component
	if !v[:VCALENDAR].has_key?(:VTIMEZONE) or v[:VCALENDAR][:VTIMEZONE][:component].nil? or v[:VCALENDAR][:VTIMEZONE][:component].empty?
		return v
	else
		 if v[:VCALENDAR][:VTIMEZONE][:component].kind_of?(Array)
			 v[:VCALENDAR][:VTIMEZONE][:component].each {|x|
				 x = timezoneadjust x
			 }
		 else
			 v[:VCALENDAR][:VTIMEZONE][:component] = timezoneadjust v[:VCALENDAR][:VTIMEZONE][:component]
		 end
		 return v
	end
  end


  def timezoneadjust(x)
	   if x[:TZID].nil? or x[:TZID].empty?
		return x
	   else
		   # TODO deal with unregistered timezones
		   begin
		   tz = TZInfo::Timezone.get(x[:TZID][:value].value) 
	   		rescue 
				return x
		   end
		[:STANDARD, :DAYLIGHT].each {|k|
		if x.has_key?(k)
	  	   if x[k][:component].kind_of?(Array)
			x[k][:component].each {|y|
				# subtracting a minute to avoid PeriodNotFound exceptions on the boundary between daylight saving and standard time
				# if that doesn't work either, we'll rescue to floating localtime
				# TODO lookup offsets applicable by parsing dates and offsets in the ical. I'd rather not.
				y[:DTSTART][:value].value = {:time => tz.local_to_utc(y[:DTSTART][:value].value[:time] - 60 , true) + 60, :zone => x[:TZID][:value].value} rescue y[:DTSTART][:value].value 
				if y.has_key?(:RDATE)
					if y[:RDATE].kind_of?(Array)
						y[:RDATE].each {|z|
			                                z[:value].value.each {|w|
								w.value = {:time => tz.local_to_utc(w.value[:time] -60 , true) +60, :zone => x[:TZID][:value].value } rescue w.value
			                                }
						}
					else
						y[:RDATE][:value].value = {:time => tz.local_to_utc(y[:RDATE].value[:time] -60, true) +60, :zone => x[:TZID][:value].value } rescue y[:RDATE][:value].value 
					end
				end
			}
		    else 
			    x[k][:component][:DTSTART][:value].value  =  {:time => tz.local_to_utc(x[k][:component][:DTSTART][:value].value[:time]-60, true)+60, :zone => x[:TZID][:value].value} rescue x[k][:component][:DTSTART][:value].value
			if x[k][:component].has_key?(:RDATE)
				if x[k][:component][:RDATE].kind_of?(Array)
					x[k][:component][:RDATE].each {|z|
		                                z[:value].value.each {|w|
							w.value = {:time => tz.local_to_utc(w.value[:time]-60, true)+60, :zone => x[:TZID][:value].value } rescue w.value 
		                                }
					}
				else
					x[k][:component][:RDATE][:value].value = {:time => tz.local_to_utc(x[k][:component][:RDATE][:value].value[:time]-60, true)+60, :zone => x[:TZID][:value].value } rescue x[k][:component][:RDATE][:value].value
				end
			end
		     end
		end
		}
	end
	return x
  end


  # RFC 6868
  def rfc6868decode(x)
	  x.gsub(/\^n/, "\n").gsub(/\^\^/, '^').gsub(/\^'/, '"')
  end

  def parse(vobject)
	@ctx = Rsec::ParseContext.new unfold(vobject), 'source'
	ret = vobjectGrammar._parse @ctx
	if !ret or Rsec::INVALID[ret] 
	      raise @ctx.generate_error 'source'
        end
	Rsec::Fail.reset
	return ret
  end

private

  def unfold(str)
	         str.gsub(/(\r|\n|\r\n)[ \t]/, '')
  end


   def parse_err(msg)
	   	  #STDERR.puts msg
	          #raise @ctx.generate_error 'source'
		  raise @ctx.report_error msg, 'source'
   end

  end
end
end
