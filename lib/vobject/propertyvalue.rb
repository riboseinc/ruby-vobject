module Vobject
      	class PropertyValue


    #attr_accessor :group, :prop_name, :params, :value, :multiple

    def initialize val
        self.value = val
        self.type = 'property'
     end

      #raise_invalid_initialization if key != name
    end

    def to_s
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

