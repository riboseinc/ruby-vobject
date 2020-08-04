require "rsec"
require "set"
require "uri"
require "date"
include Rsec::Helpers
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
      x.gsub(/\^n/, "\n").gsub(/\^\^/, "^").gsub(/\^'/, '"')
    end

    def vobject_grammar
      # properties with value cardinality 1
      @cardinality1 = {}
      @cardinality1[:PARAM] = Set.new [:VALUE]
      @cardinality1[:PROP] = Set.new [:KIND, :N, :BDAY, :ANNIVERSARY, :GENDER, :PRODID, :REV, :UID, :BIRTHPLACE, :DEATHPLACE, :DEATHDATE]

      group = C::IANATOKEN
      linegroup = group <<  "."
      beginend = /BEGIN/i.r | /END/i.r

      # parameters && parameter types
      paramname 	 = /LANGUAGE/i.r | /VALUE/i.r | /PREF/i.r | /ALTID/i.r | /PID/i.r |
        /TYPE/i.r | /MEDIATYPE/i.r | /CALSCALE/i.r | /SORT-AS/i.r |
        /GEO/i.r | /TZ/i.r | /LABEL/i.r | /INDEX/i.r | /LEVEL/i.r
      otherparamname = C::NAME_VCARD ^ paramname
      paramvalue = C::QUOTEDSTRING_VCARD.map { |s| rfc6868decode s } | C::PTEXT_VCARD.map { |s| rfc6868decode(s).upcase }
      # tzidvalue = seq("/".r._?, C::PTEXT_VCARD).map { |(_, val)| val }
      calscalevalue = /GREGORIAN/i.r | C::IANATOKEN | C::XNAME_VCARD
      prefvalue = /[0-9]{1,2}/i.r | "100".r
      pidvalue = /[0-9]+(\.[0-9]+)?/.r
      pidvaluelist = seq(pidvalue, ",", lazy { pidvaluelist }) do |(a, _, b)|
        [a, b].flatten
      end | (pidvalue ^ ",".r).map { |z| [z] }
      typeparamtel1 = /TEXT/i.r | /VOICE/i.r | /FAX/i.r | /CELL/i.r | /VIDEO/i.r |
        /PAGER/i.r | /TEXTPHONE/i.r
      typeparamtel = typeparamtel1 | C::IANATOKEN | C::XNAME_VCARD
      typeparamrelated = /CONTACT/i.r | /ACQUAINTANCE/i.r | /FRIEND/i.r | /MET/i.r |
        /CO-WORKER/i.r | /COLLEAGUE/i.r | /CO-RESIDENT/i.r | /NEIGHBOR/i.r |
        /CHILD/i.r | /PARENT/i.r | /SIBLING/i.r | /SPOUSE/i.r | /KIN/i.r |
        /MUSE/i.r | /CRUSH/i.r | /DATE/i.r | /SWEETHEART/i.r | /ME/i.r |
        /AGENT/i.r | /EMERGENCY/i.r
      typevalue = /WORK/i.r | /HOME/i.r | typeparamtel1 | typeparamrelated | C::IANATOKEN | C::XNAME_VCARD
      typevaluelist = seq(typevalue << ",".r, lazy { typevaluelist }) do |(a, b)|
        [a.upcase, b].flatten
      end | typevalue.map { |t| [t.upcase] }
      typeparamtel1list = seq(typeparamtel << ",".r, lazy { typeparamtel1list }) do |(a, b)|
        [a.upcase, b].flatten
      end | typeparamtel.map { |t| [t.upcase] }
      geourlvalue = seq('"'.r >> C::TEXT4 << '"'.r) do |s|
        parse_err("geo value not a URI") unless s =~ URI::DEFAULT_PARSER.make_regexp
        s
      end
      tzvalue = paramvalue | geourlvalue
      valuetype = /TEXT/i.r | /URI/i.r | /TIMESTAMP/i.r | /TIME/i.r | /DATE-TIME/i.r | /DATE/i.r |
        /DATE-AND-OR-TIME/i.r | /BOOLEAN/i.r | /INTEGER/i.r | /FLOAT/i.r | /UTC-OFFSET/i.r |
        /LANGUAGE-TAG/i.r | C::IANATOKEN | C::XNAME_VCARD
      mediaattr = /[!\"#$%&'*+.^A-Z0-9a-z_`i{}|~-]+/.r
      mediavalue =	mediaattr | C::QUOTEDSTRING_VCARD
      mediatail = seq(";".r >> mediaattr << "=".r, mediavalue).map do |(a, v)|
        ";#{a}=#{v}"
      end
      rfc4288regname = /[A-Za-z0-9!#$&.+^+-]{1,127}/.r
      rfc4288typename = rfc4288regname
      rfc4288subtypename = rfc4288regname
      mediavalue = seq(rfc4288typename << "/".r, rfc4288subtypename, mediatail.star).map do |(t, s, tail)|
        ret = "#{t}/#{s}"
        ret = ret . tail[0] unless tail.empty?
        ret
      end
      pvalue_list = (seq(paramvalue << ",".r, lazy { pvalue_list }) & /[;:]/.r).map do |(e, list)|
        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n"), list].flatten
      end | (paramvalue & /[;:]/.r).map do |e|
        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")]
      end
      quoted_string_list = (seq(C::QUOTEDSTRING_VCARD << ",".r, lazy { quoted_string_list }) & /[;:]/.r).map do |(e, list)|
        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n"), list].flatten
      end | (C::QUOTEDSTRING_VCARD & /[;:]/.r).map do |e|
        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")]
      end

      # fmttypevalue = seq(rfc4288typename, "/", rfc4288subtypename).map {|x, _| x.join }
      levelvalue = /beginner/i.r | /average/i.r | /expert/i.r | /high/i.r | /medium/i.r | /low/i.r

      param = seq(/ALTID/i.r, "=", paramvalue) do |(name, _, val)|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/LANGUAGE/i.r, "=", C::RFC5646LANGVALUE) do |(name, _, val)|
        { name.upcase.tr("-", "_").to_sym => val.upcase }
      end | seq(/PREF/i.r, "=", prefvalue) do |(name, _, val)|
        { name.upcase.tr("-", "_").to_sym => val.upcase }
      end | seq(/TYPE/i.r, "=", "\"".r >> typevaluelist << "\"".r) do |(name, _, val)|
        # not in spec but in examples. Errata ID 3488, "Held for Document Update": acknwoledged as error requiring an updated spec. With this included, TYPE="x,y,z" is a list of values; the proper ABNF behaviour is that "x,y,z" is interpreted as a single value
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/TYPE/i.r, "=", typevaluelist) do |(name, _, val)|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/MEDIATYPE/i.r, "=", mediavalue) do |(name, _, val)|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/CALSCALE/i.r, "=", calscalevalue) do |(name, _, val)|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/SORT-AS/i.r, "=", pvalue_list) do |(name, _, val)|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/TZ/i.r, "=", tzvalue) do |(name, _, val)|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/GEO/i.r, "=", geourlvalue) do |(name, _, val)|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/VALUE/i.r, "=", valuetype) do |(name, _, val)|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/PID/i.r, "=", pidvaluelist) do |(name, _, val)|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/INDEX/i.r, "=", prim(:int32)) do |(name, _, val)|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/LEVEL/i.r, "=", levelvalue) do |(name, _, val)|
        { name.upcase.tr("-", "_").to_sym => val.upcase }
      end | seq(otherparamname, "=", pvalue_list) do |(name, _, val)|
        val = val[0] if val.length == 1
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(paramname, "=", pvalue_list) do |(name, _, val)|
        parse_err("Violated format of parameter value #{name} = #{val}")
      end

      params = seq(";".r >> param, lazy { params }) do |(p, ps)|
        p.merge(ps) do |key, old, new|
          if @cardinality1[:PARAM].include?(key)
            parse_err("Violated cardinality of parameter #{key}")
          end
          [old, new].flatten
          # deal with duplicate properties
        end
      end | seq(";".r >> param ^ ";".r).map { |e| e[0] }

      contentline = seq(linegroup._?, C::NAME_VCARD, params._? << ":".r,
                        C::VALUE, /[\r\n]/) do |(l, name, p, value, _)|
        key = name.upcase.tr("-", "_").to_sym
        hash = { key => {} }
        errors << Paramcheck.paramcheck(strict, key, p.empty? ? {} : p[0], @ctx)
        hash[key][:value], errors1 = Typegrammars.typematch(strict, key, p[0], :GENERIC, value)
        errors << errors1
        hash[key][:group] = l[0]  unless l.empty?
        hash[key][:params] = p[0] unless p.empty?
        hash
      end
      props = seq(contentline, lazy { props }) do |(c, rest)|
        c.merge(rest) do |key, old, new|
          if @cardinality1[:PROP].include?(key.upcase) &&
            !(new.is_a?(Array) &&
              new[0].key?(:params) && new[0][:params].key?(:ALTID) &&
              old.key?(:params) && old[:params].key?(:ALTID) &&
              old[:params][:ALTID] == new[0][:params][:ALTID]) &&
            !(new.is_a?(Hash) &&
              old.key?(:params) && old[:params].key?(:ALTID) &&
              new.key?(:params) && new[:params].key?(:ALTID) &&
              old[:params][:ALTID] == new[:params][:ALTID])
            parse_err("Violated cardinality of property #{key}")
          end
          [old, new].flatten
          # deal with duplicate properties
        end
      end | ("".r & beginend).map { {} }

      calpropname = /VERSION/i.r
      calprop = seq(calpropname << ":".r, C::VALUE, /[\r\n]/.r) do |(key, value)|
        key = key.upcase.tr("-", "_").to_sym
        hash = { key => {} }
        hash[key][:value], errors1 = Typegrammars.typematch(strict, key, nil, :VCARD, value)
        errors << errors1
        hash
      end
      vobject = seq(/BEGIN:VCARD[\r\n]/i.r >> calprop, props << /END:VCARD[\r\n]/i.r) do |(v, rest)|
        parse_err("Missing VERSION attribute") unless v.has_key?(:VERSION)
        parse_err("Missing FN attribute") unless rest.has_key?(:FN)
        rest.delete(:END)
        { VCARD: v.merge(rest), errors: errors.flatten }
      end
      vobject.eof
    end

    def initialize(strict)
      self.strict = strict
      self.errors = []
    end

    def parse(vobject)
      @ctx = Rsec::ParseContext.new self.class.unfold(vobject), "source"
      ret = vobject_grammar._parse @ctx
      if !ret || Rsec::INVALID[ret]
        if strict
          raise @ctx.generate_error "source"
        else
          errors << @ctx.generate_error("source")
          ret = { VCARD: nil, errors: errors.flatten }
        end

      end
      Rsec::Fail.reset
      ret
    end

    private

    def parse_err(msg)
      if strict
        raise @ctx.report_error msg, "source"
      end

      errors << @ctx.report_error(msg, "source")
    end
  end
end
