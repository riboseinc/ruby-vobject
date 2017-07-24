require "rsec"
require "set"
require "uri"

module C

 # definitions common to classes

    SIGN        = /[+-]/i.r
    BOOLEAN = ( /TRUE/i.r.map{|x| true} | /FALSE/i.r.map{|x| false} )
    IANATOKEN =  /[a-zA-Z\d\-]+/.r
    vendorid   = /[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]/.r
    XNAME = seq( '[xX]-', vendorid, '-', IANATOKEN)
    #TEXT = /([ \t\u0021\u0023-\u002b\u002d-\u0039\u003c-\u005b\u005d-\u007e\u0080-\u00bf\u00c2-\u00df\u00e0\u00a0-\u00bf\u00e1-\u00ec\u00ed\u0080-\u009f\u00ee-\u00ef\u00f0\u0090-\u00bf\u00f1-\u00f3\u00f4\u0080-\u008f]|\\[nN;,\\])*/.r   
    TEXT = /([ \t\u0021\u0023-\u002b\u002d-\u0039\u003c-\u005b\u005d-\u007e\u0080-\u3ffff:"]|\\[nN;,\\])*/.r   
    DATE       = seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
                             Time.utc(yy, mm, dd)
                     }
    DATE_TIME  = seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, 'T',
                     /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, /Z/i.r._?) {|yy, mm, dd, _, h, m, s, z|
                          z.empty? ? Time.local(yy, mm, dd, h, m, s) : Time.utc(yy, mm, dd, h, m, s)
                  }
    DATE_TIME_UTC      = seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, 'T',
                        /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, /Z/i.r._?) {|yy, mm, dd, _, h, m, s, z|
                             Time.utc(yy, mm, dd, h, m, s)
                     }
    TIME	= seq(/[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, /Z/i.r._?) {|h, m, s, z|
	    			hash = {:hour => h, :min => m, :sec => s}
				hash[:utc] = not(z.empty?)
				hash
                     }
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
    qSafeChar   = wsp | /[!\u0023-\u007e]/ | nonASCII
    safeChar    = wsp | /[!\u0023-\u0039\u003c-\u007e]/  | nonASCII
    vChar       = /[\u0021-\u007e]/.r
    valueChar   = wsp | vChar | nonASCII
    dQuote      = /"/.r


    QUOTEDSTRING = seq(dQuote, qSafeChar.star, dQuote) {|_, qSafe, _|
                            qSafe.join('')
                    }
    PTEXT       = safeChar.star.map(&:join)
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


end
