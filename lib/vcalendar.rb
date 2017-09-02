require 'vobject/vcalendar/typegrammars'
require 'vobject/vcalendar/grammar'
require 'vobject/component'


class Vcalendar < Vobject::Component

  attr_accessor :version

  class << self


    private
    
    def raise_invalid_parsing
      raise "iCal parse failed"
    end
  end

  def parse(vcf)
      return Vobject::Component::Vcalendar.parse(vcf)
  end

  def initialize version
    super :VCALENDAR, {:VERSION => {:value => version}}
  end
  
  private
  
  def name
    :VCALENDAR
  end
  
  
end
