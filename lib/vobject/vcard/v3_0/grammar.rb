require "rsec"
require "set"
require "uri"
require "date"
include Rsec::Helpers
require "vobject"
require "vobject/component"
require "vobject/vcard/v3_0/paramcheck"
require "vobject/vcard/v3_0/typegrammars"
require_relative "../../../c"
require_relative "../../../error"

module Vcard::V3_0
  class Grammar
    attr_accessor :strict, :errors
    class << self
      def unfold(str)
        str.gsub(/[\n\r]+[ \t]/, "")
      end
    end

    def vobject_grammar
      # properties with value cardinality 1
      @cardinality1 = {}
      @cardinality1[:PARAM] = Set.new [:VALUE]
      @cardinality1[:PROP] = Set.new [:KIND, :N, :BDAY, :ANNIVERSARY, :GENDER, :PRODID, :REV, :UID]

      group = C::IANATOKEN
      linegroup = group <<  "."
      beginend = /BEGIN/i.r | /END/i.r

      # parameters && parameter types
      paramname = /ENCODING/i.r | /LANGUAGE/i.r | /CONTEXT/i.r | /TYPE/i.r | /VALUE/i.r | /PREF/i.r
      otherparamname = C::NAME_VCARD ^ paramname
      paramvalue = C::QUOTEDSTRING_VCARD.map { |s| s } | C::PTEXT_VCARD.map { |x, _| x.upcase }

      # prefvalue = /[0-9]{1,2}/i.r | "100".r
      valuetype = /URI/i.r | /DATE/i.r | /DATE-TIME/i.r | /BINARY/i.r | /PTEXT/i.r
      # mediaattr = /[!\"#$%&'*+.^A-Z0-9a-z_`i{}|~-]+/.r
      # mediavalue1 =	mediaattr | C::QUOTEDSTRING_VCARD
      # mediatail = seq(";".r >> mediaattr, "=".r << mediavalue1).map do |(a, v)|
      #  ";#{a}=#{v}"
      # end
      # rfc4288regname = /[A-Za-z0-9!#$&.+^+-]{1,127}/.r
      # rfc4288typename = rfc4288regname
      # rfc4288subtypename = rfc4288regname
      # mediavalue = seq(rfc4288typename << "/".r, rfc4288subtypename, # mediatail.star).map do |(t, s, tail)|
      #  ret = "#{t}/#{s}"
      #  ret = ret . tail[0] unless tail.empty?
      #  ret
      # end
      pvalue_list = (seq(paramvalue << ",".r, lazy { pvalue_list }) & /[;:]/.r).map do |(e, list)|
        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n"), list].flatten
      end | (paramvalue & /[;:]/.r).map do |e|
        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")]
      end
      typevaluelist = seq(C::IANATOKEN, ",".r >> lazy { typevaluelist }).map do |(t, l)|
        [t.upcase, l].flatten
      end | C::IANATOKEN.map { |t| [t.upcase] }
      quoted_string_list = (seq(C::QUOTEDSTRING_VCARD << ",".r, lazy { quoted_string_list }) & /[;:]/.r).map do |(e, list)|
        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n"), list].flatten
      end | (C::QUOTEDSTRING_VCARD & /[;:]/.r).map do |e|
        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")]
      end

      # fmttypevalue = seq(rfc4288typename, "/", rfc4288subtypename).map {|x, _| x.join }
      rfc1766primarytag = /[A-Za-z]{1,8}/.r
      rfc1766subtag = seq("-", /[A-Za-z]{1,8}/.r) { |(a, b)| a + b }
      rfc1766language = seq(rfc1766primarytag, rfc1766subtag.star) do |(a, b)|
        a += b[0] unless b.empty?
        a
      end

      param = seq(/ENCODING/i.r, "=", /b/.r) do |(name, _, val)|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/LANGUAGE/i.r, "=", rfc1766language) do |(name, _, val)|
        { name.upcase.tr("-", "_").to_sym => val.upcase }
      end | seq(/CONTEXT/i.r, "=", /word/.r) do |(name, _, val)|
        { name.upcase.tr("-", "_").to_sym => val.upcase }
      end | seq(/TYPE/i.r, "=", typevaluelist) do |(name, _, val)|
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(/VALUE/i.r, "=", valuetype) do |(name, _, val)|
        { name.upcase.tr("-", "_").to_sym => val }
      end | /PREF/i.r.map do |_name|
        # this is likely erroneous use of VCARD 2.1 convention in RFC2739; converting to canonical TYPE=PREF
        { TYPE: ["PREF"] }
      end | seq(otherparamname, "=", pvalue_list) do |(name, _, val)|
        val = val[0] if val.length == 1
        { name.upcase.tr("-", "_").to_sym => val }
      end | seq(paramname, "=", pvalue_list) do |(name, _, val)|
        parse_err("Violated format of parameter value #{name} = #{val}")
      end

      params = seq(";".r >> param & ";", lazy { params }) do |(p, ps)|
        p.merge(ps) do |key, old, new|
          if @cardinality1[:PARAM].include?(key)
            parse_err("Violated cardinality of parameter #{key}")
          end
          [old, new].flatten
          # deal with duplicate properties
        end
      end |  seq(";".r >> param).map { |e| e[0] }

      contentline = seq(linegroup._?, C::NAME_VCARD, params._? << ":".r,
                        C::VALUE, /(\r|\n|\r\n)/) do |(g, name, p, value, _)|
        key =  name.upcase.tr("-", "_").to_sym
        hash = { key => {} }
        hash[key][:value], errors1 = Typegrammars.typematch(strict, key, p[0], :GENERIC, value, @ctx)
        errors << errors1
        hash[key][:group] = g[0] unless g.empty?
        errors << Paramcheck.paramcheck(strict, key, p.empty? ? {} : p[0], @ctx)
        hash[key][:params] = p[0] unless p.empty?
        hash
      end
      props = seq(contentline, lazy { props }) do |(c, rest)|
        c.merge(rest) do |key, old, new|
          if @cardinality1[:PROP].include?(key.upcase)
            parse_err("Violated cardinality of property #{key}")
          end
          [old, new].flatten
          # deal with duplicate properties
        end
      end | ("".r & beginend).map { {} }

      calpropname = /VERSION/i.r
      calprop = seq(linegroup._?, calpropname << ":".r, C::VALUE, /[\r\n]/) do |(g, key, value, _)|
        key = key.upcase.tr("-", "_").to_sym
        hash = { key => {} }
        hash[key][:value], errors1 = Typegrammars.typematch(strict, key, nil, :VCARD, value, @ctx)
        errors << errors1
        hash[key][:group] = g[0] unless g.empty?
        hash
      end
      vobject = seq(linegroup._?, /BEGIN:VCARD[\r\n]/i.r >> calprop, props, linegroup._? << /END:VCARD[\r\n]/i.r) do |(_g, v, rest, _g1)|
        # TODO what do we do with the groups here?
        parse_err("Missing VERSION attribute") unless v.has_key?(:VERSION)
        parse_err("Missing FN attribute") unless rest.has_key?(:FN)
        parse_err("Missing N attribute") unless rest.has_key?(:N)
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
      else
        errors << @ctx.report_error(msg, "source")
      end
    end
  end
end
