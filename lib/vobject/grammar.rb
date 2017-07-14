require "rsec"
require "set"
require "uri"
require "date"
require "tzinfo"
include Rsec::Helpers

module Vobject
 class Grammar
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

    ianaToken 	= /[a-zA-Z\d\-]+/.r 
    utf8_tail 	= /[\u0080-\u00bf]/.r
    utf8_2 	= /[\u00c2-\u00df]/.r  | utf8_tail
    utf8_3 	= /[\u00e0\u00a0-\u00bf\u00e1-\u00ec\u00ed\u0080-\u009f\u00ee-\u00ef]/.r  | 
	          utf8_tail
    utf8_4 	= /[\u00f0\u0090-\u00bf\u00f1-\u00f3\u00f4\u0080-\u008f]/.r | utf8_tail
    nonASCII 	= utf8_2 | utf8_3 | utf8_4
    wsp 	= /[ \t]/.r
    qSafeChar 	= wsp | /[!\u0023-\u007e]/ | nonASCII
    safeChar 	= wsp | /[!\u0023-\u0039\u003c-\u007e]/  | nonASCII
    vChar 	= /[\u0021-\u007e]/.r
    valueChar 	= wsp | vChar | nonASCII
    dQuote 	= /"/.r

    beginLine 	= seq(/BEGIN:/i.r , ianaToken , /[\r\n]/)  {|_, token, _|
			{ :BEGIN => token.to_sym }
		}
    endLine 	= seq(/END:/i.r , ianaToken , /[\r\n]/) { |_, token, _|
			{ :END => token.to_sym }
        	}
    group 	= ianaToken
    vendorid	= /[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]/.r
    xname 	= seq( '[xX]-', vendorid, '-', ianaToken)
    linegroup 	= group <<  '.' 
    beginend 	= /BEGIN/i.r | /END/i.r
    name  	= xname | seq( ''.r ^ beginend, ianaToken )[1]
    boolean 	= /TRUE/i.r | /FALSE/i.r



