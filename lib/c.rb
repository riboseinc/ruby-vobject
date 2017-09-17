require "rsec"
require "set"
require "uri"
require_relative "vobject/vcalendar/propertyvalue"


module C

 # definitions common to classes

    SIGN        = /[+-]/i.r
    BOOLEAN = ( /TRUE/i.r.map{|x| true} | /FALSE/i.r.map{|x| false} )
    IANATOKEN =  /[a-zA-Z\d\-]+/.r
    vendorid_vcal   = /[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]/.r
    XNAME_VCAL = seq( '[xX]-', vendorid_vcal, '-', IANATOKEN).map(&:join)
    vendorid_vcard   = /[a-zA-Z0-9]+/.r # different from iCal
    XNAME_VCARD = seq( '[xX]-', vendorid_vcard, '-', IANATOKEN).map(&:join)
    #TEXT = /([ \t\u0021\u0023-\u002b\u002d-\u0039\u003c-\u005b\u005d-\u007e\u0080-\u00bf\u00c2-\u00df\u00e0\u00a0-\u00bf\u00e1-\u00ec\u00ed\u0080-\u009f\u00ee-\u00ef\u00f0\u0090-\u00bf\u00f1-\u00f3\u00f4\u0080-\u008f]|\\[nN;,\\])*/.r   
    TEXT = /([ \t\u0021\u0023-\u002b\u002d-\u0039\u003c-\u005b\u005d-\u007e\u0080-\u3ffff:"]|\\[nN;,\\])*/.r   
    TEXT3 = 		/([ \t\u0021\u0023-\u002b\u002d-\u0039\u003c-\u005b\u005d-\u007e\u0080-\u3ffff:"]|\\[nN;,\\]?)*/.r   
    TEXT4 = 		/([ \t\u0021\u0023-\u002b\u002d-\u005b\u005d-\u007e\u0080-\u3ffff:"]|\\[nN,\\])*/.r   
    COMPONENT4 = 	/([ \t\u0021\u0023-\u002b\u002d-\u003a\u003c-\u005b\u005d-\u007e\u0080-\u3ffff:"]|\\[nN,;\\])*/.r   
    DATE       = seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
                             Vobject::Vcalendar::PropertyValue::Date.new Time.utc(yy, mm, dd)
                     }
    DATE_TIME  = seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, 'T',
                     /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, /Z/i.r._?) {|yy, mm, dd, _, h, m, s, z|
                          z.empty? ? Vobject::Vcalendar::PropertyValue::DateTimeLocal.new({:time => Time.local(yy, mm, dd, h, m, s), :zone => ''}) :
				  Vobject::Vcalendar::PropertyValue::DateTimeUTC.new({:time => Time.utc(yy, mm, dd, h, m, s), :zone => 'Z'})
                  }
    DATE_TIME_UTC      = seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, 'T',
                        /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, /Z/i.r._?) {|yy, mm, dd, _, h, m, s, z|
                             Vobject::Vcalendar::PropertyValue::DateTimeUTC.new({:time => Time.utc(yy, mm, dd, h, m, s), :zone => 'Z'})
                     }
    TIME	= seq(/[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, /Z/i.r._?) {|h, m, s, z|
	    			hash = {:hour => h, :min => m, :sec => s}
				hash[:utc] = not(z.empty?)
				hash
                     }
    ICALPROPNAMES	= /BEGIN/i.r | /END/i.r | /CALSCALE/i.r | /METHOD/i.r | /VERSION/i.r |
	    	/ATTACH/i.r | /IMAGE/i.r | /CATEGORIES/i.r | /RESOURCERS/i.r | /CLASS/i.r |
		/COMMENT/i.r | /DESCRIPTION/i.r | /LOCATION/i.r | /SUMMARY/i.r | /TZID/i.r |
		/TZNAME/i.r | /CONTACT/i.r | /RELATED-TO/i.r | /UID/i.r | /PRODID/i.r | /NAME/i.r |
		/GEO/i.r | /PERCENT-COMPLETE/i.r | /PRIORITY/i.r | /STATUS/i.r | /COMPLETED/i.r |
		/CREATEED/i.r | /DTSTAMP/i.r | /LAST-MODIFIED/i.r | /DTEND/i.r | /DTSTART/i.r |
		/DUE/i.r | /RECURRENCE-ID/i.r | /EXDATE/i.r | /RDATE/i.r | /TRIGGER/i.r | 
		/FREEBUSY/i.r | /TRANSP/i.r | /TZOFFSETFROM/i.r | /TZOFFSETTO/i.r |
		/TZURI/i.r | /URL/i.r | /SOURCE/i.r | /CONFERENCE/i.r | /ATTENDEE/i.r |
		/ORGANIZER/i.r | /RRULE/i.r | /ACTION/i.r | /REPEAT/i.r | /SEQUENCE/i.r |
		/REQUEST-STATUS/i.r | /BUSYTYPE/i.r | /REFRESH-INTERVAL/i.r | /COLOR/i.r
    VCARD3PROPNAMES	= /BEGIN/i.r | /END/i.r | /SOURCE/i.r | /NAME/i.r | /PROFILE/i.r | 
	    		/VERSION/i.r | /URL/i.r | /FN/i.r | /NICKNAME/i.r | /LABEL/i.r | /EMAIL/i.r |
			/MAILER/i.r | /TITLE/i.r | /ROLE/i.r | /NOTE/i.r | /PRODID/.r | /SORT-STRING/i.r |
			/UID/i.r | /CLASS/i.r | /ORG/i.r | /CATEGORIES/i.r | /N/i.r | /PHOTO/i.r |
			/LOGO/i.r | /SOUND/i.r | /KEY/i.r | /BDAY/i.r | /REV/i.r | /ADR/i.r |
			/TEL/i.r | /TZ/i.r | /GEO/i.r | /AGENT/i.r | /IMPP/i.r |
			/FBURL/i.r | /CALADRURI/i.r | /CALURI/i.r | /CAPURI/i.r
    VCARD4PROPNAMES	= /SOURCE/i.r | /KIND/i.r | /FN/i.r | /NICKNAME/i.r | /NOTE/i.r | /N/i.r |
	    	   	/PHOTO/i.r | /BDAY/i.r | /ANNIVERSARY/i.r | /GENDER/i.r | /ADR/i.r |
			/TEL/i.r | /EMAIL/i.r | /IMPP/i.r | /LANG/i.r | /TZ/i.r |
			/GEO/i.r | /TITLE/i.r | /ROLE/i.r | /LOGO/i.r | /ORG/i.r |
			/MEMBER/i.r | /RELATED/i.r | /CATEGORIES/i.r | /PRODID/i.r |
			/REV/i.r | /SOUND/i.r | /UID/i.r | /CLIENTPIDMAP/i.r | /URL/i.r |
			/KEY/i.r | /FBURL/i.r | /CALADRURI/i.r | /CALURI/i.r | /XML/i.r |
			/BIRTHPLACE/i.r | /DEATHPLACE/i.r | /DEATHDATE/i.r | /EXPERTISE/i.r |
			/HOBBY/i.r | /INTEREST/i.r | /ORG-DIRECTORY/i.r | 
    beginend	= /BEGIN/i.r | /END/i.r
    NAME_VCAL        = C::XNAME_VCAL | seq( ''.r ^ beginend, C::IANATOKEN )[1]
    NAME_VCARD        = C::XNAME_VCARD | seq( ''.r ^ beginend, C::IANATOKEN )[1]
    durday      = seq(/[0-9]+/.r, 'D') {|d, _| {:days => d.to_i }}
    dursecond   = seq(/[0-9]+/.r, 'S')  {|d, _| {:seconds => d.to_i }}
    durminute   = seq(/[0-9]+/.r, 'M', dursecond._?)  {|d, _, s| 
	    		hash =	{:minutes => d.to_i }
			hash = hash.merge s[0] unless s.empty?
			hash
    		}
    durhour     = seq(/[0-9]+/.r, 'H', durminute._?)  {|d, _, m| 
	    		hash =	{:hours => d.to_i }
			hash = hash.merge m[0] unless m.empty?
			hash
    		}
    durweek     = seq(/[0-9]+/.r, 'W')  {|d, _| {:weeks => d.to_i }}
    durtime1    = durhour | durminute | dursecond
    durtime     = seq('T', durtime1) {|_, d| d }
    durdate     = seq(durday, durtime._?) {|d, t| 
	    		d = d.merge t[0] unless t.empty?
			d
		}
    duration1   = durdate | durtime | durweek
    DURATION    = seq(SIGN._?, 'P', duration1) {|s, _, d|
			d[:sign] = s[0] unless s.empty?
			d
		}

    utf8_tail   = /[\u0080-\u00bf]/.r
    utf8_2      = /[\u00c2-\u00df]/.r  | utf8_tail
    utf8_3      = /[\u00e0\u00a0-\u00bf\u00e1-\u00ec\u00ed\u0080-\u009f\u00ee-\u00ef]/.r  |
                      utf8_tail
    utf8_4      = /[\u00f0\u0090-\u00bf\u00f1-\u00f3\u00f4\u0080-\u008f]/.r | utf8_tail
    #nonASCII    = utf8_2 | utf8_3 | utf8_4
    nonASCII    = /[\u0080-\u3ffff]/
    wsp         = /[ \t]/.r
    qSafeChar_vcal   = wsp | /[\u0021\u0023-\u007e]/ | nonASCII
    safeChar_vcal    = wsp | /[\u0021\u0023-\u0039\u003c-\u007e]/  | nonASCII
    qSafeChar_vcard   = wsp | /[!\u0023-\u007e]/ | nonASCII
    safeChar_vcard    = wsp | /[!\u0023-\u0039\u003c-\u007e]/  | nonASCII
    vChar       = /[\u0021-\u007e]/.r
    valueChar   = wsp | vChar | nonASCII
    dQuote      = /"/.r


    QUOTEDSTRING_VCAL = seq(dQuote, qSafeChar_vcal.star, dQuote) {|_, qSafe, _|
                            qSafe.join('')
                    }
    PTEXT_VCAL       = safeChar_vcal.star.map(&:join)
    QUOTEDSTRING_VCARD = seq(dQuote, qSafeChar_vcard.star, dQuote) {|_, qSafe, _|
                            qSafe.join('')
                    }
    PTEXT_VCARD       = safeChar_vcard.star.map(&:join)
    VALUE       = valueChar.star.map(&:join)


    rfc5646irregular    = /en-GB-oed/i.r | /i-ami/i.r | /i-bnn/i.r | /i-default/i.r | /i-enochian/i.r |
                                    /i-hak/i.r | /i-klingon/i.r | /i-lux/i.r | /i-mingo/i.r |
                                    /i-navajo/i.r | /i-pwn/i.r | /i-tao/i.r  | /i-tay/i.r |
                                    /i-tsu/i.r | /sgn-BE-FR/i.r | /sgn-BE-NL/i.r | /sgn-CH-DE/i.r
        rfc5646regular      = /art-lojban/i.r | /cel-gaulish/i.r | /no-bok/i.r | /no-nyn/i.r |
                                /zh-guoyu/i.r | /zh-hakka/i.r | /zh-min/i.r | /zh-min-nan/i.r |
                                /zh-xiang/i.r
    rfc5646grandfathered        = rfc5646irregular | rfc5646regular
        rfc5646privateuse1  = seq('-', /[0-9A-Za-z]{1,8}/.r)
    rfc5646privateuse   = seq('x', rfc5646privateuse1 * (1..-1))
        rfc5646extension1   = seq('-', /[0-9A-Za-z]{2,8}/.r)
    rfc5646extension    = seq('-', /[0-9][A-WY-Za-wy-z]/.r, rfc5646extension1 * (1..-1))
        rfc5646variant      = seq('-', /[A-Za-z]{5,8}/.r) | seq('-', /[0-9][A-Za-z0-9]{3}/)
    rfc5646region       = seq('-', /[A-Za-z]{2}/.r) | seq('-', /[0-9]{3}/)
        rfc5646script       = seq('-', /[A-Za-z]{4}/.r)
    rfc5646extlang      = seq(/[A-Za-z]{3}/.r, /[A-Za-z]{3}/.r._?, /[A-Za-z]{3}/.r._?)
        rfc5646language     = seq(/[A-Za-z]{2,3}/.r , rfc5646extlang._?) | /[A-Za-z]{4}/.r | /[A-Za-z]{5,8}/.r
    rfc5646langtag      = seq(rfc5646language, rfc5646script._?, rfc5646region._?,
                                    rfc5646variant.star, rfc5646extension.star, rfc5646privateuse._? ) {|a, b, c, d, e, f|
                                    [a, b, c, d, e, f].flatten.join('')
                            }
        RFC5646LANGVALUE    = rfc5646langtag | rfc5646privateuse | rfc5646grandfathered

  # https://www.w3.org/TR/2011/REC-css3-color-20110607/#svg-color
    color = /AliceBlue/i.r | /AntiqueWhite/i.r | /Aqua/i.r | /Aquamarine/i.r | /Azure/i.r | /Beige/i.r | 
		  /Bisque/i.r | /Black/i.r | /BlanchedAlmond/i.r | /Blue/i.r | /BlueViolet/i.r | /Brown/i.r | 
		  /BurlyWood/i.r | /CadetBlue/i.r | /Chartreuse/i.r | /Chocolate/i.r | /Coral/i.r | 
		  /CornflowerBlue/i.r | /Cornsilk/i.r | /Crimson/i.r | /Cyan/i.r | /DarkBlue/i.r | 
		  /DarkCyan/i.r | /DarkGoldenRod/i.r | /DarkGray/i.r | /DarkGrey/i.r | /DarkGreen/i.r | 
		  /DarkKhaki/i.r | /DarkMagenta/i.r | /DarkOliveGreen/i.r | /DarkOrange/i.r | /DarkOrchid/i.r | 
		  /DarkRed/i.r | /DarkSalmon/i.r | /DarkSeaGreen/i.r | /DarkSlateBlue/i.r | /DarkSlateGray/i.r | 
		  /DarkSlateGrey/i.r | /DarkTurquoise/i.r | /DarkViolet/i.r | /DeepPink/i.r | /DeepSkyBlue/i.r | 
		  /DimGray/i.r | /DimGrey/i.r | /DodgerBlue/i.r | /FireBrick/i.r | /FloralWhite/i.r | /ForestGreen/i.r | 
		  /Fuchsia/i.r | /Gainsboro/i.r | /GhostWhite/i.r | /Gold/i.r | /GoldenRod/i.r | /Gray/i.r | /Grey/i.r | 
		  /Green/i.r | /GreenYellow/i.r | /HoneyDew/i.r | /HotPink/i.r | /IndianRed/i.r | /Indigo/i.r | 
		  /Ivory/i.r | /Khaki/i.r | /Lavender/i.r | /LavenderBlush/i.r | /LawnGreen/i.r | /LemonChiffon/i.r | 
		  /LightBlue/i.r | /LightCoral/i.r | /LightCyan/i.r | /LightGoldenRodYellow/i.r | /LightGray/i.r | 
		  /LightGrey/i.r | /LightGreen/i.r | /LightPink/i.r | /LightSalmon/i.r | /LightSeaGreen/i.r | 
		  /LightSkyBlue/i.r | /LightSlateGray/i.r | /LightSlateGrey/i.r | /LightSteelBlue/i.r | 
		  /LightYellow/i.r | /Lime/i.r | /LimeGreen/i.r | /Linen/i.r | /Magenta/i.r | /Maroon/i.r | 
		  /MediumAquaMarine/i.r | /MediumBlue/i.r | /MediumOrchid/i.r | /MediumPurple/i.r | 
		  /MediumSeaGreen/i.r | /MediumSlateBlue/i.r | /MediumSpringGreen/i.r | /MediumTurquoise/i.r | 
		  /MediumVioletRed/i.r | /MidnightBlue/i.r | /MintCream/i.r | /MistyRose/i.r | /Moccasin/i.r | 
		  /NavajoWhite/i.r | /Navy/i.r | /OldLace/i.r | /Olive/i.r | /OliveDrab/i.r | /Orange/i.r | 
		  /OrangeRed/i.r | /Orchid/i.r | /PaleGoldenRod/i.r | /PaleGreen/i.r | /PaleTurquoise/i.r | 
		  /PaleVioletRed/i.r | /PapayaWhip/i.r | /PeachPuff/i.r | /Peru/i.r | /Pink/i.r | /Plum/i.r | 
		  /PowderBlue/i.r | /Purple/i.r | /RebeccaPurple/i.r | /Red/i.r | /RosyBrown/i.r | /RoyalBlue/i.r | 
		  /SaddleBrown/i.r | /Salmon/i.r | /SandyBrown/i.r | /SeaGreen/i.r | /SeaShell/i.r | /Sienna/i.r | 
		  /Silver/i.r | /SkyBlue/i.r | /SlateBlue/i.r | /SlateGray/i.r | /SlateGrey/i.r | /Snow/i.r | 
		  /SpringGreen/i.r | /SteelBlue/i.r | /Tan/i.r | /Teal/i.r | /Thistle/i.r | /Tomato/i.r | 
		  /Turquoise/i.r | /Violet/i.r | /Wheat/i.r | /White/i.r | /WhiteSmoke/i.r | /Yellow/i.r | /YellowGreen/i.r 

    UTC_OFFSET = seq(C::SIGN, /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r._?) {|s, h, m, z|
                        h = {:sign => s, :hour => h, :min => m}
                        h[:sec] = z[0] unless z.empty?
                        h
	                }
        ZONE	= UTC_OFFSET.map {|u| u } | 
                    /Z/i.r.map {|z| 'Z'}

end
