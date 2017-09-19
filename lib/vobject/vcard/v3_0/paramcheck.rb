require "rsec"
require "set"
require "uri"
require "date"
include Rsec::Helpers
require "vobject/vcard/version"
require "vobject"

module Vcard::V3_0
  class Paramcheck
    class << self
      def paramcheck(strict, prop, params, ctx)
        errors = []
        if params && params[:TYPE]
          parse_err(strict, errors, "multiple values for :TYPE parameter of #{prop}", ctx) if params[:TYPE].is_a?(Array) && params[:TYPE].length > 1 && prop != :EMAIL && prop != :ADR && prop != :TEL && prop != :LABEL && prop != :IMPP
        end
        case prop
        when :NAME, :PROFILE, :GEO, :PRODID, :URL, :VERSION, :CLASS
          parse_err(strict, errors, "illegal parameters #{params} given for #{prop}", ctx) unless params.empty?
        when :CALURI, :CAPURI, :CALADRURI, :FBURL
          params.each do |key, val|
            parse_err(strict, errors, "illegal parameter #{key} given for #{prop}", ctx) unless key == :TYPE
            if params[:TYPE].is_a?(Array)
              val.each do |v|
                parse_err(strict, errors, "illegal parameter value #{v} given for parameter #{key} of #{prop}", ctx) unless v == "PREF"
              end
            else
              parse_err(strict, errors, "illegal parameter value #{val} given for parameter #{key} of #{prop}", ctx) unless val == "PREF"
            end
          end
        when :SOURCE
          params.each do |key, val|
            parse_err(strict, errors, "illegal parameter #{key} given for #{prop}", ctx) unless key == :VALUE || key == :CONTEXT || key =~ /^x/i
            parse_err(strict, errors, "illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE && val != "uri"
            parse_err(strict, errors, "illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :CONTEXT && val != "word"
          end
        when :FN, :N, :NICKNAME, :MAILER, :TITLE, :ROLE, :ORG, :CATEGORIES, :NOTE, :SORT_STRING
          params.each do |key, val|
            parse_err(strict, errors, "illegal parameter #{key} given for #{prop}", ctx) unless key == :VALUE || key == :LANGUAGE || key =~ /^x/i
            parse_err(strict, errors, "illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE && val != "ptext"
          end
        when :TEL, :IMPP, :UID
          # UID included here per errata
          params.each_key do |key|
            parse_err(strict, errors, "illegal parameter #{key} given for #{prop}", ctx) unless key == :TYPE
          end
          # we do not check the values of the :TEL :TYPE parameter, because they include ianaToken
        when :EMAIL
          params.each_key do |key|
            parse_err(strict, errors, "illegal parameter #{key} given for #{prop}", ctx) unless key == :TYPE
          end
          # we do not check the values of the first :EMAIL :TYPE parameter, because they include ianaToken
        when :ADR, :LABEL
          params.each do |key, val|
            parse_err(strict, errors, "illegal parameter #{key} given for #{prop}", ctx) unless [:VALUE, :LANGUAGE, :TYPE].include? key || key =~ /^x/i
            parse_err(strict, errors, "illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE && val != "ptext"
          end
          # we do not check the values of the :ADR :TYPE parameter, because they include ianaToken
        when :KEY
          params.each do |key, val|
            # VALUE included here per errata
            parse_err(strict, errors, "illegal parameter #{key} given for #{prop}", ctx) unless [:TYPE, :ENCODING, :VALUE].include? key
            parse_err(strict, errors, "illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE && val != "binary"
          end
          # we do not check the values of the :KEY :TYPE parameter, because they include ianaToken
        when :PHOTO, :LOGO, :SOUND
          params.each_key do |key|
            parse_err(strict, errors, "illegal parameter #{key} given for #{prop}", ctx) unless [:VALUE, :TYPE, :ENCODING].include? key
          end
          parse_err(strict, errors, "illegal value #{params[:VALUE]} of :VALUE given for #{prop}", ctx) if params[:VALUE] && params[:VALUE] != "binary" && params[:VALUE] != "uri"
          parse_err(strict, errors, "illegal value #{params[:ENCODING]} of :ENCODING given for #{prop}", ctx) if params[:ENCODING] && (params[:ENCODING] != "b" || params[:VALUE] == "uri")
          parse_err(strict, errors, "mandatory parameter of :ENCODING missing for #{prop}", ctx) if !params.has_key?(:ENCODING) && (!params.key?(:VALUE) || params[:VALUE] == "binary")
          # TODO restriction of :TYPE to image types registered with IANA
          # TODO restriction of :TYPE to sound types registered with IANA
        when :BDAY, :REV
          params.each_key do |key|
            parse_err(strict, errors, "illegal parameter #{key} given for #{prop}", ctx) unless key == :VALUE
          end
          parse_err(strict, errors, "illegal value #{params[:VALUE]} of :VALUE given for #{prop}", ctx) if params[:VALUE] && params[:VALUE] != "date" && params[:VALUE] != "date-time"
        when :AGENT
          params.each_key do |key|
            parse_err(strict, errors, "illegal parameter #{key} given for #{prop}", ctx) unless key == :VALUE
          end
          parse_err(strict, errors, "illegal value #{params[:VALUE]} of :VALUE given for #{prop}", ctx) if params[:VALUE] && params[:VALUE] != "uri"
        when :TZ
          # example in definition contradicts spec! Spec says :TZ takes no params at all
          params.each_key do |key|
            parse_err(strict, errors, "illegal parameter #{key} given for #{prop}", ctx) unless key == :VALUE
          end
          parse_err(strict, errors, "illegal value #{params[:VALUE]} of :VALUE given for #{prop}", ctx) if params[:VALUE] && params[:VALUE] != "text"
        else
          params.each_key do |key|
            parse_err(strict, errors, "illegal parameter #{key} given for #{prop}", ctx) unless key == :VALUE || key == :LANGUAGE || key =~ /^x/i
            parse_err(strict, errors, "illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE && val != "ptext"
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
