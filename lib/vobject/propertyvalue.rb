module Vobject
  class PropertyValue


    attr_accessor :value, :type, :errors

    def initialize val
      self.value = val
      self.type = 'property'
    end

    #raise_invalid_initialization if key != name

    def to_s
      self.value
    end

    def to_hash
      self.value
    end

    def name
      self.type
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
