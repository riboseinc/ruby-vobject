require "rsec"
require "set"
require "uri"
require "date"
require "tzinfo"
include Rsec::Helpers


 class Vobject::Typegrammars

  # property value types, each defining their own parser
  def recur
     date	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
	     		Time.utc(yy, mm, dd)
	     	}
     date_time	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, 'T', 
		  /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, /Z/i.r._?) {|yy, mm, dd, _, h, m, s, z|
	     		z.empty? ? Time.local(yy, mm, dd, h, m, s) : Time.utc(yy, mm, dd, h, m, s)
	     	}
    sign	= /[+-]/i.r
    freq	= /SECONDLY/i.r | /MINUTELY/i.r | /HOURLY/i.r | /DAILY/i.r |
	    		/WEEKLY/i.r | /MONTHLY/i.r | /YEARLY/i.r
    enddate 	= date | date_time
    seconds 	= /[0-9]{1,2}/.r
    byseclist 	= seconds | seq(seconds, ',', lazy{byseclist})
    minutes 	= /[0-9]{1,2}/.r
    byminlist 	= minutes | seq(minutes, ',', lazy{byminlist})
    hours 	= /[0-9]{1,2}/.r
    byhrlist 	= hours | seq(hours, ',', lazy{byhrlist})
    ordwk 	= /[0-9]{1,2}/.r
    weekday 	= /SU/i.r | /MO/i.r | /TU/i.r | /WE/i.r | /TH/i.r | /FR/i.r | /SA/i.r
    weekdaynum1	= seq(sign._?, ordwk)
    weekdaynum 	= seq(weekdaynum1._?, weekday)
    bywdaylist 	= weekdaynum | seq(weekdaynum, ',', lazy{bywdaylist})
    ordmoday 	= /[0-9]{1,2}/.r
    monthdaynum = seq(sign._?, ordmoday)
    bymodaylist = monthdaynum | seq(monthdaynum, ',', lazy{bymodaylist})
    ordyrday 	= /[0-9]{1,3}/.r
    yeardaynum	= seq(sign._?, ordyrday)
    byyrdaylist = yeardaynum | seq(yeardaynum, ',', lazy{byyrdaylist})
    weeknum 	= seq(sign._?, ordwk)
    bywknolist 	= weeknum | seq(weeknum, ',', lazy{bywknolist})
    monthnum 	= /[0-9]{1,2}/.r
    bymolist 	= monthnum | seq(monthnum, ',', lazy{bymolist})
    setposday	= yeardaynum
    bysplist 	= setposday | seq(setposday, ',', lazy{bysplist})
    recur_rule_part = 	seq(/FREQ/i.r, '=', freq) |
	    seq(/UNTIL/i.r, '=', enddate) |
	    seq(/COUNT/i.r, '=', /[0-9]+/i.r) |
	    seq(/INTERVAL/i.r, '=', /[0-9]+/i.r) |
	    seq(/BYSECOND/i.r, '=', byseclist) |
	    seq(/BYMINUTE/i.r, '=', byminlist) |
	    seq(/BYHOUR/i.r, '=', byhrlist) |
	    seq(/BYDAY/i.r, '=', bywdaylist) |
	    seq(/BYMONTHDAY/i.r, '=', bymodaylist) |
	    seq(/BYYEARDAY/i.r, '=', byyrdaylist) |
	    seq(/BYWEEKNO/i.r, '=', bywknolist) |
	    seq(/BYMONTH/i.r, '=', bymolist) |
	    seq(/BYSETPOS/i.r, '=', bysplist) |
	    seq(/WKST/i.r, '=', weekday) 
    recur 	= recur_rule_part | seq(recur_rule_part, ';', lazy{recur})
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
    ianaToken 	= /[a-zA-Z\d\-]+/.r 
    ianaToken.eof
  end 

  def versionvalue
     versionvalue = '2.0'.r | prim(:double) | 
                    seq(prim(:double), ';', prim(:double)) {|x, _, y| [x, y] }
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

  def text
    text	= /([ \t\u0021\u0023-\u002b\u002d-\u0039\u003c-\u005b\u005d-\u007e:"\u0080-\u00bf\u00c2-\u00df\u00e0\u00a0-\u00bf\u00e1-\u00ec\u00ed\u0080-\u009f\u00ee-\u00ef\u00f0\u0090-\u00bf\u00f1-\u00f3\u00f4\u0080-\u008f]|\\[;,\\nN])*/.r
    text.eof
  end

  def textlist
    text	= /([ \t\u0021\u0023-\u002b\u002d-\u0039\u003c-\u005b\u005d-\u007e:"\u0080-\u00bf\u00c2-\u00df\u00e0\u00a0-\u00bf\u00e1-\u00ec\u00ed\u0080-\u009f\u00ee-\u00ef\u00f0\u0090-\u00bf\u00f1-\u00f3\u00f4\u0080-\u008f]|\\[;,\\nN])*/.r
    textlist	= text.map {|t| [t]} | 
	    	seq(text, ',', lazy{textlist}) { |a, b| [a, b].flatten }
    textlist.eof
  end

  def request_statusvalue
    text	= /([ \t\u0021\u0023-\u002b\u002d-\u0039\u003c-\u005b\u005d-\u007e:"\u0080-\u00bf\u00c2-\u00df\u00e0\u00a0-\u00bf\u00e1-\u00ec\u00ed\u0080-\u009f\u00ee-\u00ef\u00f0\u0090-\u00bf\u00f1-\u00f3\u00f4\u0080-\u008f]|\\[;,\\nN])*/.r
    extdata = seq(';'.r, text) {|_, t| t}
    request_statusvalue = seq(/[0-9](\.[0-9]){1,2}/.r, ';', text, extdata._?) {|n, t1, t2|
                            hash = {:statcode => n, :statdesc => t1}
                            hash[:extdata] = t2[0] unless t2.empty?
                            hash
                        }
    request_statusvalue.eof
  end

  def classvalue
    	ianaToken 	= /[a-zA-Z\d\-]+/.r 
    	vendorid	= /[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]/.r
    	xname 	= seq( '[xX]-', vendorid, '-', ianaToken)
	classvalue = /PUBLIC/i.r | /PRIVATE/i.r | /CONFIDENTIAL/i.r |
		  	xname | ianaToken
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

  def date
     date	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
	     		Time.utc(yy, mm, dd)
	     	}
     date.eof
  end

  def datelist
     date	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
	     		Time.utc(yy, mm, dd)
	     	}
	 datelist   = date.map {|d| 
	                [d] 
	            } | seq(date, ",", lazy{datelist}) {|d, _, l|
	                [d, l].flatten
	            }
     datelist.eof
  end

  def date_time
     date_time	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, 'T', 
		  /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, /Z/i.r._?) {|yy, mm, dd, _, h, m, s, z|
	     		z.empty? ? Time.local(yy, mm, dd, h, m, s) : Time.utc(yy, mm, dd, h, m, s)
	     	}
     date_time.eof
  end

  def date_timelist
     date_time	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, 'T', 
		  /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, /Z/i.r._?) {|yy, mm, dd, _, h, m, s, z|
	     		z.empty? ? Time.local(yy, mm, dd, h, m, s) : Time.utc(yy, mm, dd, h, m, s)
	     	}
	 date_timelist   = date_time.map {|d| 
	                [d] 
	            } | seq(date_time, ",", lazy{date_timelist}) {|d, _, l|
	                [d, l].flatten
	            }
     date_timelist.eof
  end

  def date_time_utc
     date_time_utc	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, 'T', 
		  /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, /Z/i.r._?) {|yy, mm, dd, _, h, m, s, z|
	     		Time.utc(yy, mm, dd, h, m, s)
	     	}
     date_time_utc.eof
  end
  
  def date_time_utclist
     date_time_utc	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, 'T', 
		  /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, /Z/i.r._?) {|yy, mm, dd, _, h, m, s, z|
	     		z.empty? ? Time.local(yy, mm, dd, h, m, s) : Time.utc(yy, mm, dd, h, m, s)
	     	}
	 date_time_utclist   = date_time_utc.map {|d| 
	                [d] 
	            } | seq(date_time_utc, ",", lazy{date_time_utclist}) {|d, _, l|
	                [d, l].flatten
	            }
     date_time_utclist.eof
  end

  def duration
    sign	= /[+-]/i.r
    durday	= seq(/[0-9]+/.r, 'D')
    dursecond	= seq(/[0-9]+/.r, 'S')
    durminute	= seq(/[0-9]+/.r, 'M', dursecond._?)
    durhour	= seq(/[0-9]+/.r, 'H', durminute._?)
    durweek	= seq(/[0-9]+/.r, 'W')
    durtime1	= durhour | durminute | dursecond
    durtime	= seq('T', durtime1)
    durdate	= seq(durday, durtime._?)
    duration1	= durdate | durtime | durweek
    duration 	= seq(sign._?, 'P', duration1)
    duration.eof
  end
  
  def periodlist
    date_time	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, 'T', 
		  /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r, /Z/i.r._?) {|yy, mm, dd, _, h, m, s, z|
	     		z.empty? ? Time.local(yy, mm, dd, h, m, s) : Time.utc(yy, mm, dd, h, m, s)
	     	}
    sign	= /[+-]/i.r
    durday	= seq(/[0-9]+/.r, 'D')
    dursecond	= seq(/[0-9]+/.r, 'S')
    durminute	= seq(/[0-9]+/.r, 'M', dursecond._?)
    durhour	= seq(/[0-9]+/.r, 'H', durminute._?)
    durweek	= seq(/[0-9]+/.r, 'W')
    durtime1	= durhour | durminute | dursecond
    durtime	= seq('T', durtime1)
    durdate	= seq(durday, durtime._?)
    duration1	= durdate | durtime | durweek
    duration 	= seq(sign._?, 'P', duration1)


    period_explicit = seq(date_time, "/", date_time) {|s, _, e|
                        {:start => s, :end => e}
                    }
    period_start    = seq(date_time, "/", duration) {|s, _, d|
                        {:start => s, :duration => d}
                    }
    period 	        = period_explicit | period_start
    periodlist      = period {|p| 
                        [p] 
                    } | seq(period, ",", lazy{periodlist}) {|p, _, l|
                        [p, l].flatten
                    }
    periodlist.eof
  end
  
  def transpvalue
	  transpvalue	= /OPAQUE/i.r | /TRANSPARENT/i.r
	  transpvalue.eof
  end

  def utc_offset
    sign	    = /[+-]/i.r
    utc_offset 	= seq(sign, /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r._?)
    utc_offset.eof
  end

  def actionvalue
    	ianaToken 	= /[a-zA-Z\d\-]+/.r 
    	vendorid	= /[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]/.r
    	xname 	= seq( '[xX]-', vendorid, '-', ianaToken)
	  actionvalue	= /AUDIO/i.r | /DISPLAY/i.r | /EMAIL/i.r | ianaToken | xname
	  actionvalue.eof
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
	    ret = text._parse ctx1
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
	    ret = text._parse ctx1
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
		    ret = text._parse ctx1
	    end
    when :COMPLETED, :CREATED, :DTSTAMP, :LAST_MODIFIED
	    ret = date_time_utc._parse ctx1
    when :DTEND, :DTSTART, :DUE, :RECURRENCE_ID
	    if params and params[:VALUE] == 'DATE'
	    	ret = date._parse ctx1
	    else
		if component == :FREEBUSY
	    		ret = date_time_utc._parse ctx1
		else
			if params and params[:TZID]
			    puts "TZID"
				if component == :STANDARD or component == :DAYLIGHT
					STDERR.puts "Specified TZID within property #{key} in #{component}"
					raise ctx1.generate_error 'source'
				end
				tz = TZInfo::Timezone.get(params[:TZID])
	    			ret = date_time_utc._parse ctx1
				ret = tz.utc_to_local(ret)
			else 
	    			ret = date_time._parse ctx1
			end
		end
	    end
    when :EXDATE
	    if params and params[:VALUE] == 'DATE'
	    	ret = datelist._parse ctx1
	    else
			if params and params[:TZID]
			    puts "TZID"
				if component == :STANDARD or component == :DAYLIGHT
					STDERR.puts "Specified TZID within property #{key} in #{component}"
					raise ctx1.generate_error 'source'
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
			    puts "TZID"
				if component == :STANDARD or component == :DAYLIGHT
					STDERR.puts "Specified TZID within property #{key} in #{component}"
					raise ctx1.generate_error 'source'
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
                STDERR.puts "Specified RELATED within property #{key} as date-time"
				raise ctx1.generate_error 'source'	        
			end
	    	ret = date_time_utc._parse ctx1
	    else
	    	ret = duration._parse ctx1
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
	    ret = value
    end
    if ret.kind_of?(Hash) and ret[:error]
	STDERR.puts "#{ret[:error]} for property #{key}, value #{value}"
        raise ctx1.generate_error 'source'
    end
    if Rsec::INVALID[ret] 
	STDERR.puts "Type mismatch for property #{key}, value #{value}"
        raise ctx1.generate_error 'source'
    end
    return ret
  end

private

   def parse_err(msg)
	   	  STDERR.puts msg
	          raise @ctx.generate_error 'source'
   end

  end
