require "vobject/version"
require 'treetop'


module Vobject
  @base_path = File.expand_path(File.dirname(__FILE__))
  Treetop.load (File.join(@base_path, 'vobject.treetop'))
  @parser = VObjectGrammarParser.new

  class << self

    def parse(vobject)
	    @parser.parse(unfold(vobject)).content
    end

    private

    def unfold(str)
      str.gsub(/[\n\r]+[ \t]+/, '')
    end

    def raise_invalid_parsing
      raise "VObject parse failed"
    end

  end

end

