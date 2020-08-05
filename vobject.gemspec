# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vobject/version"

Gem::Specification.new do |spec|
  spec.name          = "vobject"
  spec.version       = Vobject::VERSION
  spec.authors       = ['Ribose Inc.']
  spec.email         = ['open.source@ribose.com']

  spec.summary       = "Parses iCalendar or vCard in Ruby."
  spec.description   = "Parse vObject formats: iCalendar (RFC 5545), vCard {3,4} (RFC 6350)."
  spec.homepage      = "https://github.com/riboseinc/ruby-vobject"
  spec.license       = "BSD-2-Clause"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-json_expectations"
  spec.add_development_dependency "byebug"
  spec.add_runtime_dependency "rsec", "~> 1.0"
  spec.add_runtime_dependency "tzinfo"
  spec.add_runtime_dependency "tzinfo-data"
end
