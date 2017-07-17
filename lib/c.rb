require "rsec"
require "set"
require "uri"

module C

 # definitions common to classes
 class Def
	 
    class << self
    def boolean     
	    ( /TRUE/i.r | /FALSE/i.r )
    end
    def ianaToken  
	    /[a-zA-Z\d\-]+/.r
    end
    def xname
    	vendorid   = /[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]/.r
    	seq( '[xX]-', vendorid, '-', ianaToken)
    end
    

  end
end
end
