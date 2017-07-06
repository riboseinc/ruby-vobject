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
    beginLine 	= seq('BEGIN:'.r , ianaToken , /[\r\n]/)  {|_, token, _|
			{ :BEGIN => token.to_sym }
		}
    endLine 	= seq('END:' , ianaToken , /[\r\n]/) { |_, token, _|
			{ :END => token.to_sym }
        	}
    group 	= ianaToken
    vendorid	= /[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]/.r
    xname 	= seq( '[xX]-', vendorid, '-', ianaToken)
    linegroup 	= group <<  '.' 
    beginend 	= 'BEGIN'.r | 'END'.r
    name  	= xname | seq(''.r ^ beginend , ianaToken )[1]
    paramname 	= xname | ianaToken
    pText  	= safeChar.star.map(&:join)
    quotedString = seq(dQuote, qSafeChar.star, dQuote) {|_, qSafe, _| 
	    		qSafe.join('') 
    		}
    paramvalue 	= quotedString | pText  
    pvalueList 	= (paramvalue & /[;:]/.r).map {|e| 
	    		[e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")]
    		} | (seq(paramvalue, ','.r, lazy{pvalueList}) & /[;:]/.r).map {|e, _, list|
			ret = list << e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n") 
			ret
		}
    param 	= seq(paramname, '=', pvalueList) {|name, _, list|
	    		list = list[0] if list.length == 1
			{name.to_sym => list}
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
			key =  name.to_sym
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
				if @cardinality1.include?(key)
					if !(old.key?(:params) and old[:params].key?(:ALTID) and 
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
    versionLine = seq( 'VERSION:'.r , value , /[\r\n]/) {|_, version, _|
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
	if !ret # or !@ctx.eos?
	      raise @ctx.generate_error 'source'
        end
	#ret = vobjectGrammar.parse! unfold(vobject)
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
