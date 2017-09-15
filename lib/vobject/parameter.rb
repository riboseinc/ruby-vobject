module Vobject


  class Parameter

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

      raise_invalid_initialization(key, name) if key != name
    end

    def to_s
      # we made param names have underscore instead of dash as symbols
      line = "#{param_name.to_s.gsub(/_/,'-')}"

      # RFC 6868
      line << "=" + value.to_s.gsub(/\^/,"^^").gsub(/\n/,"^n").gsub(/"/,"^'")

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


    def raise_invalid_initialization(key, name)
      raise "vObject property initialization failed (#{key}, #{name})"
    end

  end

 end
