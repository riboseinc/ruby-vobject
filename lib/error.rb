# expand error reporting of Rsec
module Rsec
	class ParseContext
		def report_error msg, source
			#expand generate_error
      if self.pos <= @last_fail_pos
        line = line @last_fail_pos
        col = col @last_fail_pos
        line_text = line_text @last_fail_pos
        expect_tokens = Fail.get_tokens @last_fail_mask
        expects = ", expect token [ #{expect_tokens.join ' | '} ]"
      else
        line = line pos
        col = col pos
        line_text = line_text pos
        expects = nil
      end
      msg = "#{msg}\nin #{source}:#{line} at #{col}#{expects}"
      SyntaxError.new msg, line_text, line, col
		end
	end
end
