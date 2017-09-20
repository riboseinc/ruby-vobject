module Vobject
  class ParameterValue
    def initialize(val)
      self.value = val
    end
    # raise_invalid_initialization if key != name
  end

  def to_s
    value
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
