require "rsec"
require "set"
include Rsec::Helpers

module Vobject

 class << self

  def vobjectGrammar
# properties with value cardinality 1
    @cardinality1 = Set.new [:KIND, :N, :BDAY, :ANNIVERSARY, :GENDER, :PRODID, :REV, :UID, :VERSION]
    ianaToken 	= /[a-zA-Z\d\-]+/.r {|s| s }
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
    name  	= xname | seq(''.r ^ beginend , ianaToken )[1]
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
    boolean 	= /TRUE/i.r | /FALSE/i.r
    tzidvalue 	= seq("/".r._?, pText).map {|_, val| val}
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
    rfc4288regname 	= /[A-Za-z!#$&.+^+-]{1,127}/.r
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
			{name.upcase.to_sym => val}
    		} | seq(/CN/i.r, '=', paramvalue) {|name, _, val|
			{name.upcase.to_sym => val}
    		} | seq(/CUTYPE/i.r, '=', cutypevalue) {|name, _, val|
			{name.upcase.to_sym => val.upcase}
    		} | seq(/DELEGATED-FROM/i.r, '=', quotedStringList) {|name, _, val|
	    		val = val[0] if val.length == 1
			{name.upcase.to_sym => val}
    		} | seq(/DELEGATED-TO/i.r, '=', quotedStringList) {|name, _, val|
	    		val = val[0] if val.length == 1
			{name.upcase.to_sym => val}
		} | seq(/DIR/i.r, '=', quotedString) {|name, _, val|
			{name.upcase.to_sym => val}
    		} | seq(/ENCODING/i.r, '=', encodingvalue) {|name, _, val|
			{name.upcase.to_sym => val.upcase}
    		} | seq(/FMTTYPE/i.r, '=', fmttypevalue) {|name, _, val|
			{name.upcase.to_sym => val.downcase}
    		} | seq(/FBTYPE/i.r, '=', fbtypevalue) {|name, _, val|
			{name.upcase.to_sym => val.upcase}
    		} | seq(/LANGUAGE/i.r, '=', rfc5646langvalue) {|name, _, val|
			{name.upcase.to_sym => val.upcase}
    		} | seq(/MEMBER/i.r, '=', quotedStringList) {|name, _, val|
	    		val = val[0] if val.length == 1
			{name.upcase.to_sym => val}
    		} | seq(/PARTSTAT/i.r, '=', partstatvalue) {|name, _, val|
			{name.upcase.to_sym => val.upcase}
    		} | seq(/RANGE/i.r, '=', rangevalue) {|name, _, val|
			{name.upcase.to_sym => val.upcase}
    		} | seq(/RELATED/i.r, '=', relatedvalue) {|name, _, val|
			{name.upcase.to_sym => val.upcase}
    		} | seq(/RELTYPE/i.r, '=', reltypevalue) {|name, _, val|
			{name.upcase.to_sym => val.upcase}
    		} | seq(/ROLE/i.r, '=', rolevalue) {|name, _, val|
			{name.upcase.to_sym => val.upcase}
    		} | seq(/RSVP/i.r, '=', boolean) {|name, _, val|
			{name.upcase.to_sym => val.upcase}
		} | seq(/SENT-BY/i.r, '=', quotedString) {|name, _, val|
			{name.upcase.to_sym => val}
		} | seq(/TZID/i.r, '=', tzidvalue) {|name, _, val|
			{name.upcase.to_sym => val}
    		} | seq(otherparamname, '=', pvalueList) {|name, _, val|
	    		val = val[0] if val.length == 1
			{name.to_sym => val}
		} | seq(paramname, '=', pvalueList) {|name, _, val|
			parse_err("Violated format of parameter value #{name} = #{val}")
		}
    #params	= seq(';'.r >> param & ':'.r).map {|e|
    params	= seq(';'.r >> param ).map {|e|
			e[0]
    		} | seq(';'.r >> param, lazy{params} ) {|p, ps|
			p.merge(ps) 
		}
    value 	= valueChar.star.map(&:join)
    contentline = seq(linegroup._?, name, params._?, ':', 
		      value, /[\r\n]/) {|group, name, params, _, value, _|
			key =  name.upcase.to_sym
			hash = { key => {} }
			hash[key][:value] = value
			hash[key][:group] = group[0]  unless group.empty?
			hash[key][:params] = params[0] unless params.empty?
			hash
		}
    rest 	= endLine.map {|e| 
	    		e
		} | seq(contentline, lazy{rest}) {|(c, rest)|
			c.merge( rest ) { | key, old, new|
				if @cardinality1.include?(key.upcase)
					if 	!(new.kind_of?(Array) and 
						  	new[0].key?(:params) and new[0][:params].key?(:ALTID) and
					     		old.key?(:params) and old[:params].key?(:ALTID) and 
							old[:params][:ALTID] == new[0][:params][:ALTID]) and
						!(new.kind_of?(Hash) and
						  	old.key?(:params) and old[:params].key?(:ALTID) and 
					     		new.key?(:params) and new[:params].key?(:ALTID) and 
							old[:params][:ALTID] == new[:params][:ALTID])
						parse_err("Violated cardinality of property #{key}")
					end
				end
				[old,  new].flatten
				# deal with duplicate properties
			}
		} | seq(beginLine, lazy{rest}, lazy{rest}) {|(b, rest0, rest1)|
			parse_err("Mismatch BEGIN:#{b[:BEGIN]}, END:#{rest0[:END]}") if b[:BEGIN] != rest0[:END]
			rest0.delete(:END)
			{ b[:BEGIN] => rest0 }.merge(rest1)
		}
    versionLine = seq( /VERSION:/i.r , value , /[\r\n]/) {|_, version, _|
			hash = { :VERSION => {} }
			hash[:VERSION][:value] = version
			hash
		}
    #pid = /\d+(\.\d+)*/
    #pidList = seq(pid, seq(',', Pid).star)
    vobject 	= seq(beginLine, versionLine, rest) { |(b, v, rest)|
			parse_err("Mismatch BEGIN:#{b[:BEGIN]}, END:#{rest[:END]}") if b[:BEGIN] != rest[:END]
			rest.delete(:END)
			comp = b[:BEGIN].to_sym
	            	hash = { comp => v.merge( rest ) }
		        hash
		}
    vobject.eof 
  end 

  def parse(vobject)
	@ctx = Rsec::ParseContext.new unfold(vobject), 'source'
	ret = vobjectGrammar._parse @ctx
	puts ret
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
