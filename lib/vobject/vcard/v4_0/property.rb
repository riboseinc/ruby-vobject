require "vobject/property"
require "vobject/parameter"
require "pp"

module Vcard::V4_0
  class Property < Vobject::Property
=begin
    def parameter_base_class
      version_class.const_get(:Parameter)
    end
=end

    def property_base_class
      version_class.const_get(:Property)
    end

=begin
    def to_norm
      puts "XXX"
      if norm.nil?
        if multiple.nil? || multiple.empty?
          ret = to_norm_line
        else
          arr = []
          multiple.sort.each do |x|
            arr << x.to_norm_line
          end
          ret = arr.join("")
        end
        norm = ret
      end
      norm
    end
=end

    def to_norm_line
      line = group ? "#{group}." : ""
      line << name.to_s.tr("_", "-").upcase

      # add mandatory VALUE param
      outparams = params
      if outparams.nil?
        outparams = []
      end
      outparams = outparams.select { |p| p.param_name != :VALUE }
      outparams << Vobject::Parameter.new(:VALUE, value.type)

      (outparams || {}).sort.each do |p|
        line << ";#{p.to_norm}"
      end

      line << ":#{value.to_norm}"

      line = Vobject::fold_line(line) << "\n"

      line
    end

    def version_class
      Vcard::V4_0
    end
  end
end
