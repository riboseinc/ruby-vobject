require "rsec"
require "set"
require "uri"
require "date"
require "tzinfo"
include Rsec::Helpers
require_relative "../../c"
require_relative "../../error"
require 'vobject'

module Vobject::Vcalendar
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
        when :TODO
            case key
            when :DTSTAMP, :UID, :DTSTART, :CLASS, :CREATED, :DESCRIPTION,
            :GEO, :LAST_MOD, :LOCATION, :ORGANIZER, :PRIORITY, :PERCENT_COMPLETED, :SEQUENCE, :STATUS,
            :SUMMARY, :URL, :RECURRENCE_ID, :RRULE, :DUE, :DURATION,
            :ATTACH, :ATTENDEE, :CATEGORIES, :COMMENT, :CONTACT, :EXDATE,
            :RSTATUS, :RELATED, :RESOURCES, :RDATE, :COLOR, :CONFERENCE, :IMAGE
            else
                        raise ctx1.report_error "Invalid property #{key} specified for #{component}", 'source'
            end
        when :JOURNAL
            case key
            when :DTSTAMP, :UID, :DTSTART, :CLASS, :CREATED, :DESCRIPTION,
            :LAST_MOD, :ORGANIZER, :RECURRENCE_ID, :SEQUENCE, :STATUS,
            :SUMMARY, :URL, :RRULE, 
            :ATTACH, :ATTENDEE, :CATEGORIES, :COMMENT, :CONTACT, :EXDATE,
            :RSTATUS, :RELATED,  :RDATE, :COLOR, :IMAGE
            else
                        raise ctx1.report_error "Invalid property #{key} specified for #{component}", 'source'
            end
        when :FREEBUSY
            case key
            when :DTSTAMP, :UID, :CONTACT, :DTSTART, :DTEND, :ORGANIZER, :URL,
            :ATTENDEE, :COMMENT, :FREEBUSY, :RSTATUS
            else
                        raise ctx1.report_error "Invalid property #{key} specified for #{component}", 'source'
            end
        when :TIMEZONE
            case key
            when :TZID, :LAST_MODIFIED, :TZURL
            else
                        raise ctx1.report_error "Invalid property #{key} specified for #{component}", 'source'
            end
        when :DAYLIGHT, :STANDARD
            case key
            when :DTSTART, :TZOFFSETTO, :TZOFFSETFROM, :RRULE,
            :COMMENT, :RDATE, :TZNAME
            else
                        raise ctx1.report_error "Invalid property #{key} specified for #{component}", 'source'
            end
        when :ALARM
            case key
            when :ACTION, :TRIGGER, :DURATION, :REPEAT, :ATTACH, :DESCRIPTION,
            :SUMMARY, :ATTENDEE
            else
                        raise ctx1.report_error "Invalid property #{key} specified for #{component}", 'source'
            end
        when :VAVAILABILITY
            case key
            when :DTSTAMP, :UID, :BUSYTYPE, :CLASS, :CREATED, :DESCRIPTION,
            :DTSTART, :LAST_MODIFIED, :LOCATION, :ORGANIZER, :PRIORITY, :SEQUENCE,
            :SUMMARY, :URL, :DTEND, :DURATION, :CATEGORIES, :COMMENT, :CONTACT
            else
                        raise ctx1.report_error "Invalid property #{key} specified for #{component}", 'source'
            end
        when :AVAILABLE
            case key
            when :DTSTAMP, :DTSTART, :UID, :DTEND, :DURATION, :CREATED,
            :DESCRIPTION, :LAST_MODIFIED, :LOCATION, :RECURRENCE_ID, :RRULE,
            :SUMMARY, :CATEGORIES, :COMMENT, :CONTACT, :EXDATE, :RDATE
            else
                        raise ctx1.report_error "Invalid property #{key} specified for #{component}", 'source'
            end
        end
    end    
  end



  end
end
end
