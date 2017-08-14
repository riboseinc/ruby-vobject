require 'vobject/typegrammars'
require 'vobject/grammar'
require 'vobject/component'

module Vobject

class Vcalendar < Vobject::Component

  attr_accessor :version

  class << self


    private
    
    def raise_invalid_parsing
      raise "iCal parse failed"
    end
  end

  def parse(vcf)
      return Vobject::Component.parse(vcf)
  end

  def initialize version
    super :VCALENDAR, {:VERSION => {:value => version}}
  end
  
  private
  
  def name
    :VCALENDAR
  end
  
  
end
end
