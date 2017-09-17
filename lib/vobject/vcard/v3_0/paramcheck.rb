require "rsec"
require "set"
require "uri"
require "date"
#require "tzinfo"
include Rsec::Helpers
require 'vobject/vcard/version'
require 'vobject'

module Vcard::V3_0
	class Paramcheck

 class << self



  def paramcheck(prop, params, ctx) 
	if params and params[:TYPE]
		parse_err("multiple values for :TYPE parameter of #{prop}", ctx) if params[:TYPE].kind_of?(Array) and params[:TYPE].length > 1 and prop != :EMAIL and prop != :ADR and prop != :TEL and prop != :LABEL and prop != :IMPP
	end
	case prop
	when :NAME, :PROFILE, :GEO, :PRODID, :URL, :VERSION, :CLASS
		parse_err("illegal parameters #{params} given for #{prop}", ctx) unless params.empty?
	when :CALURI, :CAPURI, :CALADRURI, :FBURL
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}", ctx) unless key == :TYPE
			if params[:TYPE].kind_of?(Array)
				val.each {|v|
					parse_err("illegal parameter value #{v} given for parameter #{key} of #{prop}", ctx) unless v == "PREF"
				}
			else
				parse_err("illegal parameter value #{val} given for parameter #{key} of #{prop}", ctx) unless val == "PREF"
			end
		}
	when :SOURCE
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}", ctx) unless key == :VALUE or key == :CONTEXT or key =~ /^x/i
			parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val != "uri"
			parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :CONTEXT and val != "word"
		}
	when :FN, :N, :NICKNAME, :MAILER, :TITLE, :ROLE, :ORG, :CATEGORIES, :NOTE, :SORT_STRING
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}", ctx) unless key == :VALUE or key == :LANGUAGE or key =~ /^x/i
			parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val != "ptext"
		}
	when :TEL, :IMPP, :UID
		# UID included here per errata
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}", ctx) unless key == :TYPE
		}
		# we do not check the values of the :TEL :TYPE parameter, because they include ianaToken
	when :EMAIL
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}", ctx) unless key == :TYPE
		}
		# we do not check the values of the first :EMAIL :TYPE parameter, because they include ianaToken
=begin
		if params[:TYPE].length > 1
			parse_err("illegal second parameter #{params[:TYPE][1]} given for #{prop}", ctx) unless params[:TYPE][1] == 'PREF'
		end
=end
	when :ADR, :LABEL
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}", ctx) unless key == :VALUE or key == :LANGUAGE or key =~ /^x/i or key == :TYPE
			parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val != "ptext"
		}
		# we do not check the values of the :ADR :TYPE parameter, because they include ianaToken
	when :KEY
		params.each {|key, val|
			# VALUE included here per errata
			parse_err("illegal parameter #{key} given for #{prop}", ctx) unless key == :TYPE or key == :ENCODING or key == :VALUE
			parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val != "binary"
		}
		# we do not check the values of the :KEY :TYPE parameter, because they include ianaToken
	when :PHOTO, :LOGO, :SOUND
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}", ctx) unless key == :VALUE or key == :TYPE or key == :ENCODING
		}
		parse_err("illegal value #{params[:VALUE]} of :VALUE given for #{prop}", ctx) if params[:VALUE] and params[:VALUE] != "binary" and params[:VALUE] != "uri"
		parse_err("illegal value #{params[:ENCODING]} of :ENCODING given for #{prop}", ctx) if params[:ENCODING] and (params[:ENCODING] != "b" or params[:VALUE] == "uri")
		parse_err("mandatory parameter of :ENCODING missing for #{prop}", ctx) if !params.has_key?(:ENCODING) and (!params.key?(:VALUE) or params[:VALUE] == "binary")
		# TODO restriction of :TYPE to image types registered with IANA
		# TODO restriction of :TYPE to sound types registered with IANA
	when :BDAY, :REV
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}", ctx) unless key == :VALUE 
		}
		parse_err("illegal value #{params[:VALUE]} of :VALUE given for #{prop}", ctx) if params[:VALUE] and params[:VALUE] != "date" and params[:VALUE] != "date-time"
	when :AGENT
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}", ctx) unless key == :VALUE 
		}
		parse_err("illegal value #{params[:VALUE]} of :VALUE given for #{prop}", ctx) if params[:VALUE] and params[:VALUE] != "uri"
	when :TZ
		# example in definition contradicts spec! Spec says :TZ takes no params at all
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}", ctx) unless key == :VALUE 
		}
		parse_err("illegal value #{params[:VALUE]} of :VALUE given for #{prop}", ctx) if params[:VALUE] and params[:VALUE] != "text"
	else
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}", ctx) unless key == :VALUE or key == :LANGUAGE or key =~ /^x/i
			parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val != "ptext"
		}
	end
  end

private


   def parse_err(msg, ctx)
	          raise ctx.report_error msg, 'source'
   end

  end
end
end
