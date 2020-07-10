# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vobject/version"

Gem::Specification.new do |spec|
  spec.name          = "ruby-vobject"
  spec.version       = Vobject::VERSION
  spec.authors       = ["Peter Tam", "Nick Nicholas"]
  spec.email         = ["peter.tam@ribose.com", "opoudjis@gmail.com"]
  spec.platform      = Gem::Platform.local
  spec.require_paths = ["lib"]

  spec.summary       = "Parse iCalendar or vCard into a ruby hash."
  spec.description   = "The main purpose of the gem is to parse vobject formatted text into a ruby
hash format. Currently there are two possiblities of vobjects, namely
iCalendar (https://tools.ietf.org/html/rfc5545) and vCard
(https://tools.ietf.org/html/rfc6350)."
  spec.homepage      = "https://github.com/riboseinc/ruby-vobject"
  spec.license       = "BSD-2-Clause"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-json_expectations"
  spec.add_development_dependency "byebug"

  spec.add_runtime_dependency "rsec", "~> 0.4"
  spec.add_runtime_dependency "tzinfo"
end
