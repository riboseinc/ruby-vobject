module Vobject
      	class ParameterValue


    #attr_accessor :group, :prop_name, :params, :value, :multiple

    def initialize val
        self.value = val
     end

      #raise_invalid_initialization if key != name
    end

    def to_s
      self.value
    end

    private

    def name
      prop_name
    end

    def default_value_type
      "text"
    end


    def raise_invalid_initialization
      raise "vObject property initialization failed"
    end


  end

