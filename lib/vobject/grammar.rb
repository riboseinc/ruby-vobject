require "rsec"
require "set"
require "uri"
require "date"
require "tzinfo"
include Rsec::Helpers
require_relative "../c"
require_relative "../error"
require "vobject"
require "vobject/typegrammars"

module Vobject
 class Grammar
	 include C


	 class << self
  def vobjectGrammar

# properties with value cardinality 1
    @cardinality1 = {}
    @cardinality1[:EVENT] = Set.new [:UID, :DTSTAMP, :DTSTART, :CLASS, :CREATED, :DESCRIPTION, :GEO, :LAST_MOD,
    			:LOCATION, :ORGANIZER, :PRIORITY, :SEQ, :STATUS, :TRANSP, :URL, :RECURID]
    @cardinality1[:TODO] = Set.new [:UID, :DTSTAMP, :CLASS, :COMPLETED, :CREATED, :DESCRIPTION, :DTSTART, :GEO, :LAST_MOD,
    			:LOCATION, :ORGANIZER, :PERCENT_COMPLETE, :PRIORITY, :SEQ, :STATUS, :SUMMARY, :URL, :RECURID]
    @cardinality1[:JOURNAL] = Set.new [:UID, :DTSTAMP, :CLASS, :CREATED, :DTSTART, :LAST_MOD,
    			:ORGANIZER, :SEQ, :STATUS, :SUMMARY, :URL, :RECURID]
    @cardinality1[:FREEBUSY] = Set.new [:UID, :DTSTAMP, :CONTACT, :DTSTART, :DTEND, :ORGANIZER, :URL]
    @cardinality1[:TIMEZONE] = Set.new [:TZID, :LAST_MOD, :TZURL]
    @cardinality1[:TZ] = Set.new [:DTSTART, :TZOFFSETTTO, :TZOFFSETFROM]
    @cardinality1[:ALARM] = Set.new [:ACTION, :TRIGGER, :DURATION, :REPEAT, :DESCRIPTION, :SUMMARY]
    @cardinality1[:PARAM] = Set.new [:FMTTYPE, :LANGUAGE, :ALTREP, :FBTYPE, :TRANSP, :CUTYPE, :MEMBER, :ROLE, :PARTSTAT, :RSVP, :DELEGATED_TO, 
    :DELEGATED_FROM, :SENT_BY, :CN, :DIR, :RANGE, :RELTYPE, :RELATED]

    group 	= C::IANATOKEN
    linegroup 	= group <<  '.' 
    beginend 	= /BEGIN/i.r | /END/i.r
    name  	= C::XNAME | seq( ''.r ^ beginend, C::IANATOKEN )[1]


