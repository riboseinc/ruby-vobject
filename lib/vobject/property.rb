require 'vobject/parameter'



  class Vobject::Property

    MAX_LINE_WIDTH = 75

    attr_accessor :group, :prop_name, :params, :value, :multiple

    def initialize key, options
      if options.class == Array 
	self.multiple = []
	options.each {|v|
          self.multiple << property_base_class.new(key, v)
          self.prop_name = key
	}
      else
        self.group = options[:group]
        self.prop_name = key
	unless options[:params].nil? or options[:params].empty?
		self.params = []
		options[:params].each {|k, v|
			self.params << parameter_base_class.new(k, v)
		}
	end
        #self.params = options[:params]
        self.value = parse_value(options[:value])
     end

      raise_invalid_initialization if key != name
    end

    def to_s
      line = group ? "#{group}." : ""
      line << "#{name}"

      (params || {}).each do |pname, pvalue|
        pvalue.to_s.gsub!(/\n/, '\n')

        line << ";#{pname}=#{pvalue}"
      end

      line << ":#{value}"

      line = fold_line(line) << "\n"

      line
    end

  def to_hash
    ret = {}
    if multiple
	    ret[prop_name] = []
	    multiple.each do |c|
		    ret[prop_name] = ret[prop_name] << c.to_hash[prop_name]
	    end
    else
        ret[prop_name][:group] = group unless group.nil?
        ret = {prop_name => {:value => value }}
        if params
            ret[prop_name][:params] = {}
            params.each do |p|
		    ret[prop_name][:params] = ret[prop_name][:params].merge p.to_hash
            end
	end
    end
    return ret
  end


    private

    def name
      prop_name
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
      #(params || {})[:VALUE] || default_value_type
	params ? params[0].value : default_value_type
    end

    def default_value_type
      "text"
    end

      def property_base_class
	      Vobject::Property
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

