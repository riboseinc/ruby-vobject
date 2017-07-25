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
 class Typegrammars

    class << self


  # property value types, each defining their own parser
  def recur
    freq	= /SECONDLY/i.r | /MINUTELY/i.r | /HOURLY/i.r | /DAILY/i.r |
	    		/WEEKLY/i.r | /MONTHLY/i.r | /YEARLY/i.r
    enddate 	= C::DATE_TIME | C::DATE
    seconds 	= /[0-9]{1,2}/.r
    byseclist 	= seq(seconds, ',', lazy{byseclist}) {|s, _, l|
	    		[s, l].flatten
	    	} | seconds.map {|s| s}
    minutes 	= /[0-9]{1,2}/.r
    byminlist 	= seq(minutes, ',', lazy{byminlist}) {|m, _, l|
	    		[m, l].flatten
		} | minutes.map {|m| m}
    hours 	= /[0-9]{1,2}/.r
    byhrlist 	= seq(hours, ',', lazy{byhrlist}) {|h, _, l|
	    		[h, l].flatten
		} | hours.map {|h| h}
    ordwk 	= /[0-9]{1,2}/.r
    weekday 	= /SU/i.r | /MO/i.r | /TU/i.r | /WE/i.r | /TH/i.r | /FR/i.r | /SA/i.r
    weekdaynum1	= seq(C::SIGN._?, ordwk) {|s, o|
	    		h = {:ordwk => s}
			h[:sign] = s[0] unless s.empty?
			h
	    	}
    weekdaynum 	= seq(weekdaynum1._?, weekday) {|a, b|
	    		h = {:weekday => b}
			h.merge a[0] unless a.empty?
			h
	    	}
    bywdaylist 	= seq(weekdaynum, ',', lazy{bywdaylist}) {|w, _, l|
	    		[w, l].flatten
		} | weekdaynum.map {|w| w} 
    ordmoday 	= /[0-9]{1,2}/.r
    monthdaynum = seq(C::SIGN._?, ordmoday) {|s, o|
	    		h = {:ordmoday => s}
			h[:sign] = s[0] unless s.empty?
			h
	    	}
    bymodaylist = seq(monthdaynum, ',', lazy{bymodaylist}) {|m, _, l|
	    		[m, l].flatten
		} | monthdaynum.map {|m| m}
    ordyrday 	= /[0-9]{1,3}/.r
    yeardaynum	= seq(C::SIGN._?, ordyrday) {|s, o|
	    		h = {:ordyrday => s}
			h[:sign] = s[0] unless s.empty?
			h
	    	}
    byyrdaylist = seq(yeardaynum, ',', lazy{byyrdaylist}) {|y, _, l|
	    		[y, l].flatten
		} | yeardaynum.map {|y| y}
    weeknum 	= seq(C::SIGN._?, ordwk) {|s, o|
	    		h = {:ordwk => s}
			h[:sign] = s[0] unless s.empty?
			h
	    	}
    bywknolist 	= seq(weeknum, ',', lazy{bywknolist}) {|w, _, l|
	    		[w, l].flatten
		} | weeknum.map {|w| w}
    monthnum 	= /[0-9]{1,2}/.r
    bymolist 	= seq(monthnum, ',', lazy{bymolist}) {|m, _, l|
	    		[m, l].flatten
		} | monthnum.map {|m| m}
    setposday	= yeardaynum
    bysplist 	= seq(setposday, ',', lazy{bysplist}) {|s, _, l|
	    		[s, l].flatten
		} | setposday.map {|s| s}
    recur_rule_part = 	seq(/FREQ/i.r, '=', freq) {|k, _, v| {:freq => v} } |
	    seq(/UNTIL/i.r, '=', enddate) {|k, _, v| {:until => v} } |
	    seq(/COUNT/i.r, '=', /[0-9]+/i.r) {|k, _, v| {:count => v} } |
	    seq(/INTERVAL/i.r, '=', /[0-9]+/i.r) {|k, _, v| {:interval => v} } |
	    seq(/BYSECOND/i.r, '=', byseclist) {|k, _, v| {:bysecond => v} } |
	    seq(/BYMINUTE/i.r, '=', byminlist) {|k, _, v| {:byminute => v} } |
	    seq(/BYHOUR/i.r, '=', byhrlist) {|k, _, v| {:byhour => v} } |
	    seq(/BYDAY/i.r, '=', bywdaylist) {|k, _, v| {:byday => v} } |
	    seq(/BYMONTHDAY/i.r, '=', bymodaylist) {|k, _, v| {:bymonthday => v} } |
	    seq(/BYYEARDAY/i.r, '=', byyrdaylist) {|k, _, v| {:byyearday => v} } |
	    seq(/BYWEEKNO/i.r, '=', bywknolist)  {|k, _, v| {:byweekno => v} } |
	    seq(/BYMONTH/i.r, '=', bymolist)  {|k, _, v| {:bymonth => v} } |
	    seq(/BYSETPOS/i.r, '=', bysplist)  {|k, _, v| {:bysetpos => v} } |
	    seq(/WKST/i.r, '=', weekday)  {|k, _, v| {:wkst => v} } 
    recur 	= seq(recur_rule_part, ';', lazy{recur}) {|h, _, r| h.merge r } | 
	    	recur_rule_part
    recur.eof
  end

  def integer  
    integer 	= prim(:int32)
    integer.eof
  end
  
  def percent_complete  
    integer 	= prim(:int32) {|a|
	    		(a >= 0 and a <= 100) ? a :  {:error => 'Percentage outside of range 0..100'}
	    	}
    integer.eof
  end
  
  def priority  
    integer 	= prim(:int32) {|a|
	    		(a >= 0 and a <= 9) ? a :  {:error => 'Percentage outside of range 0..100'}
	    	}
    integer.eof
  end

  def floatT
	 floatT = prim(:double)
	 floatT.eof
  end

  def timeT
	  timeT = C::TIME
	  timeT.eof
  end
  
  def geovalue
    float 	    = prim(:double)
    # TODO confirm that Rsec can do signs!
    geovalue	= seq(float, ';', float) {|a, _, b|
	     ( a <= 180.0 and a >= -180.0 and b <= 180 and b > -180 ) ? {:lat => a, :long => b} :
			{:error => 'Latitude/Longitude outside of range -180..180'}
    }
    geovalue.eof
  end

  def calscalevalue
    calscalevalue = /GREGORIAN/i.r
    calscalevalue.eof
  end

  def ianaToken
    ianaToken 	= C::IANATOKEN 
    ianaToken.eof
  end 

  def versionvalue
     versionvalue = 
                    seq(prim(:double), ';', prim(:double)) {|x, _, y| [x, y] } |
	     		'2.0'.r | prim(:double) 
     versionvalue.eof
  end

  def binary
	binary	= seq(/[a-zA-Z0-9+\/]*/.r, /={0,2}/.r) {|b, q|
				( (b.length + q.length) % 4 == 0 ) ? b + q : {:error => 'Malformed binary coding'}
		}
	binary.eof
  end

  def uri
	uri         = /\S+/.r.map {|s|
	                  	s =~ URI::regexp ? s : {:error => 'Invalid URI'}
			 }
	uri.eof
  end

  def textT
    text	= C::TEXT
    text.eof
  end

  def textlist
    textlist	=  
	    	seq(C::TEXT, ','.r, lazy{textlist}) { |a, _, b| [a, b].flatten }  | 
		C::TEXT.map {|t| [t]}
    textlist.eof
  end

  def request_statusvalue
    extdata = seq(';'.r, C::TEXT) {|_, t| t}
    request_statusvalue = seq(/[0-9](\.[0-9]){1,2}/.r, ';'.r, C::TEXT, extdata._?) {|n, _, t1, t2|
                            hash = {:statcode => n, :statdesc => t1}
                            hash[:extdata] = t2[0] unless t2.empty?
                            hash
                        }
    request_statusvalue.eof
  end

  def classvalue
	classvalue = /PUBLIC/i.r | /PRIVATE/i.r | /CONFIDENTIAL/i.r | C::XNAME | C::IANATOKEN
	classvalue.eof
  end

  def eventstatus
	  eventstatus	= /TENTATIVE/i.r | /CONFIRMED/i.r | /CANCELLED/i.r
	  eventstatus.eof
  end

  def todostatus
	  todostatus	= /NEEDS-ACTION/i.r | /COMPLETED/i.r | /IN-PROCESS/i.r | /CANCELLED/i.r
	  todostatus.eof
  end

  def journalstatus
	  journalstatus	= /DRAFT/i.r | /FINAL/i.r | /CANCELLED/i.r
	  journalstatus.eof
  end

  def dateT
     date = C::DATE
     date.eof
  end

  def datelist
	 datelist   = 
		 seq(C::DATE, ",".r, lazy{datelist}) {|d, _, l|
	                [d, l].flatten
	            }  |
		 C::DATE.map {|d| [d] } 
     	datelist.eof
  end

  def date_timeT
     C::DATE_TIME.eof
  end

  def date_timelist
	 date_timelist   = 
			seq(C::DATE_TIME, ",".r, lazy{date_timelist}) {|d, _, l|
	                [d, l].flatten
	            } |
		 	C::DATE_TIME.map {|d| [d] }  
     date_timelist.eof
  end

  def date_time_utcT
     date_time_utc	= C::DATE_TIME_UTC
     date_time_utc.eof
  end
  
  def date_time_utclist
	 date_time_utclist   = seq(C::DATE_TIME_UTC, ",".r, lazy{date_time_utclist}) {|d, _, l|
	                [d, l].flatten
	            } |
		 C::DATE_TIME_UTC.map {|d| [d] } 
     date_time_utclist.eof
  end

  def durationT
    duration = C::DURATION
    duration.eof
  end
  
  def periodlist
    period_explicit = seq(C::DATE_TIME, "/".r, C::DATE_TIME) {|s, _, e|
                        {:start => s, :end => e}
                    }
    period_start    = seq(C::DATE_TIME, "/".r, C::DURATION) {|s, _, d|
                        {:start => s, :duration => d}
                    }
    period 	        = period_explicit | period_start
    periodlist      = seq(period, ",".r, lazy{periodlist}) {|p, _, l|
                        [p, l].flatten
                    } |
	    		period {|p| [p] } 
    periodlist.eof
  end
  
  def transpvalue
	  transpvalue	= /OPAQUE/i.r | /TRANSPARENT/i.r
	  transpvalue.eof
  end

  def utc_offset
    utc_offset 	= seq(C::SIGN, /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r._?) {|sign, h, m, sec|
	    		hash = {:sign => sign, :hr => h, :min => m }
			hash[:sec] = sec[0] unless sec.empty?
			hash
    		}
    utc_offset.eof
  end

  def actionvalue
	  actionvalue	= /AUDIO/i.r | /DISPLAY/i.r | /EMAIL/i.r | C::IANATOKEN | C::XNAME
	  actionvalue.eof
  end

  def boolean
	  boolean = C::BOOLEAN
	  boolean.eof
  end



  # Enforce type restrictions on values of particular properties.
  # If successful, return typed interpretation of string
  def typematch(key, params, component, value)
    ctx1 = Rsec::ParseContext.new value, 'source'
    case key
    when :CALSCALE
	    ret = calscalevalue._parse ctx1
    when :METHOD
	    ret = ianaToken._parse ctx1
    when :PRODID
	    ret = textT._parse ctx1
    when :VERSION
	    ret = versionvalue._parse ctx1
    when :ATTACH
	    if params[:VALUE] == 'BINARY'
		    ret = binary._parse ctx1
	    else
		    ret = uri._parse ctx1
	    end
    when :CATEGORIES, :RESOURCES
	    ret = textlist._parse ctx1
    when :CLASS
	    ret = classvalue._parse ctx1
    when :COMMENT, :DESCRIPTION, :LOCATION, :SUMMARY, :TZID, :TZNAME, :CONTACT, :RELATED_TO, :UID
	    ret = textT._parse ctx1
    when :GEO
	    ret = geovalue._parse ctx1
    when :PERCENT_COMPLETE
	    ret = percent_complete._parse ctx1
    when :PRIORITY
	    ret = priority._parse ctx1
    when :STATUS
	    case component 
	    when :EVENT
		    ret = eventstatus._parse ctx1
	    when :TODO
		    ret = todostatus._parse ctx1
	    when :JOURNAL
		    ret = journalstatus._parse ctx1
	    else
		    ret = textT._parse ctx1
	    end
    when :COMPLETED, :CREATED, :DTSTAMP, :LAST_MODIFIED
	    ret = date_time_utcT._parse ctx1
    when :DTEND, :DTSTART, :DUE, :RECURRENCE_ID
	    if params and params[:VALUE] == 'DATE'
	    	ret = dateT._parse ctx1
	    else
		if component == :FREEBUSY
	    		ret = date_time_utcT._parse ctx1
		else
			if params and params[:TZID]
				if component == :STANDARD or component == :DAYLIGHT
					raise ctx1.report_error "Specified TZID within property #{key} in #{component}", 'source'
				end
				tz = TZInfo::Timezone.get(params[:TZID])
	    			ret = date_time_utcT._parse ctx1
				ret = tz.utc_to_local(ret)
			else 
	    			ret = date_timeT._parse ctx1
			end
		end
	    end
    when :EXDATE
	    if params and params[:VALUE] == 'DATE'
	    	ret = datelist._parse ctx1
	    else
			if params and params[:TZID]
				if component == :STANDARD or component == :DAYLIGHT
					raise ctx1.report_error "Specified TZID within property #{key} in #{component}", 'source'
				end
				tz = TZInfo::Timezone.get(params[:TZID])
	    			ret = date_time_utclist._parse ctx1
				ret = ret.map {|x| tz.utc_to_local(x) }
			else 
	    			ret = date_timelist._parse ctx1
			end
		end
    when :RDATE
	    if params and params[:VALUE] == 'DATE'
	    	ret = datelist._parse ctx1
	    elsif params and params[:VALUE] == 'PERIOD'
	    	ret = periodlist._parse ctx1
	    else
			if params and params[:TZID]
				if component == :STANDARD or component == :DAYLIGHT
					raise ctx1.report_error "Specified TZID within property #{key} in #{component}", 'source'
				end
				tz = TZInfo::Timezone.get(params[:TZID])
	    			ret = date_time_utclist._parse ctx1
				ret = ret.map {|x| tz.utc_to_local(x) }
			else 
	    			ret = date_timelist._parse ctx1
			end
		end
    when :TRIGGER
	    if params and params[:VALUE] == 'DATE-TIME' or /^\d{8}T/.match(value)
	        if params and params[:RELATED]
				raise ctx1.report_error "Specified RELATED within property #{key} as date-time", 'source'	        
			end
	    	ret = date_time_utcT._parse ctx1
	    else
	    	ret = durationT._parse ctx1
		end
    when :FREEBUSY
	    ret = periodlist._parse ctx1
    when :TRANSP
	    ret = transpvalue._parse ctx1
    when :TZOFFSETFROM, :TZOFFSETTO
	    ret = utc_offset._parse ctx1
	when :TZURI, :URL
	    ret = uri._parse ctx1
	when :ATTENDEE, :ORGANIZER
	    ret = uri._parse ctx1
	when :RRULE
	    ret = recur._parse ctx1
	when :ACTION
	    ret = actionvalue._parse ctx1
	when :REPEAT, :SEQUENCE
	    ret = integer._parse ctx1
	when :REQUEST_STATUS
	    ret = request_statusvalue._parse ctx1
    else
	    if params and params[:VALUE]
		case params[:VALUE]
		when "BOOLEAN"
			ret = boolean._parse ctx1
		when "BINARY"
			ret = binary._parse ctx1
		when "CAL-ADDRESS"
			ret = uri._parse ctx1
		when "DATE-TIME"
			ret = date_timeT._parse ctx1
		when "DATE"
			ret = dateT._parse ctx1
		when "DURATION"
			ret = durationT._parse ctx1
		when "FLOAT"
			ret = floatT._parse ctx1
		when "INTEGER"
			ret = integer._parse ctx1
		when "PERIOD"
			ret = period._parse ctx1
		when "RECUR"
			ret = recur._parse ctx1
		when "TEXT"
			ret = textT._parse ctx1
		when "TIME"
			ret = time._parse ctx1
		when "URI"
			ret = uri._parse ctx1
		when "UTC-OFFSET"
			ret = utc_offset._parse ctx1
		end
	    else 
	        ret = value
	    end
    end
    if ret.kind_of?(Hash) and ret[:error]
	raise  "#{ret[:error]} for property #{key}, value #{value}"
    end
    if Rsec::INVALID[ret] 
        raise "Type mismatch for property #{key}, value #{value}"
    end
    Rsec::Fail.reset
    return ret
  end

private

   def parse_err(msg)
	          raise @ctx.report_error msg, 'source'
   end

  end
end
end
