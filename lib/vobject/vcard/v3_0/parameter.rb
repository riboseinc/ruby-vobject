require "vobject/parameter"

module Vcard::V3_0

  class Parameter < Vobject::Parameter

    def parameter_base_class
      version_class.const_get(:Parameter)
    end

    def property_base_class
      version_class.const_get(:Property)
    end


    def version_class
      Vcard::V3_0
    end


  end

end
