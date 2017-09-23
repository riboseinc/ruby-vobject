module Vobject
  class PropertyValue
    attr_accessor :value, :type, :errors, :norm

    def <=>(another)
      self.value <=> another.value
    end

    def initialize(val)
      self.value = val
      self.type = "property"
      self.norm = nil
    end

    # raise_invalid_initialization if key != name

    def to_s
      value
    end

    def to_norm
      if norm.nil?
        norm = to_s
      end
      norm
    end

    def to_hash
      value
    end

    def name
      type
    end

    private

    def default_value_type
      "text"
    end

    def raise_invalid_initialization
      raise "vObject property initialization failed"
    end
  end
end
