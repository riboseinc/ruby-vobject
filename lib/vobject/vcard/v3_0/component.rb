require "vobject/component"
require "vobject/vcard/v3_0/property"
require "vobject/vcard/v3_0/grammar"
require "pp"

module Vcard::V3_0

  class Component < Vobject::Component

    class << self

      def parse(vcf, strict)
        hash = Vcard::V3_0::Grammar.new(strict).parse(vcf)
        comp_name = hash.keys.first
        ret = self.new comp_name, hash[comp_name], hash[:errors]
      end


      private

      def raise_invalid_parsing
        raise "vCard parse failed"
      end

    end

    def encode version
      return self.to_s
    end

    private

    def property_base_class
      version_class.const_get(:Property)
    end

    def component_base_class
      version_class.const_get(:Component)
    end

    def parameter_base_class
      version_class.const_get(:Parameter)
    end

    def version_class
      Vcard::V3_0
    end

  end

end
