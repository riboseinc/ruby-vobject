require "vobject/version"

module Vobject

  module Rules

    module ABNF
      IANAToken    = '[a-zA-Z\d\-]+?'
      Cr           = "\u000d"
      Lf           = "\u000a"
      Crlf         = "(#{Cr}|#{Lf})"
      Utf8_tail    = '[\u0080-\u00bf]'
      Utf8_2       = '([\u00c2-\u00df]|' + "#{Utf8_tail})"
      Utf8_3       = '([\u00e0\u00a0-\u00bf\u00e1-\u00ec\u00ed\u0080-\u009f\u00ee-\u00ef]|' + "#{Utf8_tail})"
      Utf8_4       = '([\u00f0\u0090-\u00bf\u00f1-\u00f3\u00f4\u0080-\u008f]|' + "#{Utf8_tail})"
      Wsp          = '[ \t]'
      VChar        = '[\u0021-\u007e]'
      NonASCII     = "(#{Utf8_2}|#{Utf8_3}|#{Utf8_4})"
      QSafeChar    = "(#{Wsp}|" + '[!\u0023-\u007e]' + "|#{NonASCII})"
      SafeChar     = "(#{Wsp}|" + '[!\u0023-\u0039\u003c-\u007e]' + "|#{NonASCII})"
      ValueChar    = "(#{Wsp}|#{VChar}|#{NonASCII})"
      DQuote       = '"'
      PText        = "#{SafeChar}*?"
      QuotedString = "#{DQuote}(#{QSafeChar}*?)#{DQuote}"
      XName        = "[xX]-#{IANAToken}"
      Group        = IANAToken
      Name         = "(#{XName}|#{IANAToken})"
      ParamName    = "(#{XName}|#{IANAToken})"
      ParamValue   = "(#{PText}|#{QuotedString})"
      PValueList   = "(?<head>#{ParamValue})(?<tail>(,#{ParamValue})*)"
      Pid          = '\d+(\.\d+)*'
      PidList      = "(?<head>#{Pid})(?<tail>(,#{Pid})*)"
      Param        = "(?<pname>#{ParamName})=(?<pvalue>#{PValueList})"
      Params       = "(;(?<phead>#{Param}))(?<ptail>(;#{Param})*)"
      Value        = "#{ValueChar}*?"
      LineGroup    = "((?<group>#{Group})" + '\.' + ")?"
      Contentline  = "#{LineGroup}(?<key>#{Name})(?<params>(#{Params})?):(?<value>#{Value})#{Crlf}"
      BeginLine    = "BEGIN:#{IANAToken}#{Crlf}"
      VersionLine  = "VERSION:#{Value}#{Crlf}"
      EndLine      = "END:#{IANAToken}#{Crlf}"
      Vobject      = "#{BeginLine}#{VersionLine}(#{Contentline})+#{EndLine}"
    end

  end

  class << self

    def parse(vobject)
      vobject = unfold(vobject)
      lines   = []
      rule    = "(?<line>#{Rules::ABNF::Contentline})(?<remainder>(#{Rules::ABNF::Contentline})*)"

      parse_for_rule(Rules::ABNF::Vobject, vobject) do |parsed|

        remainder = vobject

        while !remainder.empty?
          parse_for_rule(rule, remainder) do |remainder_parsed|
            lines << remainder_parsed[:line]
            remainder = remainder_parsed[:remainder]
          end
        end
      end

      parse_lines lines
    end

    private

    def unfold(str)
      str.gsub(/#{Rules::ABNF::Crlf}#{Rules::ABNF::Wsp}/, '')
    end

    def parse_lines lines
      lines.each_with_index.reduce([]) do |hash_stack, (line, i)|
        prop = parse_line(line)

        if prop.has_key?(:BEGIN)
          comp = prop[:BEGIN][:value].to_sym
          hash = { comp => [] }
          next hash_stack << hash
        end

        if prop.has_key?(:END)
          hash = hash_stack.pop
          comp = hash.keys.first

          raise_invalid_parsing if comp != prop[:END][:value].to_sym

          prev_hash = hash_stack.last

          raise_invalid_parsing if !prev_hash && i != lines.length - 1

          return hash unless prev_hash

          prev_hash[prev_hash.keys.first] << hash

          next hash_stack
        end

        prev_hash = hash_stack.last

        prev_hash[prev_hash.keys.first] << prop
        hash_stack
      end
    end

    def parse_line(line)
      parse_for_rule(Rules::ABNF::Contentline, unfold(line)) do |parsed|
        key = parsed[:key].to_sym

        group = parsed[:group]
        params = parse_params(parsed[:params])
        value = parsed[:value]

        hash = { key => {} }
        hash[key][:group] = group if group
        hash[key][:params] = params if !params.empty?
        hash[key][:value] = value

        hash
      end
    end

    def parse_params(params_str)
      params = {}

      while !params_str.empty?
        parse_for_rule(Rules::ABNF::Params, params_str) do |parsed|

          parse_for_rule(Rules::ABNF::Param, parsed[:phead]) do |param_parsed|
            pname  = param_parsed[:pname].to_sym
            pvalue = param_parsed[:pvalue].sub(
              Regexp.new("^#{Rules::ABNF::QuotedString}$"),
              '\1'
            )

            pvalue.gsub!(/\\n/, "\n")

            params[pname] = if params[pname]
              "#{params[pname]},#{pvalue}"
            else
              pvalue
            end
          end

          params_str = parsed[:ptail]
        end
      end

      params
    end

    #Method: parse_for_rule
    #Parameter: String containing the regular expression, String to be parsed
    #and optional block to indicate whether to yield the resulting hash
    #Return: a hash with keys indicating their regex names
    def parse_for_rule(rule, str, &block)
      matched = /\A#{rule}\Z/.match(str)

      raise_invalid_parsing unless matched

      parsed = matched.names.reduce({}) do |parsed_hash, name|
        #can we reduce memory consumption by only creating Keys whose value is not nil?
        parsed_hash[name.to_sym] = matched[name.to_sym] if matched[name.to_sym]
        #parsed_hash[name.to_sym] = matched[name.to_sym]
        parsed_hash
      end

      return yield(parsed) if block

      parsed
    end

    def raise_invalid_parsing
      raise "VObject parse failed"
    end

  end

end

