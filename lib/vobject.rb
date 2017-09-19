module Vobject
  class << self
    MAX_LINE_WIDTH = 75
    def unfold(str)
      str.gsub(/(\r|\n|\r\n)[ \t]/, "")
    end

    # This implements the line folding as specified in
    # http://tools.ietf.org/html/rfc6350#section-3.2
    # NOTE: the "line" here is not including the trailing \n
    def fold_line(line)
      folded_line    = line[0, MAX_LINE_WIDTH]
      remainder_line = line[MAX_LINE_WIDTH, line.length - MAX_LINE_WIDTH] || ""

      max_width = MAX_LINE_WIDTH - 1

      (0..((remainder_line.length - 1) / max_width)).each do |i|
        folded_line << "\n "
        folded_line << remainder_line[i * max_width, max_width]
      end

      folded_line
    end
  end
end
