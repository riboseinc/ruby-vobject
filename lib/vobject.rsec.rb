require "rsec"
include Rsec::Helpers

def vobject
    ianaToken = /[a-zA-Z\d\-]+/.r {|s| s }
    utf8_tail = /[\u0080-\u00bf]/.r
    utf8_2 = /[\u00c2-\u00df]/.r  | utf8_tail
    utf8_3 = /[\u00e0\u00a0-\u00bf\u00e1-\u00ec\u00ed\u0080-\u009f\u00ee-\u00ef]/.r  | utf8_tail
    utf8_4 = /[\u00f0\u0090-\u00bf\u00f1-\u00f3\u00f4\u0080-\u008f]/.r | utf8_tail
    nonASCII = utf8_2 | utf8_3 | utf8_4
    wsp = /[ \t]/.r
    qSafeChar = wsp | /[!\u0023-\u007e]/ | nonASCII
    safeChar = wsp | /[!\u0023-\u0039\u003c-\u007e]/  | nonASCII
    vChar = /[\u0021-\u007e]/.r
    valueChar = wsp | vChar | nonASCII
    dQuote = /"/
    beginLine = seq('BEGIN:'.r , ianaToken , /[\r\n]/).fail('begin')  {|_, token, _|
			{ :BEGIN => token.to_sym }
	}
    endLine = seq('END:' , ianaToken , /[\r\n]/) { |_, token, _|
			{ :END => token.to_sym }
        }
    group = ianaToken
    xname = seq( '[xX]-', ianaToken)
    linegroup = seq( group,  '.' ) {|group, _| group }
    beginend = 'BEGIN'.r | 'END'.r
    name  = ( xname | seq(''.r ^ beginend , ianaToken )[1]).fail('name')
    paramname = xname | ianaToken
    pText  = safeChar.star.map(&:join)
    quotedString = seq(dQuote, qSafeChar.star, dQuote) {|_, qSafe, _| qSafe.join('') }
    paramvalue = pText.map | quotedString
    
    pvalueList = paramvalue.map {|e| e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")  }  |
	    seq(paramvalue, ','.r, lazy{pvalueList} ) {|e, _, list|
			e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n") + "," + list
	}
    param = seq(paramname, '=', pvalueList) {|name, _, list|
			{name.to_sym => list}
	}
    params = seq( ';'.r, param) {|_, p|
			[ p ]
	} 
    params = params | seq(';'.r, param, params ) {|_, p, ps|
			[ p ] + ps
	}
    value = valueChar.star.map(&:join)
    contentline = seq( linegroup._?, name, params._?, ':', value, /[\r\n]/).fail('contentline') {|linegroup, name, params, _, value, _|
			key =  name.to_sym
			hash = { key => {} }
			hash[key][:value] = value
			hash[key][:group] = linegroup  unless linegroup.empty?
			hash[key][:params] = params unless params.empty?
			hash
	}
    rest = endLine.fail('rest1').map {|e| []} |
	    seq(contentline, lazy{rest}).fail('rest2') {|(contentline, rest)|
		[ contentline ]  + rest
    } | seq(beginLine, lazy{rest}, lazy{rest}).fail('rest3') {|(beginline, rest0, rest1)|
		[ { beginline[:BEGIN] => rest0 } ] + rest1
	}
    versionLine = seq( 'VERSION:'.r , value , /[\r\n]/) {|_, version, _|
			hash = { :VERSION => {} }
			hash[:VERSION][:value] = version
			hash
	}
    #pid = /\d+(\.\d+)*/
    #pidList = seq(pid, seq(',', Pid).star)
    vobject = seq(beginLine, versionLine, rest).fail('vobject') { |(beginline, versionline, rest)|
			comp = beginline[:BEGIN].to_sym
	            	hash = { comp => [versionline] + rest }
	            hash
	}

    vobject.eof 
end 
