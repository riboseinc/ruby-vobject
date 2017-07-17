require 'vobject/typegrammars'
require 'vobject/grammar'
require 'vobject/component'

module Vobject

class << self

  def parse(vcf)
      return Vobject::Component.parse(vcf)
  end

#	 include Vobject::Typegrammars
#	 include Vobject::Grammar
end
end
