require 'vobject'
require 'vobject/component'


class Vcard < Vobject::Component

  attr_accessor :version

  class << self

  def blank version
    self.new :VERSION => {:value => version}
  end

  def decode vcard_str, version=nil
	  version_str = version.nil? ? '4.0' : /\nVERSION:([^\n\r]+)/i.match(vcard_str)[1]
	  return self.blank(version_str).parse(vcard_str)
  end

  def parse vcf, version, strict
	  return version == '3.0' ? Vcard::V3_0::Component.parse(vcf, strict) : Vcard::V4_0::Component.parse(vcf, strict)
  end


    private

    def raise_invalid_parsing
      raise "vCard parse failed"
    end

  end

  def encode version
	  return self.to_s
  end

  def initialize version
	  self.version = version
	  super :VCARD, {:VERSION => {:value => version}}
  end

  private

  def name
    :VCARD
  end

  def property_base_class
    self.version == '3.0' ? Vcard::V3_0::Property : Vcard::V4_0::Property
    #version_class.const_get(:Property)
  end

  def component_base_class
    self.version == '3.0' ? Vcard::V3_0::Component : Vcard::V4_0::Component
    #version_class.const_get(:Component)
  end
end

def require_dir(dir)
  base = File.expand_path('../', __FILE__)
  Dir.glob(File.join(base, dir, "**", "*.rb")).each do |path|
    require path.gsub(/\.rb\Z/, '')
  end
end

require 'vobject/vcard/v4_0/component'
require 'vobject/vcard/v4_0/property'
require_dir 'vobject/vcard/v4_0/component'
require_dir 'vobject/vcard/v4_0/property'
require 'vobject/vcard/v3_0/component'
require 'vobject/vcard/v3_0/property'
require_dir 'vobject/vcard/v3_0/component'
require_dir 'vobject/vcard/v3_0/property'
