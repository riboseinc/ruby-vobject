
  class Vobject::Parameter

    MAX_LINE_WIDTH = 75

    attr_accessor :param_name, :value, :multiple

    def initialize key, options
      if options.class == Array 
	self.multiple = []
	options.each {|v|
          self.multiple << parameter_base_class.new(key, v)
          self.param_name = key
	}
      else
        self.param_name = key
        self.value = options
     end

      raise_invalid_initialization if key != name
    end

    def to_s
      line = "#{param_name}"

      line << ":#{value}"

      line = fold_line(line) << "\n"

      line
    end

  def to_hash
    a = {}
    if self.multiple
        val = []
        self.multiple.each do |c|
            val << c.value
        end
        return {param_name => val}
    else
        return {param_name => value}
    end
  end

    private

    def name
      param_name
    end

    def parse_value value
      parse_method = :"parse_#{value_type}_value"
      parse_method = respond_to?(parse_method, true) ? parse_method : :parse_text_value
      send(parse_method, value)
    end

    def parse_text_value value
      value
    end

    def value_type
      (params || {})[:VALUE] || default_value_type
    end

    def default_value_type
      "text"
    end

          def parameter_base_class
		                Vobject::Parameter
	  end


    def raise_invalid_initialization
      raise "vObject property initialization failed"
    end

    # This implements the line folding as specified in
    # http://tools.ietf.org/html/rfc6350#section-3.2
    #
    # NOTE: the "line" here is not including the trailing \n
    def fold_line(line)
      folded_line    = line[0, MAX_LINE_WIDTH]
      remainder_line = line[MAX_LINE_WIDTH, line.length - MAX_LINE_WIDTH] || ''

      max_width = MAX_LINE_WIDTH - 1

      for i in 0..((remainder_line.length - 1) / max_width)
        folded_line << "\n "
        folded_line << remainder_line[i * max_width, max_width]
      end

      folded_line
    end

  end

