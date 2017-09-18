# Vobject

The main purpose of the gem is to parse vobject formatted text into a ruby
hash format. Currently there are two possiblities of vobjects, namely
iCalendar (https://tools.ietf.org/html/rfc5545) and vCard
(https://tools.ietf.org/html/rfc6350). There are only a few differences
between the iCalendar and vCard format. Only vCard supports grouping
feature, and currently vCard does not have any sub-object supported.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby-vobject'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby-vobject

## Usage

```
require 'vcalendar'
require 'JSON'
require 'pp'

ics = File.read "spec/examples/vcalendar/timezones/America/Denver.ics"
# parse VCalendar into native object structure, with strict validation (crashes on any error)
pp Vcalendar.parse(ics, true)
# parse VCalendar into native object structure, without strict validation (errors other than syntax errors are tracked)
pp Vcalendar.parse(ics, false)
# list any errors
pp Vcalendar.parse(ics, false).get_errors
# convert VCalendar into Ruby hash
pp Vcalendar.parse(ics).to_hash
# convert VCalendar into JSON
pp JSON.parse(Vcalendar.parse(ics).to_json)
# convert VCalendar into VCalendar text
print Vcalendar.parse(ics).to_s
```

```
require 'vcard'
require 'JSON'
require 'pp'

vcf = File.read "spec/examples/vcard/vcard3.vcf"
# parse Vcard into native object structure (version 3), strict vslidation
pp Vcard.parse(vcf, '3.0', true)
# parse Vcard into Ruby hash
pp Vcard.parse(vcf, '3.0', true).to_hash
# parse Vcard into JSON
pp JSON.parse(Vcard.parse(vcf, '3.0', true).to_json)
# parse Vcard into VCard text
print Vcard.parse(vcf, '3.0', true).to_s
vcf = File.read "spec/examples/vcard/example61.vcf"
# parse Vcard into native object structure (version 4), lax vslidation
pp Vcard.parse(vcf, '4.0', false)
# list anu errors
pp Vcard.parse(vcf, '4.0', false).get_errors

```

* Recognises all of VCard v3.0, Vcard v4.0, and Vcalendar v2.0
* Components, properties, and parameters are all objects.
  * Each type of component is a distinct object.
* The parameters of a property are represented as an array of parameter objects.
* If a property has multiple values, given on separate lines, they are represented
as an array of value properties. Each value hash may have its own parameters.
* The values of properties are also typed objects.
* Objects can be parsed from text files.
* Objects can be populated from hashes of property value objects.
* Objects can be converted to Ruby hashes with native property value types (`.to_hash`), JSON objects with the same value types (`.to_json`), and round-tripped back to ICAL/VCARD string representations (`.to_s`)
* Validation can be strict or lax. 
  * If strict, an exception is raised on any syntax error, type mismatch, or other mismatch to the specification, such as mandatory elements.
  * If lax, an exception is still raised on syntax errors, but other issues are listed in an error field of the resulting object.

Running spec:
bundle exec rspec

## Implementation

This gem is implemented using [Rsec](https://github.com/luikore/rsec), a very fast PEG grammar based on StringScanner.

## Coverage

This tool is intended as a reference implementation, and it is very strict in its conformance: it requires all rules for parameter coocurrence, 
property typing, parameter typing, permitted properties within components, etc to be met by objects. 

The tool only parses one object at a time, and does not parse Vobject streams.

This tool supports v2.0 iCal as specified in RFC 5545, and as updated in RFC 5546 (registry for values of METHOD and REQUEST-STATUS),
RFC 6868 (caret escapes for parameter values), RFC 7529 (non-Gregorian Calendars), RFC 7953 (VAVAILABILITY component), and
RFC 7986 (new properties).

This tool supports v3.0 vCard as specified in RFC 2425 and RFC 2426, and as updated in RFC 2739 (calendar attributes) and RFC 4770 (extensions for Instant Messaging). It allows for the VCARD 2.1 style specification of PREF parameters in RFC 2739.

This tool supports v4.0 vCard as specified in RFC 6350, and as updated in RFC 6868 (parameter encoding), RFC 6474 (place of birth, place and date of death), RFC 6715 (OMA CAB extensions), and RF 6473 (KIND:application).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/riboseinc/ruby-vobject. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

