require "rsec"
require "set"
require "uri"
require "date"
require "tzinfo"
include Rsec::Helpers
require_relative "../c"
require_relative "../error"
require 'vobject'

module Vobject
 class Paramcheck

    class << self


  
  
     def paramcheck(prop, params, ctx) 
	   if params and params[:ALTREP]
		   case prop
		   when :COMMENT, :DESCRIPTION, :LOCATION, :RESOURCES, :SUMMARY, :CONTACT, :NAME, :IMAGE
		   else
                   	parse_err(":ALTREP parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:CN]
		   case prop
		   when  :ATTENDEE, :ORGANIZER
		   else
                   	parse_err(":CN parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:CUTYPE]
		   case prop
		   when :ATTENDEE
		   else
                   	parse_err(":CUTYPE parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:DELEGATED_FROM]
		   case prop
		   when   :ATTENDEE
		   else
                   	parse_err(":DELEGATED_FROM parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:DELEGATED_TO]
		   case prop
		   when   :ATTENDEE
		   else
                   	parse_err(":DELEGATED_TO parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:DIR]
		   case prop
		   when  :ATTENDEE, :ORGANIZER
		   else
                   	parse_err(":DIR parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:ENCODING]
		   case prop
		   when :ATTACH, :IMAGE  
		   else
                   	parse_err(":ENCODING parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:FMTTYPE]
		   case prop
		   when  :ATTACH, :IMAGE
		   else
                   	parse_err(":FMTTYPE parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:FBTYPE]
		   case prop
		   when  :FREEBUSY
		   else
                   	parse_err(":FBTYPE parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:LANGUAGE]
		   case prop
		   when  :CATEGORIES, :COMMENT, :DESCRIPTION, :LOCATION, :RESOURCES, 
		   :SUMMARY, :TZNAME,  :ATTENDEE, :CONTACT, :ORGANIZER, :REQUEST_STATUS,
		   :NAME, :CONFERENCE
		   else
                   	parse_err(":LANGUAGE parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:MEMBER]
		   case prop
		   when   :ATTENDEE
		   else
                   	parse_err(":MEMBER parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:PARTSTAT]
		   case prop
		   when  :ATTENDEE 
		   else
                   	parse_err(":PARTSTAT parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:RANGE]
		   case prop
		   when  :RECURRENCE_ID
		   else
                   	parse_err(":RANGE parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:RELATED]
		   case prop
		   when :TRIGGER 
		   else
                   	parse_err(":RELATED parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:RELTYPE]
		   case prop
		   when :RELATED_TO
		   else
                   	parse_err(":RELTYPE parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:ROLE]
		   case prop
		   when  :ATTENDEE
		   else
                   	parse_err(":ROLE parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:RSVP]
		   case prop
		   when  :ATTENDEE
		   else
                   	parse_err(":RSVP parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:SENT_BY]
		   case prop
		   when  :ATTENDEE, :ORGANIZER
		   else
                   	parse_err(":SENT_BY parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:TZID]
		   case prop
		   when :DTEND, :DUE, :DTSTART, :RECURRENCE_ID, :EXDATE, :RDATE
		   else
                   	parse_err(":TZID parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:DISPLAY]
		   case prop
		   when  :IMAGE
		   else
                   	parse_err(":DISPLAY parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:FEATURE]
		   case prop
		   when  :CONFERENCE
		   else
                   	parse_err(":FEATURE parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:LABEL]
		   case prop
		   when  :CONFERENCE
		   else
                   	parse_err(":LABEL parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:EMAIL]
		   case prop
		   when  :ORGANIZER, :ATTENDEE
		   else
                   	parse_err(":EMAIL parameter given for #{prop}", ctx) 
		   end
	   end


           case prop
	           when :TZURL, :URL, :CONFERENCE, :SOURCE
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val.downcase != "uri"
	                   }
	           when :FREEBUSY
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val.downcase != "period"
	                   }
	           when :COMPLETED
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val.downcase != "date-time"
	                   }
	           when :PERCENT_COMPLETE, :PRIORITY, :REPEAT, :SEQUENCE
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val.downcase != "integer"
	                   }
	           when :DURATION, :REFRESH_INTERVAL
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val.downcase != "duration"
	                   }
	           when :GEO
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val.downcase != "float"
	                   }
	           when :CREATED, :DTSTAMP, :LAST_MODIFIED
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val.downcase != "date-time"
	                   }
	           when :CALSCALE, :METHOD, :PRODID, :VERSION, :CATEGORIES, :CLASS, :COMMENT, :DESCRIPTION, :LOCATION, :RESOURCES, :STATUS, :SUMMARY, :TRANSP, :TZID, :TZNAME, :CONTACT, :RELATED_TO, :UID, :ACTION, :REQUEST_STATUS, :COLOR, :NAME
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val.downcase != "text"
	                   }
	           when :DTEND, :DUE, :DTSTART, :RECURRENCE_ID, :EXDATE
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val.downcase != "date-time" and val.downcase != "date"
	                   }
	           when :RDATE
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val.downcase != "period" and val.downcase != "date" and val.downcase != "date-time" 
	                   }
	           when :RRULE
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val.downcase != "recur" 
	                   }
	           when :TZOFFSETFROM, :TZOFFSETTO
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val.downcase != "utc-offset"
	                   }
	           when :ATTENDEE, :ORGANIZER
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val.downcase != "cal-address"
	                   }
	           when :TRIGGER
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val.downcase != "duration" and val.downcase != "date-time"
	                   }
	           when :ATTACH, :IMAGE
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val.downcase != "uri" and val.downcase != "binary"
	                   }
		   else
		  end
    end



private

   def parse_err(msg, ctx)
	          raise ctx.report_error msg, 'source'
   end

  end
end
end