# parameters and parameter types
    paramname 	= /ALTREP/i.r | /CN/i.r | /CUTYPE/i.r | /DELEGATED-FROM/i.r | /DELEGATED-TO/i.r |
	    		/DIR/i.r | /ENCODING/i.r | /FMTTYPE/i.r | /FBTYPE/i.r | /LANGUAGE/i.r |
			/MEMBER/i.r | /PARTSTAT/i.r | /RANGE/i.r | /RELATED/i.r | /RELTYPE/i.r |
			/ROLE/i.r | /RSVP/i.r | /SENT-BY/i.r | /TZID/i.r
    otherparamname = C::XNAME | seq(''.r ^ paramname, C::IANATOKEN )[1]
    paramvalue 	= C::QUOTEDSTRING.map {|s| s } | C::PTEXT.map {|s| s.upcase }
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
    pvalueList 	= (paramvalue & /[;:]/.r).map {|e| 
	    		[e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")]
    		} | (seq(paramvalue, ','.r, lazy{pvalueList}) & /[;:]/.r).map {|e, _, list|
			ret = list << e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n") 
			ret
		}
    quotedStringList = (C::QUOTEDSTRING & /[;:]/.r).map {|e|
                        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")]
                } | (seq(C::QUOTEDSTRING, ','.r, lazy{quotedStringList}) & /[;:]/.r).map {|e, _, list|
                         ret = list << e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")
                         ret
		}           

    rfc4288regname 	= /[A-Za-z0-9!#$&.+^+-]{1,127}/.r
    rfc4288typename 	= rfc4288regname
    rfc4288subtypename 	= rfc4288regname
    fmttypevalue 	= seq(rfc4288typename, "/", rfc4288subtypename).map(&:join)
    			
    param 	= seq(/ALTREP/i.r, '=', C::QUOTEDSTRING) {|name, _, val|
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
		} | seq(/DIR/i.r, '=', C::QUOTEDSTRING) {|name, _, val|
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
		} | seq(/SENT-BY/i.r, '=', C::QUOTEDSTRING) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | seq(/TZID/i.r, '=', tzidvalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | seq(/VALUE/i.r, '=', valuetype) {|name, _, val|
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

    contentline = seq(linegroup._?, name, params._?, ':', 
		      C::VALUE, /[\r\n]/) {|group, name, params, _, value, _|
			key =  name.upcase.gsub(/-/,"_").to_sym
			hash = { key => {:value => value} }
			hash[key][:group] = group[0]  unless group.empty?
			hash[key][:params] = params[0] unless params.empty?
			hash
		}

        props	= (''.r & beginend).map {|e| {}   } | 
		seq(contentline, lazy{props}) {|c, rest|
			k = c.keys[0]
			c[k][:value] = Vobject::Typegrammars.typematch(k, c[k][:params], :GENERIC, c[k][:value])
			c.merge( rest ) { | key, old, new|
				[old,  new].flatten
				# deal with duplicate properties
			}
			}
        alarmprops	= (''.r & beginend).map {|e| {}   } | 
		seq(contentline, lazy{alarmprops}) {|c, rest|
			k = c.keys[0]
			c[k][:value] = Vobject::Typegrammars.typematch(k, c[k][:params], :ALARM, c[k][:value])
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
			c[k][:value] = Vobject::Typegrammars.typematch(k, c[k][:params], :FREEBUSY, c[k][:value])
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
			c[k][:value] = Vobject::Typegrammars.typematch(k, c[k][:params], :JOURNAL, c[k][:value])
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
			c[k][:value] = Vobject::Typegrammars.typematch(k, c[k][:params], :TZ, c[k][:value])
			c.merge( rest ) { | key, old, new|
				if @cardinality1[:TZ].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
			}
			}
	standardc	= seq(/BEGIN:STANDARD[\r\n]/i.r, tzprops, /END:STANDARD[\r\n]/i.r) {|_, e, _|
				parse_err("Missing DTSTART property") unless e.has_key?(:DTSTART)
				parse_err("Missing TZOFFSETTO property") unless e.has_key?(:TZOFFSETTO)
				parse_err("Missing TZOFFSETFROM property") unless e.has_key?(:TZOFFSETFROM)
				{ :STANDARD => e }
			}
	daylightc	= seq(/BEGIN:DAYLIGHT[\r\n]/i.r, tzprops, /END:DAYLIGHT[\r\n]/i.r) {|_, e, _|
				parse_err("Missing DTSTART property") unless e.has_key?(:DTSTART)
				parse_err("Missing TZOFFSETTO property") unless e.has_key?(:TZOFFSETTO)
				parse_err("Missing TZOFFSETFROM property") unless e.has_key?(:TZOFFSETFROM)
				{ :DAYLIGHT => e }
			}
	timezoneprops	= 
			seq(standardc, lazy{timezoneprops}) {|e, rest|
				e.merge(rest)
	                } | seq(daylightc, lazy{timezoneprops}) {|e, rest|
				e.merge(rest)
			} | seq(contentline, lazy{timezoneprops}) {|e, rest|
			k = e.keys[0]
			e[k][:value] = Vobject::Typegrammars.typematch(k, e[k][:params], :TIMEZONE, e[k][:value])
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
			c[k][:value] = Vobject::Typegrammars.typematch(k, c[k][:params], :TODO, c[k][:value])
				c.merge( rest ) { | key, old, new|
				if @cardinality1[:TODO].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
				}
			}
        eventprops	= 
			seq(contentline, lazy{eventprops}) {|c, rest|
			k = c.keys[0]
			c[k][:value] = Vobject::Typegrammars.typematch(k, c[k][:params], :EVENT, c[k][:value])
				c.merge( rest ) { | key, old, new|
				if @cardinality1[:EVENT].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
				}
			} |
			(''.r & beginend).map {|e| {}   } 
	alarmc		= seq(/BEGIN:VALARM[\r\n]/i.r, alarmprops, /END:VALARM[\r\n]/i.r) {|_, e, _|
				parse_err("Missing ACTION property") unless e.has_key?(:ACTION)
				parse_err("Missing TRIGGER property") unless e.has_key?(:TRIGGER)
				if e.has_key?(:DURATION) and !e.has_key?(:REPEAT) or !e.has_key?(:DURATION) and e.has_key?(:REPEAT)
				 	parse_err("Missing DURATION and REPEAT properties") 
				end
				if e[:ACTION] == 'AUDIO'
					parse_err("Multiple ATTACH properties") if e.has_key?(:ATTACH) and e[:ATTACH].kind_of?(Array)
				elsif e[:ACTION] == 'DISP'
					parse_err("Missing DESCRIPTION property") unless e.has_key?(:DESCRIPTION)
				elsif e[:ACTION] == 'EMAIL'
					parse_err("Missing DESCRIPTION property") unless e.has_key?(:DESCRIPTION)
					parse_err("Missing SUMMARY property") unless e.has_key?(:SUMMARY)
					parse_err("Missing ATTENDEE property") unless e.has_key?(:ATTENDEE)
				end
				{ :VALARM => e }
			}
	freebusyc	= seq(/BEGIN:VFREEBUSY[\r\n]/i.r, fbprops, /END:VFREEBUSY[\r\n]/i.r) {|_, e, _|
				parse_err("Missing DTSTAMP property") unless e.has_key?(:DTSTAMP)
				parse_err("Missing UID property") unless e.has_key?(:UID)
				parse_err("DTEND before DTSTART") if e.has_key?(:DTEND) and e.has_key?(:DTSTART) and 
					e[:DTEND][:value] < e[:DTSTART][:value]
				{ :VFREEBUSY => e }
			}
	journalc	= seq(/BEGIN:VJOURNAL[\r\n]/i.r, journalprops, /END:VJOURNAL[\r\n]/i.r) {|_, e, _|
				parse_err("Missing DTSTAMP property") unless e.has_key?(:DTSTAMP)
				parse_err("Missing UID property") unless e.has_key?(:UID)
				parse_err("Missing DTSTART property with RRULE property") if e.has_key?(:RRULE) and !e.has_key?(:DTSTART)
				{ :VJOURNAL => e }
			}
	timezonec	= seq(/BEGIN:VTIMEZONE[\r\n]/i.r, timezoneprops, /END:VTIMEZONE[\r\n]/i.r) {|_, e, _|
				parse_err("Missing STANDARD or DAYLIGHT property") unless e.has_key?(:STANDARD) and e.has_key?(:DAYLIGHT)
				{ :VTIMEZONE => e }
			}
	todoc		= seq(/BEGIN:VTODO[\r\n]/i.r, todoprops, alarmc.star, /END:VTODO[\r\n]/i.r) {|_, e, a, _|
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
					e = e.merge x
				end
				{ :VTODO => e }
			}
	eventc		= seq(/BEGIN:VEVENT[\r\n]/i.r, eventprops, alarmc.star, /END:VEVENT[\r\n]/i.r) {|_, e, a, _|
				parse_err("Missing DTSTAMP property") unless e.has_key?(:DTSTAMP)
				parse_err("Missing UID property") unless e.has_key?(:UID)
				parse_err("Coocurring DTEND and DURATION properties") if e.has_key?(:DTEND) and e.has_key?(:DURATION)
				parse_err("Missing DTSTART property with RRULE property") if e.has_key?(:RRULE) and !e.has_key?(:DTSTART)
				parse_err("DTEND before DTSTART") if e.has_key?(:DTEND) and e.has_key?(:DTSTART) and 
					e[:DTEND][:value] < e[:DTSTART][:value]
				# TODO not doing constraint that dtend and dtstart are both or neither local time
				a.each do |x|
					e = e.merge x
				end
				{ :VEVENT => e }
			}
	xcomp		= seq(/BEGIN:/i.r, C::XNAME, /[\r\n]/i.r, props, /END:/i.r, C::XNAME, /[\r\n]/i.r) {|_, n, _, p, _, n1, _|
				n = n.upcase
				n1 = n1.upcase
				parse_err("Mismatch BEGIN:#{n}, END:#{n1}") if n != n1
				{ n1.to_sym => p }
			}
	ianacomp	= seq(/BEGIN:/i.r, C::IANATOKEN, /[\r\n]/i.r, props, /END:/i.r, C::IANATOKEN, /[\r\n]/i.r) {|_, n, _, p, _, n1, _|
				n = n.upcase
				n1 = n1.upcase
				parse_err("Mismatch BEGIN:#{n}, END:#{n1}") if n != n1
				{ n1.to_sym => p }
			}


	component	= eventc | todoc | journalc | freebusyc | timezonec | ianacomp | xcomp
	components 	= seq(component, lazy{components}) {|c, r|
				c.merge(r)
			} | component

	calpropname = /CALSCALE/i.r | /METHOD/i.r | /PRODID/i.r | /VERSION/i.r |
	                C::XNAME | C::IANATOKEN
	calprop     = seq(calpropname, params._?, ':', C::VALUE, 	/[\r\n]/) {|key, params, _, value, _|
	    		key = key.upcase.gsub(/-/,"_").to_sym
	    		hash = { key => {:value => Vobject::Typegrammars.typematch(key, params[0], :CALENDAR, value) }}
			hash[key][:params] = params[0] unless params.empty?
			hash
	}
	calprops    = (''.r & beginend).map { {} } | 
		seq(calprop, lazy{calprops} ) {|c, rest|
	        c.merge( rest) {|key, old, new|
	            parse_err("Multiple instances of #{key}") if key == :PRODID or key == :VERSION or key == :CALSCALE or key == :METHOD
	            [old, new].flatten
	        }
	}
    vobject 	= seq(/BEGIN:VCALENDAR[\r\n]/i.r, calprops, components, /END:VCALENDAR[\r\n]/i.r) { |(b, v, rest, e)|
			parse_err("Missing PRODID attribute") unless v.has_key?(:PRODID)
			parse_err("Missing VERSION attribute") unless v.has_key?(:VERSION)
			rest.delete(:END)
			parse_err("Missing DTSTART property") if !v.has_key?(:METHOD) and rest.has_key?(:VEVENT) and
				!rest[:VEVENT].has_key?(:DTSTART)
	            	{ :VCALENDAR => v.merge( rest ) }
		}
    vobject.eof 
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
	         str.gsub(/[\n\r][ \t]/, '')
  end


   def parse_err(msg)
	   	  #STDERR.puts msg
	          #raise @ctx.generate_error 'source'
		  raise @ctx.report_error msg, 'source'
   end

  end
end
end
