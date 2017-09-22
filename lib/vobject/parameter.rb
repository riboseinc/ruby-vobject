module Vobject
  class Parameter
    attr_accessor :param_name, :value, :multiple

    def <=>(another)
      self.to_norm <=> another.to_norm
    end

    def initialize(key, options)
      self.param_name = key
      if options.class == Array
        self.multiple = []
        options.each do |v|
          multiple << parameter_base_class.new(key, v)
          self.param_name = key
        end
      else
        self.value = options
      end

      raise_invalid_initialization(key, name) if key != name
    end

    def to_s
      # we made param names have underscore instead of dash as symbols
      line = param_name.to_s.tr("_", "-")
      line << "="
      if multiple
        arr = []
        multiple.each { |v| arr << to_s_line(v.value.to_s) }
        line << arr.join(",")
      else
        line << to_s_line(value.to_s)
      end
      line
    end

    def to_s_line(val)
      # RFC 6868
      val = val.to_s.gsub(/\^/, "^^").gsub(/\n/, "^n").gsub(/"/, "^'")
      if val =~ /[:;,]/
        val = '"' + val + '"'
      end
      val
    end

    def to_norm
      line = param_name.to_s.tr("_", "-").upcase
      line << "="
      if multiple
        arr = []
        multiple.sort.each { |v| arr << to_norm_line(v.value) }
        line << arr.join(",")
      else
        line << to_norm_line(value)
      end
      line
    end

    def to_norm_line(val)
      # RFC 6868
      val = val.to_s.gsub(/\^/, "^^").gsub(/\n/, "^n").gsub(/"/, "^'")
      #if val =~ /[:;,]/
      val = '"' + val + '"'
      #end
      val
    end

    def to_hash
      if multiple
        val = []
        multiple.each do |c|
          val << c.value
        end
        { param_name => val }
      else
        { param_name => value }
      end
    end

    private

    def name
      param_name
    end

    def parse_value(value)
      parse_method = :"parse_#{value_type}_value"
      parse_method = respond_to?(parse_method, true) ? parse_method : :parse_text_value
      send(parse_method, value)
    end

    def parse_text_value(value)
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
