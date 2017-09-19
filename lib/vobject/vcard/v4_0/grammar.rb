require "rsec"
require "set"
require "uri"
require "date"
#require "tzinfo"
include Rsec::Helpers
require "vobject/vcard/version"
require "vobject"
require "vobject/component"
require "vobject/vcard/v4_0/paramcheck"
require "vobject/vcard/v4_0/typegrammars"
require_relative "../../../c"
require_relative "../../../error"

module Vcard::V4_0
  class Grammar
    attr_accessor :strict, :errors

    class << self
      def unfold(str)
        str.gsub(/[\n\r]+[ \t]/, "")
      end
    end

    # RFC 6868
    def rfc6868decode(x)
      x.gsub(/\^n/, "\n").gsub(/\^\^/, '^').gsub(/\^'/, '"')
    end


    def vobjectGrammar

      # properties with value cardinality 1
      @cardinality1 = {}
      @cardinality1[:PARAM] = Set.new [:VALUE]
      @cardinality1[:PROP] = Set.new [:KIND, :N, :BDAY, :ANNIVERSARY, :GENDER, :PRODID, :REV, :UID, :BIRTHPLACE, :DEATHPLACE, :DEATHDATE]

      group 	= C::IANATOKEN
      linegroup 	= group <<  '.'
      beginend 	= /BEGIN/i.r | /END/i.r



      # parameters && parameter types
      paramname 		= /LANGUAGE/i.r | /VALUE/i.r | /PREF/i.r | /ALTID/i.r | /PID/i.r |
        /TYPE/i.r | /MEDIATYPE/i.r | /CALSCALE/i.r | /SORT-AS/i.r |
        /GEO/i.r | /TZ/i.r | /LABEL/i.r | /INDEX/i.r | /LEVEL/i.r
      otherparamname = C::NAME_VCARD ^ paramname
      paramvalue 	= C::QUOTEDSTRING_VCARD.map { |s| rfc6868decode s } | C::PTEXT_VCARD.map { |s| rfc6868decode(s).upcase }
      tzidvalue 	= seq("/".r._?, C::PTEXT_VCARD).map { |_, val| val}   
      calscalevalue = /GREGORIAN/i.r | C::IANATOKEN | C::XNAME_VCARD
      prefvalue	= /[0-9]{1,2}/i.r | '100'.r
      pidvalue	= /[0-9]+(\.[0-9]+)?/.r
      pidvaluelist	=  seq(pidvalue, ",", lazy { pidvaluelist }) { |a, _, b|
        [a, b].flatten
      } | (pidvalue ^ ",".r).map { |z| [z]}
      typeparamtel1	= /TEXT/i.r | /VOICE/i.r | /FAX/i.r | /CELL/i.r | /VIDEO/i.r |
        /PAGER/i.r | /TEXTPHONE/i.r
      typeparamtel	= typeparamtel1 | C::IANATOKEN | C::XNAME_VCARD
      typeparamrelated	= /CONTACT/i.r | /ACQUAINTANCE/i.r | /FRIEND/i.r | /MET/i.r |
        /CO-WORKER/i.r | /COLLEAGUE/i.r | /CO-RESIDENT/i.r | /NEIGHBOR/i.r |
        /CHILD/i.r | /PARENT/i.r | /SIBLING/i.r | /SPOUSE/i.r | /KIN/i.r |
        /MUSE/i.r | /CRUSH/i.r | /DATE/i.r | /SWEETHEART/i.r | /ME/i.r |
        /AGENT/i.r | /EMERGENCY/i.r
      typevalue	= /WORK/i.r | /HOME/i.r | typeparamtel1 | typeparamrelated | C::IANATOKEN | C::XNAME_VCARD
      typevaluelist =  	seq(typevalue, ",", lazy { typevaluelist }) { |a, _, b|
        [a.upcase, b].flatten
      } | typevalue.map { |t| [t.upcase] }
      typeparamtel1list =  seq(typeparamtel1, ",", lazy{typeparamtel1list}) { |a, _, b|
        [a.upcase, b].flatten
      } | typeparamtel1.map { |t| [t.upcase] }
      geourlvalue = seq('"'.r >> C::TEXT4 << '"'.r) { |s|
        parse_err("geo value not a URI") unless s =~ URI::regexp
        s
      }
      tzvalue 	= paramvalue | geourlvalue
      valuetype 	= /TEXT/i.r | /URI/i.r | /TIMESTAMP/i.r | /TIME/i.r | /DATE-TIME/i.r | /DATE/i.r |
        /DATE-AND-OR-TIME/i.r | /BOOLEAN/i.r | /INTEGER/i.r | /FLOAT/i.r | /UTC-OFFSET/i.r |
        /LANGUAGE-TAG/i.r | C::IANATOKEN | C::XNAME_VCARD
      mediaattr	= /[!\"#$%&'*+.^A-Z0-9a-z_`i{}|~-]+/.r
      mediavalue	=	mediaattr | C::QUOTEDSTRING_VCARD
      mediatail	= seq(";", mediaattr, "=", mediavalue).map { |_, a, _, v|
        ";#{a}=#{v}"
      }
      rfc4288regname      = /[A-Za-z0-9!#$&.+^+-]{1,127}/.r
      rfc4288typename     = rfc4288regname
      rfc4288subtypename  = rfc4288regname
      mediavalue	= seq(rfc4288typename, "/", rfc4288subtypename, mediatail.star).map { |t, _, s, tail|
        ret = "#{t}/#{s}"
        ret = ret . tail[0] unless tail.empty?
        ret
      }
      pvalueList 	=  (seq(paramvalue, ",".r, lazy{pvalueList}) & /[;:]/.r).map { |e, _, list|
        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n") , list].flatten
      } | (paramvalue & /[;:]/.r).map { |e|
        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")]
      }
      quotedStringList =  (seq(C::QUOTEDSTRING_VCARD, ",".r, lazy{quotedStringList}) & /[;:]/.r).map { |e, _, list|
        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n"), list].flatten
      } | (C::QUOTEDSTRING_VCARD & /[;:]/.r).map { |e|
        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")]
      }

      fmttypevalue 	= seq(rfc4288typename, "/", rfc4288subtypename).map(&:join)
      levelvalue	= /beginner/i.r | /average/i.r | /expert/i.r | /high/i.r | /medium/i.r | /low/i.r

      param 	= seq(/ALTID/i.r, "=", paramvalue) { |name, _, val|
        {name.upcase.gsub(/-/,"_").to_sym => val}
      } | seq(/LANGUAGE/i.r, "=", C::RFC5646LANGVALUE) { |name, _, val|
        {name.upcase.gsub(/-/,"_").to_sym => val.upcase}
      } | seq(/PREF/i.r, "=", prefvalue) { |name, _, val|
        {name.upcase.gsub(/-/,"_").to_sym => val.upcase}
      } | seq(/TYPE/i.r, "=", "\"".r >> typevaluelist << "\"".r) { |name, _, val|
        # not in spec but in examples. Errata ID 3488, "Held for Document Update": acknwoledged as error requiring an updated spec. With this included, TYPE="x,y,z" is a list of values; the proper ABNF behaviour is that "x,y,z" is interpreted as a single value
        {name.upcase.gsub(/-/,"_").to_sym => val}
      } | seq(/TYPE/i.r, "=", typevaluelist) { |name, _, val|
        {name.upcase.gsub(/-/,"_").to_sym => val}
      } | seq(/MEDIATYPE/i.r, "=", mediavalue) { |name, _, val|
        {name.upcase.gsub(/-/,"_").to_sym => val}
      } | seq(/CALSCALE/i.r, "=", calscalevalue) { |name, _, val|
        {name.upcase.gsub(/-/,"_").to_sym => val}
      } | seq(/SORT-AS/i.r, "=", pvalueList) { |name, _, val|
        {name.upcase.gsub(/-/,"_").to_sym => val}
      } | seq(/TZ/i.r, "=", tzvalue) { |name, _, val|
        {name.upcase.gsub(/-/,"_").to_sym => val}
      } | seq(/GEO/i.r, "=", geourlvalue) { |name, _, val|
        {name.upcase.gsub(/-/,"_").to_sym => val}
      } | seq(/VALUE/i.r, "=", valuetype) { |name, _, val|
        {name.upcase.gsub(/-/,"_").to_sym => val}
      } | seq(/PID/i.r, "=", pidvaluelist) { |name, _, val|
        {name.upcase.gsub(/-/,"_").to_sym => val}
      } | seq(/INDEX/i.r, "=", prim(:int32)) { |name, _, val|
        {name.upcase.gsub(/-/,"_").to_sym => val}
      } | seq(/LEVEL/i.r, "=", levelvalue) { |name, _, val|
        {name.upcase.gsub(/-/,"_").to_sym => val.upcase}
      } | seq(otherparamname, "=", pvalueList) { |name, _, val|
        val = val[0] if val.length == 1
        {name.upcase.gsub(/-/,"_").to_sym => val}
      } | seq(paramname, "=", pvalueList) { |name, _, val|
        parse_err("Violated format of parameter value #{name} = #{val}")
      }

      params	=  seq(";".r >> param, lazy { params } ) { |p, ps|
        p.merge(ps) { |key, old, new|
          if @cardinality1[:PARAM].include?(key)
            parse_err("Violated cardinality of parameter #{key}")
          end
          [old,  new].flatten
          # deal with duplicate properties
        }
      } | seq(";".r >> param ^ ";".r).map { |e|
        e[0]
      }

      contentline = seq(linegroup._?, C::NAME_VCARD, params._?, ':',
                        C::VALUE, /[\r\n]/) do |group, name, params, _, value, _|
        key =  name.upcase.gsub(/-/,"_").to_sym
        hash = { key => {} }
        self.errors << Vcard::V4_0::Paramcheck.paramcheck(self.strict, key, params.empty?  ? {} : params[0], @ctx)
        hash[key][:value], errors1 = Vcard::V4_0::Typegrammars.typematch(self.strict, key, params[0], :GENERIC, value)
        self.errors << errors1
        hash[key][:group] = group[0]  unless group.empty?
        hash[key][:params] = params[0] unless params.empty?
        hash
      end
      props	=  seq(contentline, lazy { props }) { |c, rest|
        c.merge( rest ) { | key, old, new|
          if @cardinality1[:PROP].include?(key.upcase) and
            !(new.is_a?(Array) and
              new[0].key?(:params) && new[0][:params].key?(:ALTID) and
              old.key?(:params) && old[:params].key?(:ALTID) and
              old[:params][:ALTID] == new[0][:params][:ALTID]) and
            !(new.is_a?(Hash) and
              old.key?(:params) && old[:params].key?(:ALTID) and
              new.key?(:params) && new[:params].key?(:ALTID) and
              old[:params][:ALTID] == new[:params][:ALTID])
            parse_err("Violated cardinality of property #{key}")
          end
          [old,  new].flatten
          # deal with duplicate properties
        }
      } | ("".r & beginend).map { |e|
        {}  
      }

      calpropname = /VERSION/i.r
      calprop     = seq(calpropname, ':', C::VALUE, 	/[\r\n]/) { |key, _, value, _|
        key = key.upcase.gsub(/-/,"_").to_sym
        hash = { key => {} }
        hash[key][:value], errors1 = Vcard::V4_0::Typegrammars.typematch(self.strict, key, nil, :VCARD, value)
        self.errors << errors1
        hash
      }
      vobject 	= seq(/BEGIN:VCARD[\r\n]/i.r, calprop, props, /END:VCARD[\r\n]/i.r) { |(b, v, rest, e)|
        parse_err("Missing VERSION attribute") unless v.has_key?(:VERSION)
        parse_err("Missing FN attribute") unless rest.has_key?(:FN)
        rest.delete(:END)
        hash = { :VCARD => v.merge( rest ) , :errors => self.errors.flatten }
        hash
      }
      vobject.eof
    end

    def initialize(strict)
      self.strict = strict
      self.errors = []
    end


    def parse(vobject)
      @ctx = Rsec::ParseContext.new self.class.unfold(vobject), "source"
      ret = vobjectGrammar._parse @ctx
      if !ret || Rsec::INVALID[ret]
        if self.strict
          raise @ctx.generate_error "source"
        else
          self.errors << @ctx.generate_error("source")
          ret = { :VCARD => nil, :errors => self.errors.flatten }
        end

      end
      Rsec::Fail.reset
      return ret
    end

    private

    def parse_err(msg)
      if self.strict
        raise @ctx.report_error msg, "source"
      else
        self.errors << @ctx.report_error(msg, "source")
      end
    end

  end
end
