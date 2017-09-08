require 'vobject'

module Vobject
module Vcalendar
module PropertyValue
      	class Text << Vobject::PropertyValue

    def initialize val
        self.value = val
        self.type = 'text'
    end

      #raise_invalid_initialization if key != name
    end

    def to_s
      self.value
    end

    private

end
end
end
