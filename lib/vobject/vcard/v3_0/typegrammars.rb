require "rsec"
require "set"
require "uri"
require "date"
#require "tzinfo"
include Rsec::Helpers
require 'vobject/vcard/version'
require_relative "./propertyparent"
require 'vobject'
require_relative './propertyvalue'

module Vcard::V3_0
	class Typegrammars

 class << self

  # property value types, each defining their own parser

    def binary
           binary  = seq(/[a-zA-Z0-9+\/]*/.r, /={0,2}/.r) {|b, q|
                   ( (b.length + q.length) % 4 == 0 ) ? Vcard::V3_0::PropertyValue::Binary.new(b + q) 
		   : {:error => 'Malformed binary coding'}
                   }
            binary.eof
    end

  def phoneNumber 
	  # This is on the lax side; there should be up to 15 digits
	  # Will allow letters
	  phoneNumber = /[0-9() +A-Z-]+/i.r.map {|p| Vcard::V3_0::PropertyValue::Phonenumber.new p}
	  phoneNumber.eof
  end

    def geovalue
	        float           = prim(:double)
		geovalue    = seq(float, ';', float) {|a, _, b|
		              ( a <= 180.0 and a >= -180.0 and b <= 180 and b > -180 ) ? 
				      Vcard::V3_0::PropertyValue::Geovalue.new({:lat => a, :long => b}) :
		                                       {:error => 'Latitude/Longitude outside of range -180..180'}
		                                             }
	                                                  geovalue.eof
    end
		

  def classvalue  
    ianaToken 	= /[a-zA-Z\d\-]+/.r 
    xname 	= seq( '[xX]-', /[a-zA-Z0-9-]+/.r).map(&:join)
    classvalue 	= (/PUBLIC/i.r | /PRIVATE/i.r | /CONFIDENTIAL/i.r | ianaToken | xname).map {|m|
    		Vcard::V3_0::PropertyValue::ClassValue.new m }
    classvalue.eof
  end
  
  def integer  
    integer 	= prim(:int32).map {|i| Vcard::V3_0::PropertyValue::Integer.new i }
    integer.eof
  end
  
  def floatT
    floatT 	    = prim(:double).map {|f| Vcard::V3_0::PropertyValue::Float.new f }
    floatT.eof
  end

  def ianaToken
    ianaToken 	= /[a-zA-Z\d\-]+/.r.map {|x| Vcard::V3_0::PropertyValue::Ianatoken.new x }
    ianaToken.eof
  end 

  def versionvalue
     versionvalue = '3.0'.r.map {|v| Vcard::V3_0::PropertyValue::Version.new v}
     versionvalue.eof
  end

  def profilevalue
     profilevalue = /VCARD/i.r.map {|v| Vcard::V3_0::PropertyValue::Profilevalue.new v}
     profilevalue.eof
  end

  def uri
	uri         = /\S+/.r.map {|s|
	                  	s =~ URI::regexp ? Vcard::V3_0::PropertyValue::Uri.new(s) : 
					{:error => 'Invalid URI'}
			 }
	uri.eof
  end

  def textT
    textT	= C::TEXT3.map {|t| Vcard::V3_0::PropertyValue::Text.new(unescape t) }
    textT.eof
  end

  def textlist
    text	= C::TEXT3
    textlist1	= 
	    	seq(text << ','.r, lazy{textlist1}) { |a, b| [unescape(a), b].flatten } |
	    	text.map {|t| [unescape(t)]}
    textlist	= textlist1.map {|m| Vcard::V3_0::PropertyValue::Textlist.new m }
    textlist.eof
  end

  def org
    text	= C::TEXT3
    org1	= 
	    	seq(text, ';', lazy{org1}) { |a, _, b| [unescape(a), b].flatten } |
	    	text.map {|t| [unescape(t)]}
    org		= org1.map {|o| Vcard::V3_0::PropertyValue::Org.new o }
    org.eof
  end

  def dateT
     dateT	= seq(/[0-9]{4}/.r, /-/.r._?, /[0-9]{2}/.r, /-/.r._?, /[0-9]{2}/.r) {|yy, _, mm, _, dd|
		    Vcard::V3_0::PropertyValue::Date.new({:year => yy, :month => mm, :day => dd})
        } 
     dateT.eof
  end

  def timeT	
    utc_offset 	= seq(C::SIGN, /[0-9]{2}/.r, /:/.r._?, /[0-9]{2}/.r) {|s, h, _, m|
                    {:sign => s, :hour => h, :min => m}
                }
    zone	= utc_offset.map {|u| u  } | 
                    /Z/i.r.map {|z| 'Z' }
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    secfrac	= seq(','.r >> /[0-9]+/)
    time	= seq(hour, /:/._?, minute, /:/._?, second, secfrac._?, zone._?) {|h, _, m, _, s, f, z|
                h = {:hour => h, :min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h[:secfrac] = f[0] unless f.empty?
                Vcard::V3_0::PropertyValue::Time.new(h)
            } 
    timeT.eof
  end

  def date_time
    utc_offset 	= seq(C::SIGN, /[0-9]{2}/.r, /:/.r._?, /[0-9]{2}/.r) {|s, h, _, m|
                    {:sign => s, :hour => h, :min => m}
                }
    zone	= utc_offset.map {|u| u  } | 
                    /Z/i.r.map {|z| 'Z' }
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    secfrac	= seq(','.r >> /[0-9]+/)
     date	= seq(/[0-9]{4}/.r, /-/.r._?, /[0-9]{2}/.r, /-/.r._?, /[0-9]{2}/.r) {|yy, _, mm, _, dd|
		    {:year => yy, :month => mm, :day => dd}
        } 
    time	= seq(hour, /:/.r._?, minute, /:/.r._?, second, secfrac._?, zone._?) {|h, _, m, _, s, f, z|
                h = {:hour => h, :min => m, :sec => s}
		if z.empty?
                	h[:zone] = ''
		else
                	h[:zone] = z[0] 
		end
                h[:secfrac] = f[0] unless f.empty?
                h
            } 
     date_time	= seq(date, 'T', time) {|d, _, t|
                	#d = d.merge t
			#res = {:time => Time.local(d[:year], d[:month], d[:day], d[:hour], d[:min], d[:sec]), :zone => d[:zone]}
			#res[:secfrac] = h[:secfrac] if h[:secfrac]
			Vcard::V3_0::PropertyValue::DateTimeLocal.new(d.merge t)
	     	}
     date_time.eof
  end

  def date_or_date_time
    utc_offset 	= seq(C::SIGN, /[0-9]{2}/.r, /:/.r._?, /[0-9]{2}/.r) {|s, h, _, m|
                    {:sign => s, :hour => h, :min => m}
                }
    zone	= utc_offset.map {|u| u  } | 
                    /Z/i.r.map {|z| 'Z' }
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    secfrac	= seq(','.r >> /[0-9]+/)
     date	= seq(/[0-9]{4}/.r, /-/.r._?, /[0-9]{2}/.r, /-/.r._?, /[0-9]{2}/.r) {|yy, _, mm, _, dd|
		    {:year => yy, :month => mm, :day => dd}
        } 
    time	= seq(hour, /:/.r._?, minute, /:/.r._?, second, secfrac._?, zone._?) {|h, _, m, _, s, f, z|
                h = {:hour => h, :min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h[:secfrac] = f[0] unless f.empty?
                h
            } 
     date_or_date_time	= seq(date, 'T', time) {|d, _, t|
                	#d = d.merge t
			#res = {:time => Time.local(d[:year], d[:month], d[:day], d[:hour], d[:min], d[:sec]), :zone => d[:zone]}
			#res[:secfrac] = d[:secfrac] if d[:secfrac]
			Vcard::V3_0::PropertyValue::DateTimeLocal.new(d.merge t)
	     	} | date.map {|d|
			#res = {:time => Time.local(d[:year], d[:month], d[:day], 0, 0, 0), :zone => d[:zone]}
		    	Vcard::V3_0::PropertyValue::Date.new(d)
		}
     date_or_date_time.eof
  end

  def utc_offset
    utc_offset 	= seq(C::SIGN, /[0-9]{2}/.r, /:/.r._?, /[0-9]{2}/.r) {|s, h, _, m|
                    Vcard::V3_0::PropertyValue::Utcoffset.new({:sign => s, :hour => h, :min => m})
                }
    utc_offset.eof
  end

  def kindvalue
    ianaToken 	= /[a-zA-Z\d\-]+/.r 
    xname 	= seq( '[xX]-', /[a-zA-Z0-9-]+/.r).map(&:join)
	  kindvalue = (/individual/i.r | /group/i.r | /org/i.r | /location/i.r |
		  	ianaToken | xname).map {|k| Vcard::V3_0::PropertyValue::Kindvalue.new(k)}
	  kindvalue.eof
  end

  def fivepartname
    #text	= /([ \t\u0021\u0023-\u002b\u002d-\u0039\u003c-\u005b\u005d-\u007e:"\u0080-\u00bf\u00c2-\u00df\u00e0\u00a0-\u00bf\u00e1-\u00ec\u00ed\u0080-\u009f\u00ee-\u00ef\u00f0\u0090-\u00bf\u00f1-\u00f3\u00f4\u0080-\u008f]|\\[;,\\nN])*/.r  
    text	= C::TEXT3
    component	=  
	    	seq(text, ',', lazy{component}) {|a, _, b|
	    		[unescape(a), b].flatten
		} | text.map {|t| [unescape(t)] }
    fivepartname1 = seq(component, ';', component, ';', component, ';', 
		       component, ';', component) {|a, _, b, _, c, _, d, _, e|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		c = c[0] if c.length == 1
	    		d = d[0] if d.length == 1
	    		e = e[0] if e.length == 1
	    		{:surname => a, :givenname => b, :middlename => c, :honprefix => d, :honsuffix => e}
	    	} | seq(component, ';', component, ';', component, ';', component) {|a, _, b, _, c, _, d|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		c = c[0] if c.length == 1
	    		d = d[0] if d.length == 1
	    		{:surname => a, :givenname => b, :middlename => c, :honprefix => d, :honsuffix => ''}
	    	} | seq(component, ';', component, ';', component) {|a, _, b, _, c|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		c = c[0] if c.length == 1
	    		{:surname => a, :givenname => b, :middlename => c, :honprefix => '', :honsuffix => ''}
	    	} | seq(component, ';', component) {|a, _, b|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		{:surname => a, :givenname => b, :middlename => '', :honprefix => '', :honsuffix => ''}
	    	} | component.map {|a|
	    		a = a[0] if a.length == 1
	    		{:surname => 'a', :givenname => '', :middlename => '', :honprefix => '', :honsuffix => ''}
	    	} 
    fivepartname 	= fivepartname1.map {|n| Vcard::V3_0::PropertyValue::Fivepartname.new(n)}
    fivepartname.eof
  end

  def address
    text	= C::TEXT3
    component	=  
	    	seq(text, ',', lazy{component}) {|a, _, b|
	    		[unescape(a), b].flatten
		} | text.map {|t| [unescape(t)] }
    address1 = seq(component, ';', component, ';', component, ';', component, ';', 
		       component, ';', component, ';', component) {|a, _, b, _, c, _, d, _, e, _, f, _, g|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		c = c[0] if c.length == 1
	    		d = d[0] if d.length == 1
	    		e = e[0] if e.length == 1
	    		f = f[0] if f.length == 1
	    		g = g[0] if g.length == 1
	    		{:pobox => a, :ext => b, :street => c, 
				:locality => d, :region => e, :code => f, :country => g}
	    	} | seq(component, ';', component, ';', component, ';', component, ';', 
		       component, ';', component) {|a, _, b, _, c, _, d, _, e, _, f|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		c = c[0] if c.length == 1
	    		d = d[0] if d.length == 1
	    		e = e[0] if e.length == 1
	    		f = f[0] if f.length == 1
	    		{:pobox => a, :ext => b, :street => c, 
				:locality => d, :region => e, :code => f, :country => ''}
	    	} | seq(component, ';', component, ';', component, ';', component, ';', 
		       component) {|a, _, b, _, c, _, d, _, e|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		c = c[0] if c.length == 1
	    		d = d[0] if d.length == 1
	    		e = e[0] if e.length == 1
	    		{:pobox => a, :ext => b, :street => c, 
				:locality => d, :region => e, :code => '', :country => ''}
	    	} | seq(component, ';', component, ';', component, ';', component) {|a, _, b, _, c, _, d|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		c = c[0] if c.length == 1
	    		d = d[0] if d.length == 1
	    		{:pobox => a, :ext => b, :street => c, 
				:locality => d, :region => '', :code => '', :country => ''}
	    	} | seq(component, ';', component, ';', component) {|a, _, b, _, c|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		c = c[0] if c.length == 1
	    		{:pobox => a, :ext => b, :street => c, 
				:locality => '', :region => '', :code => '', :country => ''}
	    	} | seq(component, ';', component) {|a, _, b|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		{:pobox => a, :ext => b, :street => '', 
				:locality => '', :region => '', :code => '', :country => ''}
	    	} | component.map {|a|
	    		a = a[0] if a.length == 1
	    		{:pobox => a, :ext => '', :street => '', 
				:locality => '', :region => '', :code => '', :country => ''}
	    	} 
    address 	= address1.map {|n| Vcard::V3_0::PropertyValue::Address.new(n)}
    address.eof
  end

    def registered_propname
	        registered_propname = C::NAME_VCARD
		    registered_propname.eof
		      end

      def is_registered_propname?(x)
	          p = registered_propname.parse(x)
		      return not(Rsec::INVALID[p])
		        end
    # text escapes: \\ \; \, \N \n
    def unescape(x)
        # temporarily escape \\ as \007f, which is disallowed in any text
        x.gsub(/\\\\/, "\u007f").gsub(/\\;/, ';').gsub(/\\,/, ',').gsub(/\\[Nn]/, "\n").gsub(/\u007f/, "\\")
    end


  # Enforce type restrictions on values of particular properties.
  # If successful, return typed interpretation of string
  def typematch(key, params, component, value, ctx)
    params[:VALUE] = params[:VALUE].downcase if params and params[:VALUE]
    property_parent(key, component, value, ctx)
    ctx1 = Rsec::ParseContext.new value, 'source'
    case key
     when :VERSION
	    ret = versionvalue._parse ctx1
     when :SOURCE, :URL, :IMPP, :FBURL, :CALURI, :CALADRURI, :CAPURI
	    ret = uri._parse ctx1
	    # not imposing filename restrictions on calendar URIs
     when :NAME, :FN, :LABEL, :EMAIL, :MAILER, :TITLE, :ROLE, :NOTE, :PRODID, :SORT_STRING, :UID
	    ret = textT._parse ctx1
     when :CLASS
	    ret = classvalue._parse ctx1
     when :CATEGORIES, :NICKNAME
	    ret = textlist._parse ctx1
     when :ORG
	    ret = org._parse ctx1
     when :PROFILE
	    ret = profilevalue._parse ctx1
     when :N
	    ret = fivepartname._parse ctx1
     when :PHOTO, :LOGO, :SOUND
	     if params and params[:VALUE] == 'uri'
		     ret = uri._parse ctx1
	     else
		     ret = binary._parse ctx1
	     end
     when :KEY
	     if params and params[:ENCODING] == 'b'
		     ret = binary._parse ctx1
	     else
		     ret = textT._parse ctx1
	     end
     when :BDAY
	     if params and params[:VALUE] == 'date-time'
		     ret = date_time._parse ctx1
	     elsif params and params[:VALUE] == 'date'
		     ret = dateT._parse ctx1
	     else
		     # unlike VCARD 4, can have either date or date_time without explicit value switch
		     ret = date_or_date_time._parse ctx1
	     end
     when :REV
	     if params and params[:VALUE] == 'date'
		     ret = dateT._parse ctx1
	     elsif params and params[:VALUE] == 'date-time'
		     ret = date_time._parse ctx1
	     else
		     # unlike VCARD 4, can have either date or date_time without explicit value switch
		     ret = date_or_date_time._parse ctx1
	     end
     when :ADR
	    ret = address._parse ctx1
    when :TEL
	    ret = phoneNumber._parse ctx1
    when :TZ
	    if params and params[:VALUE] == 'text'
	    	ret = textT._parse ctx1
	    else
	    	ret = utc_offset._parse ctx1
	    end
    when :GEO
	    ret = geovalue._parse ctx1
    when :AGENT
	    if params and params[:VALUE] == 'uri'
	    	ret = uri._parse ctx1
	    else
		# unescape
		value = value.gsub(/\\n/,"\n").gsub(/\\;/,';').gsub(/\\,/,',').gsub(/\\:/,':')
		# spec says that colons need to be escaped, but none of the examples do so
		#value = value.gsub(/\\:/,':')
		value = value.gsub(/BEGIN:VCARD\n/, "BEGIN:VCARD\nVERSION:3.0\n") unless value =~ /\nVERSION:3\.0/
    		ctx1 = Rsec::ParseContext.new value, 'source' 
		ret = Vcard::V3_0::PropertyValue::Agent.new(Vcard::V3_0::Grammar.vobjectGrammar._parse ctx1)
	    end
    else
	    ret = textT._parse ctx1
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
