require "rsec"
require "set"
require "uri"
require "date"
#require "tzinfo"
include Rsec::Helpers
require 'vobject/vcard/version'
require 'vobject'
require 'vobject/component'
require "vobject/vcard/v3_0/paramcheck"
require "vobject/vcard/v3_0/typegrammars"
require_relative "../../../c"
require_relative "../../../error"

module Vcard::V3_0
	class Grammar
attr_accessor :strict, :errors
 class << self
  def unfold(str)
	         str.gsub(/[\n\r]+[ \t]/, '')
  end
 end

  def vobjectGrammar

# properties with value cardinality 1
    @cardinality1 = {}
    @cardinality1[:PARAM] = Set.new [:VALUE]
    @cardinality1[:PROP] = Set.new [:KIND, :N, :BDAY, :ANNIVERSARY, :GENDER, :PRODID, :REV, :UID]

    group 	= C::IANATOKEN
    linegroup 	= group <<  '.' 
    beginend 	= /BEGIN/i.r | /END/i.r



# parameters and parameter types
    paramname 		= /ENCODING/i.r | /LANGUAGE/i.r | /CONTEXT/i.r | /TYPE/i.r | /VALUE/i.r | /PREF/i.r
    otherparamname = C::NAME_VCARD ^ paramname
    paramvalue 	= C::QUOTEDSTRING_VCARD.map {|s| s } | C::PTEXT_VCARD.map {|s| s.upcase }
    
    prefvalue	= /[0-9]{1,2}/i.r | '100'.r
    valuetype 	= /URI/i.r | /DATE/i.r | /DATE-TIME/i.r | /BINARY/i.r | /PTEXT/i.r  
    mediaattr	= /[!\"#$%&'*+.^A-Z0-9a-z_`i{}|~-]+/.r
    mediavalue	=	mediaattr | C::QUOTEDSTRING_VCARD
    mediatail   = seq(';', mediaattr, '=', mediavalue).map {|_, a, _, v|
	                       ";#{a}=#{v}"
	               }
    rfc4288regname      = /[A-Za-z0-9!#$&.+^+-]{1,127}/.r
    rfc4288typename     = rfc4288regname
    rfc4288subtypename  = rfc4288regname
    mediavalue	= seq(rfc4288typename, "/", rfc4288subtypename, mediatail.star).map {|t, _, s, tail|
	                  ret = "#{t}/#{s}"
	                  ret = ret . tail[0] unless tail.empty?
	                  ret
                  }
    pvalueList 	=  (seq(paramvalue, ','.r, lazy{pvalueList}) & /[;:]/.r).map {|e, _, list|
			[e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n") , list].flatten
		} | (paramvalue & /[;:]/.r).map {|e|
                        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")]
                }
    typevaluelist = seq(C::IANATOKEN, ','.r >> lazy{typevaluelist}).map {|t, l|
	    		[t.upcase, l].flatten
    		} | C::IANATOKEN.map {|t| [t.upcase] }
    quotedStringList = (seq(C::QUOTEDSTRING_VCARD, ','.r, lazy{quotedStringList}) & /[;:]/.r).map {|e, _, list|
                         [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n"), list].flatten
                } | (C::QUOTEDSTRING_VCARD & /[;:]/.r).map {|e|
                        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")]
                }

    fmttypevalue 	= seq(rfc4288typename, "/", rfc4288subtypename).map(&:join)
    rfc1766primarytag 	= /[A-Za-z]{1,8}/.r
    rfc1766subtag 	= seq('-', /[A-Za-z]{1,8}/.r) {|a, b| a + b }
    rfc1766language	= seq(rfc1766primarytag, rfc1766subtag.star) {|a, b| 
	    			a += b[0] unless b.empty?
				a
	    		}

    param 	= seq(/ENCODING/i.r, '=', /b/.r) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
    		} | seq(/LANGUAGE/i.r, '=', rfc1766language) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val.upcase}
    		} | seq(/CONTEXT/i.r, '=', /word/.r) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val.upcase}
    		} | seq(/TYPE/i.r, '=', typevaluelist) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | seq(/VALUE/i.r, '=', valuetype) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | /PREF/i.r.map {|name|
			# this is likely erroneous use of VCARD 2.1 convention in RFC2739; converting to canonical TYPE=PREF
			{:TYPE => ["PREF"]}
    		} | seq(otherparamname, '=', pvalueList) {|name, _, val|
	    		val = val[0] if val.length == 1
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | seq(paramname, '=', pvalueList) {|name, _, val|
			parse_err("Violated format of parameter value #{name} = #{val}")
		}

    params	= seq(';'.r >> param & ';', lazy{params} ) {|p, ps|
			p.merge(ps) {|key, old, new|
				if @cardinality1[:PARAM].include?(key)
						parse_err("Violated cardinality of parameter #{key}")
				end
				[old,  new].flatten
				# deal with duplicate properties
			}
		} |  seq(';'.r >> param ).map {|e| e[0] }

    contentline = seq(linegroup._?, C::NAME_VCARD, params._?, ':', 
		      C::VALUE, /(\r|\n|\r\n)/) {|group, name, params, _, value, _|
			key =  name.upcase.gsub(/-/,"_").to_sym
			hash = { key => {} }
			hash[key][:value] = Typegrammars.typematch(self.strict, key, params[0], :GENERIC, value, @ctx)
			hash[key][:group] = group[0]  unless group.empty?
			Paramcheck.paramcheck(key, params.empty? ? {} : params[0], @ctx)
			hash[key][:params] = params[0] unless params.empty?
			hash
		}
        props	=  seq(contentline, lazy{props}) {|c, rest|
			c.merge( rest ) { | key, old, new|
				if @cardinality1[:PROP].include?(key.upcase) 
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
				# deal with duplicate properties
			}
			} | (''.r & beginend).map {|e|
			 	{}   
			}

	calpropname = /VERSION/i.r 
	calprop     = seq(linegroup._?, calpropname, ':', C::VALUE, 	/[\r\n]/) {|group, key, _, value, _|
	    		key = key.upcase.gsub(/-/,"_").to_sym
	    		hash = { key => {} }
			hash[key][:value] = Typegrammars.typematch(self.strict, key, nil, :VCARD, value, @ctx)
			hash[key][:group] = group[0]  unless group.empty?
			hash
	}
    vobject 	= seq(linegroup._?, /BEGIN:VCARD[\r\n]/i.r, calprop, props, linegroup._?, /END:VCARD[\r\n]/i.r) { |(g, b, v, rest, g1, e)|
	    		# TODO what do we do with the groups here?
			parse_err("Missing VERSION attribute") unless v.has_key?(:VERSION)
			parse_err("Missing FN attribute") unless rest.has_key?(:FN)
			parse_err("Missing N attribute") unless rest.has_key?(:N)
			rest.delete(:END)
	            	hash = { :VCARD => v.merge( rest ) }
		        hash
		}
    vobject.eof 
  end 

    def initialize(strict)
	              self.strict = strict
		                self.errors = []
  end


  def parse(vobject)
	@ctx = Rsec::ParseContext.new self.class.unfold(vobject), 'source'
	ret = vobjectGrammar._parse @ctx
	if !ret or Rsec::INVALID[ret] 
	        if self.strict
	      raise @ctx.generate_error 'source'
		else
			self.errors << @ctx.generate_error('source')
			              end
        end
	Rsec::Fail.reset
	        if self.strict
		                return ret
		else
		                return {:vobject => ret, :errors => self.errors}
 	       end

  end

private

   def parse_err(msg)
	   if self.strict
	          raise @ctx.report_error msg, 'source'
 	   else
		   self.errors << @ctx.report_error(msg, 'source')
	   end
   end

  end
end
