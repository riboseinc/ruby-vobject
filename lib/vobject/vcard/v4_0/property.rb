require "vobject/property"

module Vcard::V4_0
  class Property < Vobject::Property
  end

  def parameter_base_class
    version_class.const_get(:Parameter)
  end

  def property_base_class
    version_class.const_get(:Property)
  end


  def to_norm_line
    line = group ? "#{group}." : ""
    line << name.to_s.tr("_", "-").upcase

    # add mandatory VALUE param
    outparams = params
    outparams[:VALUE] = value.type

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