# parameters and parameter types
    paramname 	= /ALTREP/i.r | /CN/i.r | /CUTYPE/i.r | /DELEGATED-FROM/i.r | /DELEGATED-TO/i.r |
	    		/DIR/i.r | /ENCODING/i.r | /FMTTYPE/i.r | /FBTYPE/i.r | /LANGUAGE/i.r |
			/MEMBER/i.r | /PARTSTAT/i.r | /RANGE/i.r | /RELATED/i.r | /RELTYPE/i.r |
			/ROLE/i.r | /RSVP/i.r | /SENT-BY/i.r | /TZID/i.r
    otherparamname = xname | seq(''.r ^ paramname, ianaToken)[1]
    pText  	= safeChar.star.map(&:join)
    quotedString = seq(dQuote, qSafeChar.star, dQuote) {|_, qSafe, _| 
	    		qSafe.join('') 
    		}
    paramvalue 	= quotedString.map {|s| s } | pText.map {|s| s.upcase }
    cutypevalue	= /INDIVIDUAL/i.r | /GROUP/i.r | /RESOURCE/i.r | /ROOM/i.r | /UNKNOWN/i.r |
	    		xname | ianaToken.map 
    encodingvalue = /8BIT/i.r | /BASE64/i.r
    fbtypevalue	= /FREE/i.r | /BUSY/i.r | /BUSY-UNAVAILABLE/i.r | /BUSY-TENTATIVE/i.r | 
	    		xname | ianaToken
    partstatevent = /NEEDS-ACTION/i.r | /ACCEPTED/i.r | /DECLINED/i.r | /TENTATIVE/i.r |
	    		/DELEGATED/i.r | xname | ianaToken
    partstattodo = /NEEDS-ACTION/i.r | /ACCEPTED/i.r | /DECLINED/i.r | /TENTATIVE/i.r |
	    		/DELEGATED/i.r | /COMPLETED/i.r | /IN-PROCESS/i.r | xname | ianaToken
    partstatjour = /NEEDS-ACTION/i.r | /ACCEPTED/i.r | /DECLINED/i.r | xname | ianaToken
    partstatvalue = partstatevent | partstattodo | partstatjour
    rangevalue 	= /THISANDFUTURE/i.r
    relatedvalue = /START/i.r | /END/i.r
    reltypevalue = /PARENT/i.r | /CHILD/i.r | /SIBLING/i.r | xname | ianaToken
    tzidvalue 	= seq("/".r._?, pText).map {|_, val| val}
    valuetype 	= /BINARY/i.r | /BOOLEAN/i.r | /CAL-ADDRESS/i.r | /DATE-TIME/i.r | /DATE/i.r |
	    	/DURATION/i.r | /FLOAT/i.r | /INTEGER/i.r | /PERIOD/i.r | /RECUR/i.r | /TEXT/i.r |
		/TIME/i.r | /URI/i.r | /UTC-OFFSET/i.r | xname | ianaToken
    rolevalue 	= /CHAIR/i.r | /REQ-PARTICIPANT/i.r | /OPT-PARTICIPANT/i.r | /NON-PARTICIPANT/i.r | 
	    		xname | ianaToken
    pvalueList 	= (paramvalue & /[;:]/.r).map {|e| 
	    		[e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")]
    		} | (seq(paramvalue, ','.r, lazy{pvalueList}) & /[;:]/.r).map {|e, _, list|
			ret = list << e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n") 
			ret
		}
    quotedStringList = (quotedString & /[;:]/.r).map {|e|
                        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")]
                } | (seq(quotedString, ','.r, lazy{quotedStringList}) & /[;:]/.r).map {|e, _, list|
                         ret = list << e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")
                         ret
                }

    rfc4288regname 	= /[A-Za-z0-9!#$&.+^+-]{1,127}/.r
    rfc4288typename 	= rfc4288regname
    rfc4288subtypename 	= rfc4288regname
    fmttypevalue 	= seq(rfc4288typename, "/", rfc4288subtypename).map(&:join)
    rfc5646irregular	= /en-GB-oed/i.r | /i-ami/i.r | /i-bnn/i.r | /i-default/i.r | /i-enochian/i.r |
	    			/i-hak/i.r | /i-klingon/i.r | /i-lux/i.r | /i-mingo/i.r |
				/i-navajo/i.r | /i-pwn/i.r | /i-tao/i.r  | /i-tay/i.r |
				/i-tsu/i.r | /sgn-BE-FR/i.r | /sgn-BE-NL/i.r | /sgn-CH-DE/i.r
    rfc5646regular	= /art-lojban/i.r | /cel-gaulish/i.r | /no-bok/i.r | /no-nyn/i.r |
	    			/zh-guoyu/i.r | /zh-hakka/i.r | /zh-min/i.r | /zh-min-nan/i.r |
				/zh-xiang/i.r
    rfc5646grandfathered	= rfc5646irregular | rfc5646regular
    rfc5646privateuse1	= seq('-', /[0-9A-Za-z]{1,8}/.r)
    rfc5646privateuse	= seq('x', rfc5646privateuse1 * (1..-1))
    rfc5646extension1	= seq('-', /[0-9A-Za-z]{2,8}/.r)
    rfc5646extension	= seq('-', /[0-9][A-WY-Za-wy-z]/.r, rfc5646extension1 * (1..-1))
    rfc5646variant	= seq('-', /[A-Za-z]{5,8}/.r) | seq('-', /[0-9][A-Za-z0-9]{3}/)
    rfc5646region	= seq('-', /[A-Za-z]{2}/.r) | seq('-', /[0-9]{3}/)
    rfc5646script	= seq('-', /[A-Za-z]{4}/.r)
    rfc5646extlang	= seq(/[A-Za-z]{3}/.r, /[A-Za-z]{3}/.r._?, /[A-Za-z]{3}/.r._?)
    rfc5646language	= seq(/[A-Za-z]{2,3}/.r , rfc5646extlang._?) | /[A-Za-z]{4}/.r | /[A-Za-z]{5,8}/.r
    rfc5646langtag	= seq(rfc5646language, rfc5646script._?, rfc5646region._?,
			      rfc5646variant.star, rfc5646extension.star, rfc5646privateuse._? ) {|a, b, c, d, e, f|
	    			[a, b, c, d, e, f].flatten.join('')
    			}
    rfc5646langvalue 	= rfc5646langtag | rfc5646privateuse | rfc5646grandfathered

    param 	= seq(/ALTREP/i.r, '=', quotedString) {|name, _, val|
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
		} | seq(/DIR/i.r, '=', quotedString) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
    		} | seq(/ENCODING/i.r, '=', encodingvalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val.upcase}
    		} | seq(/FMTTYPE/i.r, '=', fmttypevalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val.downcase}
    		} | seq(/FBTYPE/i.r, '=', fbtypevalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val.upcase}
    		} | seq(/LANGUAGE/i.r, '=', rfc5646langvalue) {|name, _, val|
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
    		} | seq(/RSVP/i.r, '=', boolean) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val.upcase}
		} | seq(/SENT-BY/i.r, '=', quotedString) {|name, _, val|
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

    params	= seq(';'.r >> param ).map {|e|
			e[0]
    		} | seq(';'.r >> param, lazy{params} ) {|p, ps|
			p.merge(ps) {|key, old, new|
				if @cardinality1[:PARAM].include?(key)
						parse_err("Violated cardinality of parameter #{key}")
				end
				[old,  new].flatten
				# deal with duplicate properties
			}
		}

    value 	= valueChar.star.map(&:join)
    contentline = seq(linegroup._?, name, params._?, ':', 
		      value, /[\r\n]/) {|group, name, params, _, value, _|
			key =  name.upcase.gsub(/-/,"_").to_sym
			hash = { key => {} }
			hash[key][:value] = Vobject::Typegrammars.typematch(key, params[0], :GENERIC, value)
			hash[key][:group] = group[0]  unless group.empty?
			hash[key][:params] = params[0] unless params.empty?
			hash
		}

=begin
NOT using named properties per component, since ianaToken allows any component, and will result in backtracking error
    eventname	= /DTSTAMP/i.r | /UID/i.r | /DTSTART/i.r | /CLASS/i.r | /CREATED/i.r | /DESCRIPTION/i.r |
	    		/GEO/i.r | /LAST-MOD/i.r | /LOCATION/i.r | /ORGANIZER/i.r | /PRIORITY/i.r |
			/SEQ/i.r | /STATUS/i.r | /SUMMARY/i.r | /TRANSP/i.r | /URL/i.r | /RECURID/i.r |
			/RRULE/i.r | /DTEND/i.r | /DURATION/i.r | /ATTACH/i.r | /ATTENDEE/i.r |
			/CATEGORIES/i.r | /COMMENT/i.r | /CONTACT/i.r | /EXDATE/i.r | /RSTATUS/i.r |
			/RELATED/i.r | /RESOURCES/i.r | /RDATE/i.r | xname | seq( ''.r ^ beginend, ianaToken )[1]
    todoname	= /DTSTAMP/i.r | /UID/i.r | /CLASS/i.r | /COMPLETED/i.r | /CREATED/i.r | /DESCRIPTION/i.r |
	    		/DTSTART/i.r | /GEO/i.r | /LAST-MOD/i.r | /LOCATION/i.r | /ORGANIZER/i.r | 
			/PERCENT-COMPLETE/i.r | /PRIORITY/i.r | /RECURID/i.r | 
			/SEQ/i.r | /STATUS/i.r | /SUMMARY/i.r | /URL/i.r  |
			/RRULE/i.r | /DUE/i.r | /DURATION/i.r | /ATTACH/i.r | /ATTENDEE/i.r |
			/CATEGORIES/i.r | /COMMENT/i.r | /CONTACT/i.r | /EXDATE/i.r | /RSTATUS/i.r |
			/RELATED/i.r | /RESOURCES/i.r | /RDATE/i.r | xname | seq( ''.r ^ beginend, ianaToken )[1]
    journame	= /DTSTAMP/i.r | /UID/i.r | /CLASS/i.r | /CREATED/i.r | /DTSTART/i.r | /LAST-MOD/i.r | /ORGANIZER/i.r | 
			/RECURID/i.r | /SEQ/i.r | /STATUS/i.r | /SUMMARY/i.r | /URL/i.r  |
			/RRULE/i.r | /ATTACH/i.r | /ATTENDEE/i.r |
			/CATEGORIES/i.r | /COMMENT/i.r | /CONTACT/i.r | /DESCRIPTION/i.r | /EXDATE/i.r | /RSTATUS/i.r |
			/RELATED/i.r | /RDATE/i.r | xname | seq( ''.r ^ beginend, ianaToken )[1]
    fbname	= /DTSTAMP/i.r | /UID/i.r | /CONTACT/i.r | /DTSTART/i.r | /DTEND/i.r | 
	    		/ORGANIZER/i.r | /URL/i.r |
			/ATTENDEE/i.r | /COMMENT/i.r | /FREEBUSY/i.r | /RSTATUS/i.r | 
			xname | seq( ''.r ^ beginend, ianaToken )[1]
    timezname	= /TZID/i.r | /LAST-MOD/i.r | /TZURL/i.r | 
			xname | seq( ''.r ^ beginend, ianaToken )[1]
    tzname	= /DTSTART/i.r | /TZOFFSETTO/i.r | /TZOFFSETFROM/i.r | 
	    		/RRULE/i.r | /COMMENT/i.r | /RDATE/i.r | /TZNAME/i.r |
			xname | seq( ''.r ^ beginend, ianaToken )[1]
    alarmname	= /ACTION/i.r | /TRIGGER/i.r | /DURATION/i.r | /REPEAT/i.r | /ATTACH/i.r | /DESCRIPTION/i.r | 
    			/ATTENDEE/i.r |
			xname | seq( ''.r ^ beginend, ianaToken )[1]
=end
    eventline 	= seq(linegroup._?, name, params._?, ':', 
		      value, /[\r\n]/) {|group, name, params, _, value, _|
			key =  name.upcase.gsub(/-/,"_").to_sym
			hash = { key => {} }
			hash[key][:value] = Vobject::Typegrammars.typematch(key, params[0], :EVENT, value)
			hash[key][:group] = group[0]  unless group.empty?
			hash[key][:params] = params[0] unless params.empty?
			hash
		}
    todoline = seq(linegroup._?, name, params._?, ':', 
		      value, /[\r\n]/) {|group, name, params, _, value, _|
			key =  name.upcase.gsub(/-/,"_").to_sym
			hash = { key => {} }
			hash[key][:value] = Vobject::Typegrammars.typematch(key, params[0], :TODO, value)
			hash[key][:group] = group[0]  unless group.empty?
			hash[key][:params] = params[0] unless params.empty?
			hash
		}
    jourline = seq(linegroup._?, name, params._?, ':', 
		      value, /[\r\n]/) {|group, name, params, _, value, _|
			key =  name.upcase.gsub(/-/,"_").to_sym
			hash = { key => {} }
			hash[key][:value] = Vobject::Typegrammars.typematch(key, params[0], :JOURNAL, value)
			hash[key][:group] = group[0]  unless group.empty?
			hash[key][:params] = params[0] unless params.empty?
			hash
		}
    fbline = seq(linegroup._?, name, params._?, ':', 
		      value, /[\r\n]/) {|group, name, params, _, value, _|
			key =  name.upcase.gsub(/-/,"_").to_sym
			hash = { key => {} }
			hash[key][:value] = Vobject::Typegrammars.typematch(key, params[0], :FREEBUSY, value)
			hash[key][:group] = group[0]  unless group.empty?
			hash[key][:params] = params[0] unless params.empty?
			hash
		}
    timezline = seq(linegroup._?, name, params._?, ':', 
		      value, /[\r\n]/) {|group, name, params, _, value, _|
			key =  name.upcase.gsub(/-/,"_").to_sym
			hash = { key => {} }
			hash[key][:value] = Vobject::Typegrammars.typematch(key, params[0], :TIMEZONE, value)
			hash[key][:group] = group[0]  unless group.empty?
			hash[key][:params] = params[0] unless params.empty?
			hash
		}
    tzline = seq(linegroup._?, name, params._?, ':', 
		      value, /[\r\n]/) {|group, name, params, _, value, _|
			key =  name.upcase.gsub(/-/,"_").to_sym
			hash = { key => {} }
			hash[key][:value] = Vobject::Typegrammars.typematch(key, params[0], :TZ, value)
			hash[key][:group] = group[0]  unless group.empty?
			hash[key][:params] = params[0] unless params.empty?
			hash
		}
    alarmline = seq(linegroup._?, name, params._?, ':', 
		      value, /[\r\n]/) {|group, name, params, _, value, _|
			key =  name.upcase.gsub(/-/,"_").to_sym
			hash = { key => {} }
			hash[key][:value] = Vobject::Typegrammars.typematch(key, params[0], :ALARM, value)
			hash[key][:group] = group[0]  unless group.empty?
			hash[key][:params] = params[0] unless params.empty?
			hash
		}

=begin 
				if @cardinality1.include?(key.upcase)
APPLIES TO VCARD ONLY
					and 	!(new.kind_of?(Array) and 
						  	new[0].key?(:params) and new[0][:params].key?(:ALTID) and
					     		old.key?(:params) and old[:params].key?(:ALTID) and 
							old[:params][:ALTID] == new[0][:params][:ALTID]) and
						!(new.kind_of?(Hash) and
						  	old.key?(:params) and old[:params].key?(:ALTID) and 
					     		new.key?(:params) and new[:params].key?(:ALTID) and 
							old[:params][:ALTID] == new[:params][:ALTID])
						parse_err("Violated cardinality of property #{key}")
=end
		
        props	= (''.r & beginend).map {|e|
			 	{}   
			} | seq(contentline, lazy{props}) {|c, rest|
			c.merge( rest ) { | key, old, new|
				[old,  new].flatten
				# deal with duplicate properties
			}
			}
        alarmprops	= (''.r & beginend).map {|e|
			 	{}   
			} | seq(alarmline, lazy{alarmprops}) {|c, rest|
			c.merge( rest ) { | key, old, new|
				if @cardinality1[:ALARM].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
				# deal with duplicate properties
			}
			}
        fbprops		= (''.r & beginend).map {|e|
			 	{}   
			} | seq(fbline, lazy{fbprops}) {|c, rest|
			c.merge( rest ) { | key, old, new|
				if @cardinality1[:FREEBUSY].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
				# deal with duplicate properties
			}
			}
        journalprops	= (''.r & beginend).map {|e|
			 	{}   
			} | seq(jourline, lazy{journalprops}) {|c, rest|
			c.merge( rest ) { | key, old, new|
				if @cardinality1[:JOURNAL].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
				# deal with duplicate properties
			}
			}
        tzprops		= (''.r & beginend).map {|e|
			 	{}   
			} | seq(tzline, lazy{tzprops}) {|c, rest|
			c.merge( rest ) { | key, old, new|
				if @cardinality1[:TZ].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
				# deal with duplicate properties
			}
			}
	standardc	= seq(/BEGIN:STANDARD[\r\n]/i.r, tzprops, /END:STANDARD[\r\n]/i.r) {|_, e, _|
				parse_err("Missing DTSTART property") unless e.has_key?(:DTSTART)
				parse_err("Missing TZOFFSETTO property") unless e.has_key?(:TZOFFSETTO)
				parse_err("Missing TZOFFSETFROM property") unless e.has_key?(:TZOFFSETFROM)
				hash = { :STANDARD => e }
				hash
			}
	daylightc	= seq(/BEGIN:DAYLIGHT[\r\n]/i.r, tzprops, /END:DAYLIGHT[\r\n]/i.r) {|_, e, _|
				parse_err("Missing DTSTART property") unless e.has_key?(:DTSTART)
				parse_err("Missing TZOFFSETTO property") unless e.has_key?(:TZOFFSETTO)
				parse_err("Missing TZOFFSETFROM property") unless e.has_key?(:TZOFFSETFROM)
				hash = { :DAYLIGHT => e }
				hash
			}
	timezoneprops	= (''.r & beginend).map {|e|
		                {}
	                } | seq(standardc, lazy{timezoneprops}) {|e, rest|
				e.merge(rest)
	                } | seq(daylightc, lazy{timezoneprops}) {|e, rest|
				e.merge(rest)
			} | seq(timezline, lazy{timezoneprops}) {|e, rest|
				e.merge( rest ) { | key, old, new|
				if @cardinality1[:TIMEZONE].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
				# deal with duplicate properties
				}
			}
        todoprops	= (''.r & beginend).map {|e|
			 	{}   
			} | seq(todoline, lazy{todoprops}) {|c, rest|
				c.merge( rest ) { | key, old, new|
				if @cardinality1[:TODO].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
				# deal with duplicate properties
				}
			}
        eventprops	= (''.r & beginend).map {|e|
			 	{}   
			} | seq(eventline, lazy{eventprops}) {|c, rest|
				c.merge( rest ) { | key, old, new|
				if @cardinality1[:EVENT].include?(key.upcase)
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
				# deal with duplicate properties
				}
			}
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
				hash = { :VALARM => e }
				hash
			}
	freebusyc	= seq(/BEGIN:VFREEBUSY[\r\n]/i.r, fbprops, /END:VFREEBUSY[\r\n]/i.r) {|_, e, _|
				parse_err("Missing DTSTAMP property") unless e.has_key?(:DTSTAMP)
				parse_err("Missing UID property") unless e.has_key?(:UID)
				parse_err("DTEND before DTSTART") if e.has_key?(:DTEND) and e.has_key?(:DTSTART) and 
					e[:DTEND] < e[:DTSTART]
				hash = { :VJOURNAL => e }
				hash
			}
	journalc	= seq(/BEGIN:VJOURNAL[\r\n]/i.r, journalprops, /END:VJOURNAL[\r\n]/i.r) {|_, e, _|
				parse_err("Missing DTSTAMP property") unless e.has_key?(:DTSTAMP)
				parse_err("Missing UID property") unless e.has_key?(:UID)
				parse_err("Missing DTSTART property with RRULE property") if e.has_key?(:RRULE) and !e.has_key?(:DTSTART)
				hash = { :VJOURNAL => e }
				hash
			}
	timezonec	= seq(/BEGIN:VTIMEZONE[\r\n]/i.r, timezoneprops, /END:VTIMEZONE[\r\n]/i.r) {|_, e, _|
				parse_err("Missing STANDARD or DAYLIGHT property") unless e.has_key?(:STANDARD) and e.has_key?(:DAYLIGHT)
				hash = { :VJOURNAL => e }
				hash
			}
	todoc		= seq(/BEGIN:VTODO[\r\n]/i.r, todoprops, alarmc._?, /END:VTODO[\r\n]/i.r) {|_, e, a, _|
				parse_err("Missing DTSTAMP property") unless e.has_key?(:DTSTAMP)
				parse_err("Missing UID property") unless e.has_key?(:UID)
				parse_err("Coocurring DUE and DURATION properties") if e.has_key?(:DUE) and e.has_key?(:DURATION)
				parse_err("Missing DTSTART property with DURATION property") if e.has_key?(:DURATION) and !e.has_key?(:DTSTART)
				parse_err("Missing DTSTART property with RRULE property") if e.has_key?(:RRULE) and !e.has_key?(:DTSTART)
				parse_err("DUE before DTSTART") if e.has_key?(:DUE) and e.has_key?(:DTSTART) and 
					e[:DUE] < e[:DTSTART]
				# TODO not doing constraint that due and dtstart are both or neither local time
				# TODO not doing constraint that recurrence-id and dtstart are both or neither local time
				# TODO not doing constraint that recurrence-id and dtstart are both or neither date
				hash = { :VTODO => e }
				hash = hash.merge(a[0]) unless a.empty?
				hash
			}
	eventc		= seq(/BEGIN:VEVENT[\r\n]/i.r, eventprops, alarmc._?, /END:VEVENT[\r\n]/i.r) {|_, e, a, _|
				parse_err("Missing DTSTAMP property") unless e.has_key?(:DTSTAMP)
				parse_err("Missing UID property") unless e.has_key?(:UID)
				parse_err("Coocurring DTEND and DURATION properties") if e.has_key?(:DTEND) and e.has_key?(:DURATION)
				parse_err("Missing DTSTART property with RRULE property") if e.has_key?(:RRULE) and !e.has_key?(:DTSTART)
				parse_err("DTEND before DTSTART") if e.has_key?(:DTEND) and e.has_key?(:DTSTART) and 
					e[:DTEND] < e[:DTSTART]
				# TODO not doing constraint that dtend and dtstart are both or neither local time
				hash = { :VEVENT => e }
				hash = hash.merge(a[0]) unless a.empty?
				hash
			}
	xcomp		= seq(/BEGIN:/i.r, xname, /[\r\n]/i.r, props, /END:/i.r, xname, /[\r\n]/i.r) {|_, n, _, p, _, n1, _|
				n = n.upcase
				n1 = n1.upcase
				parse_err("Mismatch BEGIN:#{n}, END:#{n1}") if n != n1
				hash = { n1.to_sym => p }
				hash
			}
	ianacomp	= seq(/BEGIN:/i.r, ianaToken, /[\r\n]/i.r, props, /END:/i.r, ianaToken, /[\r\n]/i.r) {|_, n, _, p, _, n1, _|
				n = n.upcase
				n1 = n1.upcase
				parse_err("Mismatch BEGIN:#{n}, END:#{n1}") if n != n1
				hash = { n1.to_sym => p }
				hash
			}


	component	= eventc | todoc | journalc | freebusyc | timezonec | ianacomp | xcomp
	components 	= component | seq(component, lazy{components}) {|c, r|
				c.merge(r)
			}

	calpropname = /CALSCALE/i.r | /METHOD/i.r | /PRODID/i.r | /VERSION/i.r |
	                xname | ianaToken
	calprop     = seq(calpropname, params._?, ':', value, 	/[\r\n]/) {|key, params, _, value, _|
	    		key = key.upcase.gsub(/-/,"_").to_sym
	    		hash = { key => {} }
			hash[key][:value] = Vobject::Typegrammars.typematch(key, params[0], :CALENDAR, value)
			hash[key][:params] = params[0] unless params.empty?
			hash
	}
	calprops    = (''.r & beginend).map {
	        {}
	} | seq(calprop, lazy{calprops} ) {|c, rest|
	        c.merge( rest) {|key, old, new|
	            parse_err("Multiple instances of #{key}") if key == :PRODID or key == :VERSION or key == :CALSCALE or key == :METHOD
	            [old, new].flatten
	        }
	}
    vobject 	= seq(/BEGIN:VCALENDAR[\r\n]/i.r, calprops, components, /END:VCALENDAR[\r\n]/i.r) { |(b, v, rest, e)|
			#parse_err("Mismatch BEGIN:#{b[:BEGIN]}, END:#{rest[:END]}") if b[:BEGIN] != rest[:END]
			parse_err("Missing PRODID attribute") unless v.has_key?(:PRODID)
			parse_err("Missing VERSION attribute") unless v.has_key?(:VERSION)
			rest.delete(:END)
	            	hash = { :VCALENDAR => v.merge( rest ) }
			parse_err("Missing DTSTART property") if !v.has_key?(:METHOD) and rest.has_key?(:VEVENT) and
				!rest[:VEVENT].has_key?(:DTSTART)
		        hash
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
	         str.gsub(/[\n\r]+[ \t]+/, '')
  end


   def parse_err(msg)
	   	  STDERR.puts msg
	          raise @ctx.generate_error 'source'
   end

  end
end
end
