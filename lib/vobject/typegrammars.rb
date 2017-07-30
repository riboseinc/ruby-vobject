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
	    		h = {:ordwk => o}
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
	    		h = {:ordmoday => o}
			h[:sign] = s[0] unless s.empty?
			h
	    	}
    bymodaylist = seq(monthdaynum, ',', lazy{bymodaylist}) {|m, _, l|
	    		[m, l].flatten
		} | monthdaynum.map {|m| m}
    ordyrday 	= /[0-9]{1,3}/.r
    yeardaynum	= seq(C::SIGN._?, ordyrday) {|s, o|
	    		h = {:ordyrday => o}
			h[:sign] = s[0] unless s.empty?
			h
	    	}
    byyrdaylist = seq(yeardaynum, ',', lazy{byyrdaylist}) {|y, _, l|
	    		[y, l].flatten
		} | yeardaynum.map {|y| y}
    weeknum 	= seq(C::SIGN._?, ordwk) {|s, o|
	    		h = {:ordwk => o}
			h[:sign] = s[0] unless s.empty?
			h
	    	}
    bywknolist 	= seq(weeknum, ',', lazy{bywknolist}) {|w, _, l|
	    		[w, l].flatten
		} | weeknum.map {|w| w}
    #monthnum 	= /[0-9]{1,2}/.r
    # RFC 7529 add leap month indicator
    monthnum 	= /[0-9]{1,2}L?/i.r
    bymolist 	= seq(monthnum, ',', lazy{bymolist}) {|m, _, l|
	    		[m, l].flatten
		} | monthnum.map {|m| m}
    setposday	= yeardaynum
    bysplist 	= seq(setposday, ',', lazy{bysplist}) {|s, _, l|
	    		[s, l].flatten
		} | setposday.map {|s| s}
    # http://www.unicode.org/repos/cldr/tags/latest/common/bcp47/calendar.xml
    rscale	= C::XNAME | /buddhist/i.r | /chinese/i.r | /coptic/i.r | /dangi/i.r |
	    	/ethioaa/i.r | /ethiopic-amete-alem/i.r | /ethiopic/i.r |
		/gregory/i.r | /hebrew/i.r | /indian/i.r | /islamic/i.r |
		/islamic-umalqura/i.r | /islamic-tbla/i.r | /islamic-civil/i.r |
		/islamic-rgsa/i.r | /iso8601/i.r | /japanese/i.r | /persian/i.r |
		/roc/i.r | /islamicc/i.r | /gregorian/i.r
    skip	= /OMIT/i.r | /BACKWARD/i.r | /FORWARD/i.r
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
	    seq(/WKST/i.r, '=', weekday)  {|k, _, v| {:wkst => v} } |
	    # RFC 7529
	    seq(/RSCALE/i.r, '=', rscale)  {|k, _, v| {:rscale => v} } | 
	    seq(/SKIP/i.r, '=', skip)  {|k, _, v| {:skip => v} } 
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
    text	= C::TEXT.map {|t| unescape t }
    text.eof
  end

  def textlist
    textlist	=  
	    	seq(C::TEXT, ','.r, lazy{textlist}) { |a, _, b| [unescape(a), b].flatten }  | 
		C::TEXT.map {|t| [unescape(t)]}
    textlist.eof
  end

  def request_statusvalue
	    @req_status = Set.new %w{2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 2.10 2.11 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 3.10 3.11 3.12 3.13 3.14 4.0 5.0 5.1 5.2 5.3}
    extdata = seq(';'.r, C::TEXT) {|_, t| t}
    request_statusvalue = seq(/[0-9](\.[0-9]){1,2}/.r, ';'.r, C::TEXT, extdata._?) {|n, _, t1, t2|
			    parse_err("Invalid request status #{n}") unless @req_status.include?(n) #RFC 5546   			
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
	    		period.map {|p| [p] } 
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

  # RFC 5546
  def methodvalue
	  methodvalue 	= /PUBLISH/i.r | /REQUEST/i.r | /REPLY/i.r | /ADD/i.r | /CANCEL/i.r | /REFRESH/i.r | 
		  	/COUNTER/i.r | /DECLINECOUNTER/i.r
	  methodvalue.eof
  end

  # RFC 7953
  def busytype
	  busytype = /BUSY-UNAVAILABLE/i.r | /BUSY-TENTATIVE/i.r | /BUSY/i.r |  C::IANATOKEN | C::XNAME
	  busytype.eof
  end

  # https://www.w3.org/TR/2011/REC-css3-color-20110607/#svg-color
  def color
	  color = /AliceBlue/i.r | /AntiqueWhite/i.r | /Aqua/i.r | /Aquamarine/i.r | /Azure/i.r | /Beige/i.r | 
		  /Bisque/i.r | /Black/i.r | /BlanchedAlmond/i.r | /Blue/i.r | /BlueViolet/i.r | /Brown/i.r | 
		  /BurlyWood/i.r | /CadetBlue/i.r | /Chartreuse/i.r | /Chocolate/i.r | /Coral/i.r | 
		  /CornflowerBlue/i.r | /Cornsilk/i.r | /Crimson/i.r | /Cyan/i.r | /DarkBlue/i.r | 
		  /DarkCyan/i.r | /DarkGoldenRod/i.r | /DarkGray/i.r | /DarkGrey/i.r | /DarkGreen/i.r | 
		  /DarkKhaki/i.r | /DarkMagenta/i.r | /DarkOliveGreen/i.r | /DarkOrange/i.r | /DarkOrchid/i.r | 
		  /DarkRed/i.r | /DarkSalmon/i.r | /DarkSeaGreen/i.r | /DarkSlateBlue/i.r | /DarkSlateGray/i.r | 
		  /DarkSlateGrey/i.r | /DarkTurquoise/i.r | /DarkViolet/i.r | /DeepPink/i.r | /DeepSkyBlue/i.r | 
		  /DimGray/i.r | /DimGrey/i.r | /DodgerBlue/i.r | /FireBrick/i.r | /FloralWhite/i.r | /ForestGreen/i.r | 
		  /Fuchsia/i.r | /Gainsboro/i.r | /GhostWhite/i.r | /Gold/i.r | /GoldenRod/i.r | /Gray/i.r | /Grey/i.r | 
		  /Green/i.r | /GreenYellow/i.r | /HoneyDew/i.r | /HotPink/i.r | /IndianRed/i.r | /Indigo/i.r | 
		  /Ivory/i.r | /Khaki/i.r | /Lavender/i.r | /LavenderBlush/i.r | /LawnGreen/i.r | /LemonChiffon/i.r | 
		  /LightBlue/i.r | /LightCoral/i.r | /LightCyan/i.r | /LightGoldenRodYellow/i.r | /LightGray/i.r | 
		  /LightGrey/i.r | /LightGreen/i.r | /LightPink/i.r | /LightSalmon/i.r | /LightSeaGreen/i.r | 
		  /LightSkyBlue/i.r | /LightSlateGray/i.r | /LightSlateGrey/i.r | /LightSteelBlue/i.r | 
		  /LightYellow/i.r | /Lime/i.r | /LimeGreen/i.r | /Linen/i.r | /Magenta/i.r | /Maroon/i.r | 
		  /MediumAquaMarine/i.r | /MediumBlue/i.r | /MediumOrchid/i.r | /MediumPurple/i.r | 
		  /MediumSeaGreen/i.r | /MediumSlateBlue/i.r | /MediumSpringGreen/i.r | /MediumTurquoise/i.r | 
		  /MediumVioletRed/i.r | /MidnightBlue/i.r | /MintCream/i.r | /MistyRose/i.r | /Moccasin/i.r | 
		  /NavajoWhite/i.r | /Navy/i.r | /OldLace/i.r | /Olive/i.r | /OliveDrab/i.r | /Orange/i.r | 
		  /OrangeRed/i.r | /Orchid/i.r | /PaleGoldenRod/i.r | /PaleGreen/i.r | /PaleTurquoise/i.r | 
		  /PaleVioletRed/i.r | /PapayaWhip/i.r | /PeachPuff/i.r | /Peru/i.r | /Pink/i.r | /Plum/i.r | 
		  /PowderBlue/i.r | /Purple/i.r | /RebeccaPurple/i.r | /Red/i.r | /RosyBrown/i.r | /RoyalBlue/i.r | 
		  /SaddleBrown/i.r | /Salmon/i.r | /SandyBrown/i.r | /SeaGreen/i.r | /SeaShell/i.r | /Sienna/i.r | 
		  /Silver/i.r | /SkyBlue/i.r | /SlateBlue/i.r | /SlateGray/i.r | /SlateGrey/i.r | /Snow/i.r | 
		  /SpringGreen/i.r | /SteelBlue/i.r | /Tan/i.r | /Teal/i.r | /Thistle/i.r | /Tomato/i.r | 
		  /Turquoise/i.r | /Violet/i.r | /Wheat/i.r | /White/i.r | /WhiteSmoke/i.r | /Yellow/i.r | /YellowGreen/i.r 
	  color.eof
  end


  # text escapes: \\ \; \, \N \n
  def unescape(x)
	  x.gsub(/\\\\/, '\\').gsub(/\\;/, ';').gsub(/\\,/, ',').gsub(/\\[Nn]/, "\n")
  end
  
  def registered_propname
    registered_propname = C::NAME
    registered_propname.eof
  end
  

  # Enforce type restrictions on values of particular properties.
  # If successful, return typed interpretation of string
  def typematch(key, params, component, value)
    ctx1 = Rsec::ParseContext.new value, 'source'
    if not (key =~ /^x/i)
        case component
        when :EVENT
            case key
            when :DTSTAMP, :UID, :DTSTART, :CLASS, :CREATED, :DESCRIPTION,
            :GEO, :LAST_MOD, :LOCATION, :ORGANIZER, :PRIORITY, :SEQUENCE, :STATUS,
            :SUMMARY, :TRANSP, :URL, :RECURRENCE_ID, :RRULE, :DTEND, :DURATION,
            :ATTACH, :ATTENDEE, :CATEGORIES, :COMMENT, :CONTACT, :EXDATE,
            :RSTATUS, :RELATED, :RESOURCES, :RDATE, :COLOR, :CONFERENCE, :IMAGE
            else
                    p = registered_propname.parse(key.to_s)
                    if Rsec::INVALID[p]
                    else
                        raise ctx1.report_error "Invalid property #{key} specified for #{component}", 'source'
                    end
            end
        when :TODO
            case key
            when :DTSTAMP, :UID, :DTSTART, :CLASS, :CREATED, :DESCRIPTION,
            :GEO, :LAST_MOD, :LOCATION, :ORGANIZER, :PRIORITY, :PERCENT_COMPLETED, :SEQUENCE, :STATUS,
            :SUMMARY, :URL, :RECURRENCE_ID, :RRULE, :DUE, :DURATION,
            :ATTACH, :ATTENDEE, :CATEGORIES, :COMMENT, :CONTACT, :EXDATE,
            :RSTATUS, :RELATED, :RESOURCES, :RDATE, :COLOR, :CONFERENCE, :IMAGE
            else
                    p = registered_propname.parse(key.to_s)
                    if Rsec::INVALID[p]
                    else
                        raise ctx1.report_error "Invalid property #{key} specified for #{component}", 'source'
                    end
            end
        when :JOURNAL
            case key
            when :DTSTAMP, :UID, :DTSTART, :CLASS, :CREATED, :DESCRIPTION,
            :LAST_MOD, :ORGANIZER, :RECURRENCE_ID, :SEQUENCE, :STATUS,
            :SUMMARY, :URL, :RRULE, 
            :ATTACH, :ATTENDEE, :CATEGORIES, :COMMENT, :CONTACT, :EXDATE,
            :RSTATUS, :RELATED,  :RDATE, :COLOR, :IMAGE
            else
                    p = registered_propname.parse(key.to_s)
                    if Rsec::INVALID[p]
                    else
                        raise ctx1.report_error "Invalid property #{key} specified for #{component}", 'source'
                    end
            end
        when :FREEBUSY
            case key
            when :DTSTAMP, :UID, :CONTACT, :DTSTART, :DTEND, :ORGANIZER, :URL,
            :ATTENDEE, :COMMENT, :FREEBUSY, :RSTATUS
            else
                    p = registered_propname.parse(key.to_s)
                    if Rsec::INVALID[p]
                    else
                        raise ctx1.report_error "Invalid property #{key} specified for #{component}", 'source'
                    end
            end
        when :TIMEZONE
            case key
            when :TZID, :LAST_MODIFIED, :TZURL
            else
                    p = registered_propname.parse(key.to_s.to_s)
                    if Rsec::INVALID[p]
                    else
                        raise ctx1.report_error "Invalid property #{key} specified for #{component}", 'source'
                    end
            end
        when :DAYLIGHT, :STANDARD
            case key
            when :DTSTART, :TZOFFSETTO, :TZOFFSETFROM, :RRULE,
            :COMMENT, :RDATE, :TZNAME
            else
                    p = registered_propname.parse(key.to_s)
                    if Rsec::INVALID[p]
                    else
                        raise ctx1.report_error "Invalid property #{key} specified for #{component}", 'source'
                    end
            end
        when :ALARM
            case key
            when :ACTION, :TRIGGER, :DURATION, :REPEAT, :ATTACH, :DESCRIPTION,
            :SUMMARY, :ATTENDEE
            else
                    p = registered_propname.parse(key.to_s)
                    if Rsec::INVALID[p]
                    else
                        raise ctx1.report_error "Invalid property #{key} specified for #{component}", 'source'
                    end
            end
        when :VAVAILABILITY
            case key
            when :DTSTAMP, :UID, :BUSYTYPE, :CLASS, :CREATED, :DESCRIPTION,
            :DTSTART, :LAST_MODIFIED, :LOCATION, :ORGANIZER, :PRIORITY, :SEQUENCE,
            :SUMMARY, :URL, :DTEND, :DURATION, :CATEGORIES, :COMMENT, :CONTACT
            else
                    p = registered_propname.parse(key.to_s)
                    if Rsec::INVALID[p]
                    else
                        raise ctx1.report_error "Invalid property #{key} specified for #{component}", 'source'
                    end
            end
        when :AVAILABLE
            case key
            when :DTSTAMP, :DTSTART, :UID, :DTEND, :DURATION, :CREATED,
            :DESCRIPTION, :LAST_MODIFIED, :LOCATION, :RECURRENCE_ID, :RRULE,
            :SUMMARY, :CATEGORIES, :COMMENT, :CONTACT, :EXDATE, :RDATE
            else
                    p = registered_propname.parse(key.to_s)
                    if Rsec::INVALID[p]
                    else
                        raise ctx1.report_error "Invalid property #{key} specified for #{component}", 'source'
                    end
                end
        end
    end    
    
    case key
    when :CALSCALE
	    ret = calscalevalue._parse ctx1
    when :METHOD
	    ret = methodvalue._parse ctx1
    when :VERSION
	    ret = versionvalue._parse ctx1
    when :ATTACH
	    if params[:VALUE] == 'BINARY'
		    ret = binary._parse ctx1
	    else
		    ret = uri._parse ctx1
	    end
    when :IMAGE
	raise ctx1.report_error "No VALUE parameter specified for property #{key}", 'source' if params.empty?
	raise ctx1.report_error "No VALUE parameter specified for property #{key}", 'source' unless params[:VALUE]
	    if params[:VALUE] == 'BINARY'
		raise ctx1.report_error "No ENCODING parameter specified for property #{key}", 'source' unless params[:ENCODING]
		raise ctx1.report_error "Incorrect ENCODING parameter specified for property #{key}", 'source' unless params[:ENCODING] == 'BASE64'
		    ret = binary._parse ctx1
	    elsif params[:VALUE] == 'URI'
		    ret = uri._parse ctx1
	    else
	raise ctx1.report_error "Incorrect VALUE parameter specified for property #{key}", 'source' 
	    end
    when :CATEGORIES, :RESOURCES
	    ret = textlist._parse ctx1
    when :CLASS
	    ret = classvalue._parse ctx1
    when :COMMENT, :DESCRIPTION, :LOCATION, :SUMMARY, :TZID, :TZNAME, :CONTACT, :RELATED_TO, :UID, :PRODID, :NAME
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
	    if (key == :DTEND or key == :DTSTART) and (component == :VAVAILABILITY or component == :AVAILABLE)
	    		ret = date_timeT._parse ctx1
	    elsif params and params[:VALUE] == 'DATE'
	    	ret = dateT._parse ctx1
	    else
		if component == :FREEBUSY
	    		ret = date_time_utcT._parse ctx1
		else
			if params and params[:TZID]
				if component == :STANDARD or component == :DAYLIGHT
					raise ctx1.report_error "Specified TZID within property #{key} in #{component}", 'source'
				end
				begin
					tz = TZInfo::Timezone.get(params[:TZID])
	    				ret = date_time_utcT._parse ctx1
					ret = tz.utc_to_local(ret)
				rescue
					# undefined timezone
	    				ret = date_time_utcT._parse ctx1
				end
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
	when :TZURI, :URL, :SOURCE, :CONFERENCE
	    if key == :CONFERENCE
		    raise ctx1.report_error "Missing URI VALUE parameter" if params.empty?
		    raise ctx1.report_error "Missing URI VALUE parameter" if !params[:VALUE]
		raise ctx1.report_error "Type mismatch of VALUE parameter #{params[:VALUE]} for property #{key}" if params[:VALUE]  != 'URI'
	    end
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
	# RFC 7953
	when :BUSYTYPE
		ret = busytype._parse ctx1
	# RFC 7986
	when :REFRESH_INTERVAL
		raise ctx1.report_error "Missing VALUE parameter for property #{key}" if params.empty?
		raise ctx1.report_error "Missing VALUE parameter for property #{key}" if !params[:VALUE] 
		raise ctx1.report_error "Type mismatch of VALUE parameter #{params[:VALUE]} for property #{key}" if params[:VALUE]  != 'DURATION'
		ret = durationT._parse ctx1
	# RFC 7986
	when :COLOR
		ret = color._parse ctx1
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
			ret = timeT._parse ctx1
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
  
     def paramcheck(prop, params) 
	   if params and params[:ALTREP]
		   case prop
		   when :COMMENT, :DESCRIPTION, :LOCATION, :RESOURCES, :SUMMARY, :CONTACT, :NAME, :IMAGE
		   else
                   	parse_err(":ALTREP parameter given for #{prop}") 
		   end
	   end
	   if params and params[:CN]
		   case prop
		   when  :ATTENDEE, :ORGANIZER
		   else
                   	parse_err(":CN parameter given for #{prop}") 
		   end
	   end
	   if params and params[:CUTYPE]
		   case prop
		   when :ATTENDEE
		   else
                   	parse_err(":CUTYPE parameter given for #{prop}") 
		   end
	   end
	   if params and params[:DELEGATED_FROM]
		   case prop
		   when   :ATTENDEE
		   else
                   	parse_err(":DELEGATED_FROM parameter given for #{prop}") 
		   end
	   end
	   if params and params[:DELEGATED_TO]
		   case prop
		   when   :ATTENDEE
		   else
                   	parse_err(":DELEGATED_TO parameter given for #{prop}") 
		   end
	   end
	   if params and params[:DIR]
		   case prop
		   when  :ATTENDEE, :ORGANIZER
		   else
                   	parse_err(":DIR parameter given for #{prop}") 
		   end
	   end
	   if params and params[:ENCODING]
		   case prop
		   when :ATTACH, :IMAGE  
		   else
                   	parse_err(":ENCODING parameter given for #{prop}") 
		   end
	   end
	   if params and params[:FMTTYPE]
		   case prop
		   when  :ATTACH, :IMAGE
		   else
                   	parse_err(":FMTTYPE parameter given for #{prop}") 
		   end
	   end
	   if params and params[:FBTYPE]
		   case prop
		   when  :FREEBUSY
		   else
                   	parse_err(":FBTYPE parameter given for #{prop}") 
		   end
	   end
	   if params and params[:LANGUAGE]
		   case prop
		   when  :CATEGORIES, :COMMENT, :DESCRIPTION, :LOCATION, :RESOURCES, 
		   :SUMMARY, :TZNAME,  :ATTENDEE, :CONTACT, :ORGANIZER, :REQUEST_STATUS,
		   :NAME, :CONFERENCE
		   else
                   	parse_err(":LANGUAGE parameter given for #{prop}") 
		   end
	   end
	   if params and params[:MEMBER]
		   case prop
		   when   :ATTENDEE
		   else
                   	parse_err(":MEMBER parameter given for #{prop}") 
		   end
	   end
	   if params and params[:PARTSTAT]
		   case prop
		   when  :ATTENDEE 
		   else
                   	parse_err(":PARTSTAT parameter given for #{prop}") 
		   end
	   end
	   if params and params[:RANGE]
		   case prop
		   when  :RECURRENCE_ID
		   else
                   	parse_err(":RANGE parameter given for #{prop}") 
		   end
	   end
	   if params and params[:RELATED]
		   case prop
		   when :TRIGGER 
		   else
                   	parse_err(":RELATED parameter given for #{prop}") 
		   end
	   end
	   if params and params[:RELTYPE]
		   case prop
		   when :RELATED_TO
		   else
                   	parse_err(":RELTYPE parameter given for #{prop}") 
		   end
	   end
	   if params and params[:ROLE]
		   case prop
		   when  :ATTENDEE
		   else
                   	parse_err(":ROLE parameter given for #{prop}") 
		   end
	   end
	   if params and params[:RSVP]
		   case prop
		   when  :ATTENDEE
		   else
                   	parse_err(":RSVP parameter given for #{prop}") 
		   end
	   end
	   if params and params[:SENT_BY]
		   case prop
		   when  :ATTENDEE, :ORGANIZER
		   else
                   	parse_err(":SENT_BY parameter given for #{prop}") 
		   end
	   end
	   if params and params[:TZID]
		   case prop
		   when :DTEND, :DUE, :DTSTART, :RECURRENCE_ID, :EXDATE, :RDATE
		   else
                   	parse_err(":TZID parameter given for #{prop}") 
		   end
	   end
	   if params and params[:DISPLAY]
		   case prop
		   when  :IMAGE
		   else
                   	parse_err(":DISPLAY parameter given for #{prop}") 
		   end
	   end
	   if params and params[:FEATURE]
		   case prop
		   when  :CONFERENCE
		   else
                   	parse_err(":FEATURE parameter given for #{prop}") 
		   end
	   end
	   if params and params[:LABEL]
		   case prop
		   when  :CONFERENCE
		   else
                   	parse_err(":LABEL parameter given for #{prop}") 
		   end
	   end
	   if params and params[:EMAIL]
		   case prop
		   when  :ORGANIZER, :ATTENDEE
		   else
                   	parse_err(":EMAIL parameter given for #{prop}") 
		   end
	   end


           case prop
	           when :TZURL, :URL, :CONFERENCE, :SOURCE
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val.downcase != "uri"
	                   }
	           when :FREEBUSY
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val.downcase != "period"
	                   }
	           when :COMPLETED
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val.downcase != "date-time"
	                   }
	           when :PERCENT_COMPLETE, :PRIORITY, :REPEAT, :SEQUENCE
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val.downcase != "integer"
	                   }
	           when :DURATION, :REFRESH_INTERVAL
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val.downcase != "duration"
	                   }
	           when :GEO
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val.downcase != "float"
	                   }
	           when :CREATED, :DTSTAMP, :LAST_MODIFIED
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val.downcase != "date-time"
	                   }
	           when :CALSCALE, :METHOD, :PRODID, :VERSION, :CATEGORIES, :CLASS, :COMMENT, :DESCRIPTION, :LOCATION, :RESOURCES, :STATUS, :SUMMARY, :TRANSP, :TZID, :TZNAME, :CONTACT, :RELATED_TO, :UID, :ACTION, :REQUEST_STATUS, :COLOR, :NAME
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val.downcase != "text"
	                   }
	           when :DTEND, :DUE, :DTSTART, :RECURRENCE_ID, :EXDATE
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val.downcase != "date-time" and val.downcase != "date"
	                   }
	           when :RDATE
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val.downcase != "period" and val.downcase != "date" and val.downcase != "date-time" 
	                   }
	           when :RRULE
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val.downcase != "recur" 
	                   }
	           when :TZOFFSETFROM, :TZOFFSETTO
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val.downcase != "utc-offset"
	                   }
	           when :ATTENDEE, :ORGANIZER
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val.downcase != "cal-address"
	                   }
	           when :TRIGGER
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val.downcase != "duration" and val.downcase != "date-time"
	                   }
	           when :ATTACH, :IMAGE
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val.downcase != "uri" and val.downcase != "binary"
	                   }
		   else
		  end
    end



private

   def parse_err(msg)
	          raise @ctx.report_error msg, 'source'
   end

  end
end
end
