require "rsec"
require "set"
require "uri"
require "date"
require "tzinfo"
require 'vobject/typegrammars'
require 'vobject/grammar'

module Vobject

 # definitions common to classes
 class Def
    attr_reader :boolean, :ianaToken, :xname
    @boolean     = /TRUE/i.r | /FALSE/i.r
    @ianaToken  = /[a-zA-Z\d\-]+/.r
    vendorid   = /[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]/.r
    @xname      = seq( '[xX]-', vendorid, '-', @ianaToken)


#	 include Vobject::Typegrammars
#	 include Vobject::Grammar
  end
end
