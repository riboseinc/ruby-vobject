require "rsec"
require "set"
require "uri"
require "date"
require "tzinfo"
include Rsec::Helpers
require_relative "../../../c"
require_relative "../../../error"
require 'vobject' 

module Vcard::V3_0
 class Typegrammars
        
    class << self
          
          
        
      
  # Ensure each property belongs to a legal component
  def property_parent(key, component, value, ctx1)
    if not (key =~ /^x/i) and is_registered_propname?(key.to_s)
        case component
        when :EVENT
            case key    
            when :DTSTAMP, :UID, :DTSTART, :CLASS, :CREATED, :DESCRIPTION,
            :GEO, :LAST_MOD, :LOCATION, :ORGANIZER, :PRIORITY, :SEQUENCE, :STATUS,
            :SUMMARY, :TRANSP, :URL, :RECURRENCE_ID, :RRULE, :DTEND, :DURATION,
            :ATTACH, :ATTENDEE, :CATEGORIES, :COMMENT, :CONTACT, :EXDATE,
            :RSTATUS, :RELATED, :RESOURCES, :RDATE, :COLOR, :CONFERENCE, :IMAGE
            else
                        raise ctx1.report_error "Invalid property #{key} specified for #{component}", 'source'
            end
        when :EVENT
            case key    
            when :DTSTAMP, :UID, :DTSTART, :CLASS, :CREATED, :DESCRIPTION,
            :GEO, :LAST_MOD, :LOCATION, :ORGANIZER, :PRIORITY, :SEQUENCE, :STATUS,
            :SUMMARY, :TRANSP, :URL, :RECURRENCE_ID, :RRULE, :DTEND, :DURATION,
            :ATTACH, :ATTENDEE, :CATEGORIES, :COMMENT, :CONTACT, :EXDATE,
            :RSTATUS, :RELATED, :RESOURCES, :RDATE, :COLOR, :CONFERENCE, :IMAGE
            else
                        raise ctx1.report_error "Invalid property #{key} specified for #{component}", 'source'
            end
        end
    end
  end



  end
end
end
