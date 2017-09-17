require "rsec"
require "set"
require "uri"
require "date"
include Rsec::Helpers
require 'vobject/vcard/version'
require 'vobject'
require_relative './propertyvalue'

module Vcard::V4_0
	class Typegrammars

 class << self

  # property value types, each defining their own parser

  def integer  
    integer 	= prim(:int32).map {|i| Vcard::V4_0::PropertyValue::Integer.new i }
    integer.eof
  end
  
  def floatT
    floatT 	    = prim(:double).map {|f| Vcard::V4_0::PropertyValue::Float.new f }
    floatT.eof
  end

  def ianaToken
    ianaToken 	= C::IANATOKEN.map {|x| Vcard::V4_0::PropertyValue::Ianatoken.new x}
    ianaToken.eof
  end 

  def versionvalue
     versionvalue = '4.0'.r.map {|v| Vcard::V4_0::PropertyValue::Version.new v} 
     versionvalue.eof
  end

  def uri
	uri         = /\S+/.r.map {|s|
	                  	s =~ URI::regexp ? Vcard::V4_0::PropertyValue::Uri.new(s) : 
					{:error => 'Invalid URI'}
			 }
	uri.eof
  end

  def clientpidmap
	uri         = /\S+/.r.map {|s|
	                  	s =~ URI::regexp ? s : {:error => 'Invalid URI'}
			 }
	clientpidmap = seq(/[0-9]/.r, ';', uri) {|a, _, b|
		Vcard::V4_0::PropertyValue::Clientpidmap.new({:pid => a, :uri => b})
	}
	clientpidmap.eof
  end

  def textT
    textT	= C::TEXT4.map {|t| Vcard::V4_0::PropertyValue::Text.new(unescape t) }
    textT.eof
  end

  def textlist
    textlist1	= 
	    	seq(C::TEXT4, ',', lazy{textlist1}) { |a, b| [unescape(a), b].flatten } |
	    	C::TEXT4.map {|t| [unescape(t)]} 
    textlist    = textlist1.map {|m| Vcard::V4_0::PropertyValue::Textlist.new m }
    textlist.eof
  end

  def dateT
     dateT1	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
		    {:year => yy, :month => mm, :day => dd}
		} | seq(/[0-9]{4}/.r, "-", /[0-9]{2}/.r) {|yy, _, dd|
			{:year => yy, :day => dd }
        	} | /[0-9]{4}/.r {|yy|
			{:year => yy }
		} | seq('--', /[0-9]{2}/.r, /[0-9]{2}/.r) {|_, mm, dd|
		    {:month => mm, :day => dd}
		} | seq('--', /[0-9]{2}/.r) {|_, mm|
                    {:month => mm}
		} | seq('--', '-', /[0-9]{2}/.r) {|_, _, dd|
		    {:day => dd}
		}
     dateT	= dateT1.map {|d| Vcard::V4_0::PropertyValue::Date.new d }
     dateT.eof
  end

  def date_noreduc
     date_noreduc1	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
	     		{:year => yy, :month => mm, :day => dd}
		} | seq('--', /[0-9]{2}/.r, /[0-9]{2}/.r) {|_, mm, dd|
		        {:month => mm, :day => dd}
		} | seq('--', '-', /[0-9]{2}/.r) {|_, _, dd|
		        {:day => dd}
		}
     date_noreduc	= date_noreduc1.map {|d| Vcard::V4_0::PropertyValue::Date.new d }
     date_noreduc.eof
  end

  def date_complete
     date_complete1	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
            {:year => yy, :month => mm, :day => dd}
		}
     date_complete	= date_complete1.map {|d| Vcard::V4_0::PropertyValue::Date.new d }
     date_complete.eof
  end

  def timeT	
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    time1	= seq(hour, minute, second, C::ZONE._?) {|h, m, s, z|
                h = {:hour => h, :min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq(hour, minute, C::ZONE._?) {|h, m, z|
                h = {:hour => h, :min => m}
                h[:zone] = z[0] unless z.empty?
                h
            } |	seq(hour, C::ZONE._?) {|h, z|
                h = {:hour => h}
                h[:zone] = z[0] unless z.empty?
                h
            #} | seq('-', minute, second, C::ZONE._?) {|m, s, z|
            # errata: remove zones from truncated times
            } | seq('-', minute, second) {|m, s|
                h = {:min => m, :sec => s}
                h
            #} | seq('-', minute, C::ZONE._?) {|m, z|
            # errata: remove zones from truncated times
            } | seq('-', minute) {|m|
                h = {:min => m}
                h
            #} | seq('-', '-', second, C::ZONE._?) {|s, z|
            # errata: remove zones from truncated times
            } | seq('-', '-', second) {|s|
                h = {:sec => s}
                h
            }
    time 	= time1.map {|d| Vcard::V4_0::PropertyValue::Time.new d }
    time.eof
  end

  def time_notrunc
    time_notrunc1	= seq(hour, minute, second, C::ZONE._?) {|h, m, s, z|
                h = {:hour => h, :min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq(hour, minute, C::ZONE._?) {|h, m, z|
                h = {:hour => h, :min => m}
                h[:zone] = z[0] unless z.empty?
                h
	    	} | seq(hour, C::ZONE._?) {|h, z|
                h = {:hour => h}
                h[:zone] = z[0] unless z.empty?
                h
	    	}
    time_notrunc 	= time_notrunc1.map {|d| Vcard::V4_0::PropertyValue::Time.new d }
	time_notrunc.eof
  end

  def time_complete
    time_complete1	= seq(hour, minute, second, C::ZONE._?) {|h, m, s, z|
                h = {:hour => h, :min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            } 
    time_complete 	= time_complete1.map {|d| Vcard::V4_0::PropertyValue::Time.new d }
	time_complete.eof
  end

 def date_time
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    time_notrunc	= seq(hour, minute, second, C::ZONE._?) {|h, m, s, z|
                h = {:hour => h, :min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq(hour, minute, C::ZONE._?) {|h, m, z|
                h = {:hour => h, :min => m}
                h[:zone] = z[0] unless z.empty?
                h
	    	} | seq(hour, C::ZONE._?) {|h, z|
                h = {:hour => h}
                h[:zone] = z[0] unless z.empty?
                h
	    	}
     date_noreduc	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
            {:year => yy, :month => mm, :day => dd}
        } |
		seq('--', /[0-9]{2}/.r, /[0-9]{2}/.r) {|_, mm, dd|
		    {:month => mm, :day => dd}
		} | seq('--', '-', /[0-9]{2}/.r) {|_, _, dd|
		    {:day => dd}
		}
     date_time	= seq(date_noreduc, 'T', time_notrunc) {|d, _, t|
                d = d.merge t
		Vcard::V4_0::PropertyValue::DateTimeLocal.new d
	     	}
     date_time.eof
  end

  def timestamp
    date_complete	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
            {:year => yy, :month => mm, :day => dd}
		}
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    time_complete	= seq(hour, minute, second, C::ZONE._?) {|h, m, s, z|
                h = {:hour => h, :min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
    }
    timestamp 	= seq(date_complete, 'T', time_complete)  {|d, _, t|
		Vcard::V4_0::PropertyValue::DateTimeLocal.new(d.merge t)
	     	}
    timestamp.eof
  end

  def date_and_or_time
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    time_notrunc	= seq(hour, minute, second, C::ZONE._?) {|h, m, s, z|
                    h = {:hour => h, :min => m, :sec => s}
                    h[:zone] = z[0] unless z.empty?
                    h
            } | seq(hour, minute, C::ZONE._?) {|h, m, z|
                    h = {:hour => h, :min => m}
                    h[:zone] = z[0] unless z.empty?
                    h
            } | seq(hour, C::ZONE._?) {
                    h = {:hour => h}
                    h[:zone] = z[0] unless z.empty?
                    h
            }
     date_noreduc	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
	     		 {:year => yy, :month => mm, :day => dd}
		} | seq('--', /[0-9]{2}/.r, /[0-9]{2}/.r) {|_, mm, dd|
		         {:month => mm, :day => dd}
		} | seq('--', '-', /[0-9]{2}/.r) {|_, _, dd|
		         {:day => dd}
		}
     date_time	= seq(date_noreduc, 'T', time_notrunc) {|d, _, t|
                d.merge t
	     	}
     date	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
                {:year => yy, :month => mm, :day => dd}
		} | seq(/[0-9]{4}/.r, "-", /[0-9]{2}/.r) {|yy, _, dd|
                {:year => yy, :day => dd}
	     	} | /[0-9]{4}/.r {|yy|
                {:year => yy}
		} | seq('--', /[0-9]{2}/.r, /[0-9]{2}/.r) {|_, mm, dd|
                {:month => mm, :day => dd}
		} | seq('--', /[0-9]{2}/.r) {|_, mm|
                {:month => mm}
		} | seq('--', '-', /[0-9]{2}/.r) {|_, _, dd|
                {:day => dd}
		}
    time	= seq(hour, minute, second, C::ZONE._?) {|h, m, s, z|
                h = {:hour => h, :min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq(hour, minute, C::ZONE._?) {|h, m, z|
                h = {:hour => h, :min => m}
                h[:zone] = z[0] unless z.empty?
                h
            } |	seq(hour, C::ZONE._?) {|h, z|
                h = {:hour => h}
                h[:zone] = z[0] unless z.empty?
                h
            #} | seq('-', minute, second, C::ZONE._?) {|m, s, z|
            # errata: remove zones from truncated times
            } | seq('-', minute, second) {|m, s|
                h = {:min => m, :sec => s}
                h
            #} | seq('-', minute, C::ZONE._?) {|m, z|
            # errata: remove zones from truncated times
            } | seq('-', minute) {|m|
                h = {:min => m}
                h
            #} | seq('-', '-', second, C::ZONE._?) {|s, z|
            # errata: remove zones from truncated times
            } | seq('-', '-', second) {|s|
                h = {:sec => s}
                h
            }
     date_and_or_time = date_time.map {|d| Vcard::V4_0::PropertyValue::DateTimeLocal.new d} | 
	     date.map {|d| Vcard::V4_0::PropertyValue::Date.new d} | 
	     seq("T".r >> time).map {|t| Vcard::V4_0::PropertyValue::Time.new t }
     date_and_or_time.eof
  end
  
  def utc_offset
    utc_offset 	= C::UTC_OFFSET.map {|u| Vcard::V4_0::PropertyValue::Utcoffset.new u}
    utc_offset.eof
  end

  def kindvalue
	  kindvalue = (/individual/i.r | /group/i.r | /org/i.r | /location/i.r | /application/i.r
		  	C::IANATOKEN | C::XNAME_VCARD).map {|v| Vcard::V4_0::PropertyValue::Kindvalue.new v}
	  kindvalue.eof
  end

  def fivepartname
    #text	= /([ \t\u0021\u0023-\u002b\u002d-\u0039\u003c-\u005b\u005d-\u007e:"\u0080-\u00bf\u00c2-\u00df\u00e0\u00a0-\u00bf\u00e1-\u00ec\u00ed\u0080-\u009f\u00ee-\u00ef\u00f0\u0090-\u00bf\u00f1-\u00f3\u00f4\u0080-\u008f]|\\[;,\\nN])*/.r
    component	=  
	    	seq(C::COMPONENT4, ',', lazy{component}) {|a, _, b|
	    		[unescape_component(a), b].flatten
		} | C::COMPONENT4.map {|t| [unescape_component(t)] }
    fivepartname = seq(component, ';', component, ';', component, ';', 
		       component, ';', component) {|a, _, b, _, c, _, d, _, e|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		c = c[0] if c.length == 1
	    		d = d[0] if d.length == 1
	    		e = e[0] if e.length == 1
	    		Vcard::V4_0::PropertyValue::Fivepartname.new({:surname => a, :givenname => b, :additionalname => c, 
				:honprefix => d, :honsuffix => e})
	    	}
    fivepartname.eof
  end

  def address
    component	=  
	    	seq(C::COMPONENT4, ',', lazy{component}) {|a, _, b|
	    		[unescape_component(a), b].flatten
		} | C::COMPONENT4.map {|t| [unescape_component(t)] }
    address = seq(component, ';', component, ';', component, ';', component, ';', 
		       component, ';', component, ';', component) {|a, _, b, _, c, _, d, _, e, _, f, _, g|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		c = c[0] if c.length == 1
	    		d = d[0] if d.length == 1
	    		e = e[0] if e.length == 1
	    		f = f[0] if f.length == 1
	    		g = g[0] if g.length == 1
	    		Vcard::V4_0::PropertyValue::Address.new({:pobox => a, :ext => b, :street => c, 
				:locality => d, :region => e, :code => f, :country => g})
	    	}
    address.eof
  end

  def gender
	  gender1 = seq(/[MFONU]/.r._?, ';', C::TEXT4) {|sex, _, gender|
		  		sex = sex[0] unless sex.empty?
		  		{:sex => sex, :gender => gender}
			} | /[MFONU]/.r.map { |sex|
				{:sex => sex, :gender => ''}
			}
	  gender	= gender1.map{|g| Vcard::V4_0::PropertyValue::Gender.new g}
	  gender.eof
  end

   def org
       text        = C::COMPONENT4
       org1 =
                 seq(text, ';', lazy{org1}) { |a, _, b| [unescape_component(a), b].flatten } |
                  text.map {|t| [unescape_component(t)]}
       org	= org1.map{|g| Vcard::V4_0::PropertyValue::Org.new g}
       org.eof
   end

   def lang 
	   lang = C::RFC5646LANGVALUE.map{|l| Vcard::V4_0::PropertyValue::Lang.new l}
   end

  def typeparamtel1list
    typeparamtel1	= /TEXT/i.r | /VOICE/i.r | /FAX/i.r | /CELL/i.r | /VIDEO/i.r |
	    		/PAGER/i.r | /TEXTPHONE/i.r | C::IANATOKEN | C::XNAME_VCARD
    typeparamtel1list = seq(typeparamtel1, ",", lazy{typeparamtel1list}) {|a, _, b|
	    			[a, b].flatten
			} | typeparamtel1.map {|t| [t] } 
    typeparamtel1list.eof
  end

  def typerelatedlist
      typeparamrelated    = /CONTACT/i.r | /ACQUAINTANCE/i.r | /FRIEND/i.r | /MET/i.r |
                              /CO-WORKER/i.r | /COLLEAGUE/i.r | /CO-RESIDENT/i.r | /NEIGHBOR/i.r |
                              /CHILD/i.r | /PARENT/i.r | /SIBLING/i.r | /SPOUSE/i.r | /KIN/i.r |
                              /MUSE/i.r | /CRUSH/i.r | /DATE/i.r | /SWEETHEART/i.r | /ME/i.r |
                              /AGENT/i.r | /EMERGENCY/i.r
      typerelatedlist	= seq(typeparamrelated, ';', lazy{typerelatedlist}) {|a, _, b|
	      			[a, b].flatten
			} | typeparamrelated.map {|t| [t] } 
      typerelatedlist.eof
  end

    # text escapes: \\ \; \, \N \n
    def unescape(x)
        # temporarily escape \\ as \007f, which is disallowed in any text
        x.gsub(/\\\\/, "\u007f").gsub(/\\,/, ',').gsub(/\\[Nn]/, "\n").gsub(/\u007f/, "\\")
    end
    # also escape semicolon for compound types
    def unescape_component(x)
        # temporarily escape \\ as \007f, which is disallowed in any text
        x.gsub(/\\\\/, "\u007f").gsub(/\\;/, ';').gsub(/\\,/, ',').gsub(/\\[Nn]/, "\n").gsub(/\u007f/, "\\")
    end
 

  # Enforce type restrictions on values of particular properties.
  # If successful, return typed interpretation of string
  def typematch(key, params, component, value)
    ctx1 = Rsec::ParseContext.new value, 'source'
    case key
     when :VERSION
	    ret = versionvalue._parse ctx1
     when :SOURCE, :PHOTO, :IMPP, :GEO, :LOGO, :MEMBER, :SOUND, :URL, :FBURL, :CALADRURI, :CALURI, :ORG_DIRECTORY
	    ret = uri._parse ctx1
     when :KIND
	    ret = kindvalue._parse ctx1
     when :XML, :FN, :EMAIL, :TITLE, :ROLE, :NOTE, :EXPERTISE, :HOBBY, :INTEREST
	    ret = textT._parse ctx1
     when :NICKNAME, :CATEGORIES
	    ret = textlist._parse ctx1
     when :ORG
	    ret = org._parse ctx1
     when :N
	    ret = fivepartname._parse ctx1
     when :ADR
	    ret = address._parse ctx1
    when :BDAY, :ANNIVERSARY
	    if params and params[:VALUE] == 'text'
		    if params[:CALSCALE]
		        raise ctx1.report_error "Specified CALSCALE within property #{key} as text", 'source'
		    end
		    ret = textT._parse ctx1
	    else
		    if params and params[:CALSCALE] and /^T/ =~ value
		        raise ctx1.report_error "Specified CALSCALE within property #{key} as time", 'source'
		    end
		    ret = date_and_or_time._parse ctx1
	    end
    when :DEATHDATE
	    if params and params[:VALUE] == 'text'
		    ret = textT._parse ctx1
	    else
		    ret = date_and_or_time._parse ctx1
	    end
    when :TEL
	    if params and params[:TYPE]
		    typestr = params[:TYPE].kind_of?(Array) ? params[:TYPE].join(',') : params[:TYPE]
		    ret1 = typeparamtel1list.parse typestr
		    if !ret1 or Rsec::INVALID[ret1]
	      		raise ctx1.report_error "Specified illegal TYPE parameter #{typestr} within property #{key}", 'source'
		    end
	    end
	    if params and params[:VALUE] == 'uri'
		    ret = uri._parse ctx1
	    else
		    ret = textT._parse ctx1
	    end
     when :BIRTHPLACE, :DEATHPLACE
	    if params and params[:VALUE] == 'uri'
		    ret = uri._parse ctx1
	    else
		    ret = textT._parse ctx1
	    end
     when :RELATED
	    if params and params[:TYPE]
		    typestr = params[:TYPE].kind_of?(Array) ? params[:TYPE].join(';') : params[:TYPE]
		    ret1 = typerelatedlist.parse typestr
		    if !ret1 or Rsec::INVALID[ret1]
	      		raise ctx1.report_error "Specified illegal TYPE parameter #{typestr} within property #{key}", 'source'
		    end
	    end
	    if params and params[:VALUE] == 'uri'
		    ret = uri._parse ctx1
	    else
		    ret = textT._parse ctx1
	    end
     when :UID, :KEY
	    if params and params[:VALUE] == 'text'
		    ret = textT._parse ctx1
	    else
		    ret = uri._parse ctx1
	    end
     when :GENDER
	    ret = gender._parse ctx1
     when :LANG
	    ret = lang._parse ctx1
     when :TZ
	     if params and params[:VALUE] == 'uri'
	    	ret = uri._parse ctx1
	     elsif params and params[:VALUE] == 'utc_offset'
	    	ret = utc_offset._parse ctx1
	     else
	    	ret = textT._parse ctx1
	     end
      when :REV
	      ret = timestamp._parse ctx1
     when :CLIENTPIDMAP
	     if params and params[:PID]
	      		raise @ctx.report_error "Specified PID parameter in CLIENTPIDMAP property", 'source'
	     end
	     ret = clientpidmap._parse ctx1
    else
	    # left completely open in spec
	    ret = Vobject::PropertyValue.new value
    end
    if ret.kind_of?(Hash) and ret[:error]
        raise ctx1.report_error "#{ret[:error]} for property #{key}, value #{value}", 'source'
    end
    if Rsec::INVALID[ret] 
        raise ctx1.report_error "Type mismatch for property #{key}, value #{value}", 'source'
    end
    return ret
  end



private


   def parse_err(msg, ctx)
	          raise ctx.report_error msg, 'source'
   end

  end
end
end
