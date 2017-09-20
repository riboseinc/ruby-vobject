require "rsec"
require "set"
require "uri"
require "date"
require "tzinfo"
include Rsec::Helpers
require_relative "../../c"
require_relative "../../error"

module Vobject::Vcalendar
  class Paramcheck
    class << self
      def paramcheck(strict, prop, params, ctx)
        errors = []
        if params && params[:ALTREP]
          case prop
          when :COMMENT, :DESCRIPTION, :LOCATION, :RESOURCES, :SUMMARY,
            :CONTACT, :NAME, :IMAGE
          else
            parse_err(strict, errors, "(:ALTREP parameter given for #{prop}", ctx)
          end
        end
        if params && params[:CN]
          case prop
          when :ATTENDEE, :ORGANIZER
          else
            parse_err(strict, errors, "(:CN parameter given for #{prop}", ctx)
          end
        end
        if params && params[:CUTYPE]
          case prop
          when :ATTENDEE
          else
            parse_err(strict, errors, "(:CUTYPE parameter given for #{prop}", ctx)
          end
        end
        if params && params[:DELEGATED_FROM]
          case prop
          when :ATTENDEE
          else
            parse_err(strict, errors, "(:DELEGATED_FROM parameter given for #{prop}", ctx)
          end
        end
        if params && params[:DELEGATED_TO]
          case prop
          when :ATTENDEE
          else
            parse_err(strict, errors, "(:DELEGATED_TO parameter given for #{prop}", ctx)
          end
        end
        if params && params[:DIR]
          case prop
          when :ATTENDEE, :ORGANIZER
          else
            parse_err(strict, errors, "(:DIR parameter given for #{prop}", ctx)
          end
        end
        if params && params[:ENCODING]
          case prop
          when :ATTACH, :IMAGE 
          else
            parse_err(strict, errors, "(:ENCODING parameter given for #{prop}", ctx)
          end
        end
        if params && params[:FMTTYPE]
          case prop
          when :ATTACH, :IMAGE
          else
            parse_err(strict, errors, "(:FMTTYPE parameter given for #{prop}", ctx)
          end
        end
        if params && params[:FBTYPE]
          case prop
          when :FREEBUSY
          else
            parse_err(strict, errors, "(:FBTYPE parameter given for #{prop}", ctx)
          end
        end
        if params && params[:LANGUAGE]
          case prop
          when :CATEGORIES, :COMMENT, :DESCRIPTION, :LOCATION, :RESOURCES,
            :SUMMARY, :TZNAME, :ATTENDEE, :CONTACT, :ORGANIZER, :REQUEST_STATUS,
            :NAME, :CONFERENCE
          else
            parse_err(strict, errors, "(:LANGUAGE parameter given for #{prop}", ctx)
          end
        end
        if params && params[:MEMBER]
          case prop
          when :ATTENDEE
          else
            parse_err(strict, errors, "(:MEMBER parameter given for #{prop}", ctx)
          end
        end
        if params && params[:PARTSTAT]
          case prop
          when :ATTENDEE
          else
            parse_err(strict, errors, "(:PARTSTAT parameter given for #{prop}", ctx)
          end
        end
        if params && params[:RANGE]
          case prop
          when :RECURRENCE_ID
          else
            parse_err(strict, errors, "(:RANGE parameter given for #{prop}", ctx)
          end
        end
        if params && params[:RELATED]
          case prop
          when :TRIGGER
          else
            parse_err(strict, errors, "(:RELATED parameter given for #{prop}", ctx)
          end
        end
        if params && params[:RELTYPE]
          case prop
          when :RELATED_TO
          else
            parse_err(strict, errors, "(:RELTYPE parameter given for #{prop}", ctx)
          end
        end
        if params && params[:ROLE]
          case prop
          when :ATTENDEE
          else
            parse_err(strict, errors, "(:ROLE parameter given for #{prop}", ctx)
          end
        end
        if params && params[:RSVP]
          case prop
          when :ATTENDEE
          else
            parse_err(strict, errors, "(:RSVP parameter given for #{prop}", ctx)
          end
        end
        if params && params[:SENT_BY]
          case prop
          when :ATTENDEE, :ORGANIZER
          else
            parse_err(strict, errors, "(:SENT_BY parameter given for #{prop}", ctx)
          end
        end
        if params && params[:TZID]
          case prop
          when :DTEND, :DUE, :DTSTART, :RECURRENCE_ID, :EXDATE, :RDATE
          else
            parse_err(strict, errors, "(:TZID parameter given for #{prop}", ctx)
          end
        end
        if params && params[:DISPLAY]
          case prop
          when :IMAGE
          else
            parse_err(strict, errors, "(:DISPLAY parameter given for #{prop}", ctx)
          end
        end
        if params && params[:FEATURE]
          case prop
          when :CONFERENCE
          else
            parse_err(strict, errors, "(:FEATURE parameter given for #{prop}", ctx)
          end
        end
        if params && params[:LABEL]
          case prop
          when :CONFERENCE
          else
            parse_err(strict, errors, "(:LABEL parameter given for #{prop}", ctx)
          end
        end
        if params && params[:EMAIL]
          case prop
          when :ORGANIZER, :ATTENDEE
          else
            parse_err(strict, errors, "(:EMAIL parameter given for #{prop}", ctx)
          end
        end

        case prop
        when :TZURL, :URL, :CONFERENCE, :SOURCE
          params.each do |key, val|
            parse_err(strict, errors, "(illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE && val.casecmp("uri") != 0
          end
        when :FREEBUSY
          params.each do |key, val|
            parse_err(strict, errors, "(illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE && val.casecmp("period") != 0
          end
        when :COMPLETED
          params.each do |key, val|
            parse_err(strict, errors, "(illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE && val.casecmp("date-time") != 0
          end
        when :PERCENT_COMPLETE, :PRIORITY, :REPEAT, :SEQUENCE
          params.each do |key, val|
            parse_err(strict, errors, "(illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE && val.casecmp("integer") != 0
          end
        when :DURATION, :REFRESH_INTERVAL
          params.each do |key, val|
            parse_err(strict, errors, "(illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE && val.casecmp("duration") != 0
          end
        when :GEO
          params.each do |key, val|
            parse_err(strict, errors, "(illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE && val.casecmp("float") != 0
          end
        when :CREATED, :DTSTAMP, :LAST_MODIFIED
          params.each do |key, val|
            parse_err(strict, errors, "(illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE && val.casecmp("date-time") != 0
          end
        when :CALSCALE, :METHOD, :PRODID, :VERSION, :CATEGORIES, :CLASS,
          :COMMENT, :DESCRIPTION, :LOCATION, :RESOURCES, :STATUS, :SUMMARY,
          :TRANSP, :TZID, :TZNAME, :CONTACT, :RELATED_TO, :UID, :ACTION,
          :REQUEST_STATUS, :COLOR, :NAME
          params.each do |key, val|
            parse_err(strict, errors, "(illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE && val.casecmp("text") != 0
          end
        when :DTEND, :DUE, :DTSTART, :RECURRENCE_ID, :EXDATE
          params.each do |key, val|
            parse_err(strict, errors, "(illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE && val.casecmp("date-time") != 0 && val.casecmp("date") != 0
          end
        when :RDATE
          params.each do |key, val|
            parse_err(strict, errors, "(illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE && val.casecmp("period") != 0 && val.casecmp("date") != 0 && val.casecmp("date-time") != 0
          end
        when :RRULE
          params.each do |key, val|
            parse_err(strict, errors, "(illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE && val.casecmp("recur") != 0
          end
        when :TZOFFSETFROM, :TZOFFSETTO
          params.each do |key, val|
            parse_err(strict, errors, "(illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE && val.casecmp("utc-offset") != 0
          end
        when :ATTENDEE, :ORGANIZER
          params.each do |key, val|
            parse_err(strict, errors, "(illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE && val.casecmp("cal-address") != 0
          end
        when :TRIGGER
          params.each do |key, val|
            parse_err(strict, errors, "(illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE && val.casecmp("duration") != 0 && val.casecmp("date-time") != 0
          end
        when :ATTACH, :IMAGE
          params.each do |key, val|
            parse_err(strict, errors, "(illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE && val.casecmp("uri") != 0 && val.casecmp("binary") != 0
          end
        end
        errors
      end

      private

      def parse_err(strict, errors, msg, ctx)
        if strict
          raise ctx.report_error msg, "source"
        else
          errors << ctx.report_error(msg, "source")
        end
      end
    end
  end
end
