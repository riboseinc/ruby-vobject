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

Vobject.parse("<ics/vcf file>")

* Components, properties, and parameters are each objects.
* The parameters of a property are represented as an array of parameter objects.
* If a property has multiple values, given on separate lines, they are represented
as an array of value properties. Each value hash may have its own parameters.
* The values of properties are native Ruby types wherever possible
(hashes, dates, integers, doubles).

Example:

A sample ics file (in spec/examples/example2.ics):

```
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//ABC Corporation//NONSGML My Product//EN
BEGIN:VTODO
DTSTAMP:19980130T134500Z
SEQUENCE:2
UID:uid4@example.com
ORGANIZER:mailto:unclesam@example.com
ATTENDEE;PARTSTAT=ACCEPTED:mailto:jqpublic@example.com
ATTENDEE;DELEGATED-TO="mailto:jdoe@example.com","mailto:j
 qpublic@example.com":mailto:jsmith@example.com
DUE:19980415T000000
STATUS:NEEDS-ACTION
SUMMARY:Submit Income Taxes
BEGIN:VALARM
ACTION:AUDIO
TRIGGER:19980403T120000Z
ATTACH;FMTTYPE=audio/basic:http://example.com/pub/audio-
 files/ssbanner.aud
REPEAT:4
DURATION:PT1H
END:VALARM
END:VTODO
END:VCALENDAR
```

Parse the ics file into Ruby hash format:

```ruby
require 'vobject'

ics = File.read "spec/examples/example2.ics"
Vobject.parse(ics)

#<Vobject::Component:0x007fa5711e7468
 @children=
  [#<Vobject::Property:0x007fa5711dfab0
    @group=nil,
    @prop_name=:VERSION,
    @value="2.0">,
   #<Vobject::Property:0x007fa5711df588
    @group=nil,
    @prop_name=:PRODID,
    @value="-//ABC Corporation//NONSGML My Product//EN">,
   #<Vobject::Component:0x007fa5711defe8
    @children=
     [#<Vobject::Property:0x007fa5711dea48
       @group=nil,
       @prop_name=:DTSTAMP,
       @value=1998-01-30 13:45:00 UTC>,
      #<Vobject::Property:0x007fa5711de390
       @group=nil,
       @prop_name=:SEQUENCE,
       @value=2>,
      #<Vobject::Property:0x007fa5711dde40
       @group=nil,
       @prop_name=:UID,
       @value="uid4@example.com">,
      #<Vobject::Property:0x007fa5711dda30
       @group=nil,
       @prop_name=:ORGANIZER,
       @value="mailto:unclesam@example.com">,
      #<Vobject::Property:0x007fa5711dd6c0
       @multiple=
        [#<Vobject::Property:0x007fa5711dd670
          @group=nil,
          @params=
           [#<Vobject::Parameter:0x007fa5711dd620
             @param_name=:PARTSTAT,
             @value="ACCEPTED">],
          @prop_name=:ATTENDEE,
          @value="mailto:jqpublic@example.com">,
         #<Vobject::Property:0x007fa5711dd580
          @group=nil,
          @params=
           [#<Vobject::Parameter:0x007fa5711dd530
             @multiple=
              [#<Vobject::Parameter:0x007fa5711dd4b8
                @param_name=:DELEGATED_TO,
                @value="mailto:jqpublic@example.com">,
               #<Vobject::Parameter:0x007fa5711dd490
                @param_name=:DELEGATED_TO,
                @value="mailto:jdoe@example.com">],
             @param_name=:DELEGATED_TO>],
          @prop_name=:ATTENDEE,
          @value="mailto:jsmith@example.com">],
       @prop_name=:ATTENDEE>,
      #<Vobject::Property:0x007fa5711dd120
       @group=nil,
       @prop_name=:DUE,
       @value=1998-04-15 00:00:00 +1000>,
      #<Vobject::Property:0x007fa5711dce50
       @group=nil,
       @prop_name=:STATUS,
       @value="NEEDS-ACTION">,
      #<Vobject::Property:0x007fa5711dcb80
       @group=nil,
       @prop_name=:SUMMARY,
       @value="Submit Income Taxes">],
    @comp_name=:VTODO>,
   #<Vobject::Component:0x007fa5711dc8d8
    @children=
     [#<Vobject::Property:0x007fa5711dc630
       @group=nil,
       @prop_name=:ACTION,
       @value="AUDIO">,
      #<Vobject::Property:0x007fa5711dc310
       @group=nil,
       @prop_name=:TRIGGER,
       @value=1998-04-03 12:00:00 UTC>,
      #<Vobject::Property:0x007fa5711dc040
       @group=nil,
       @params=
        [#<Vobject::Parameter:0x007fa5711dd968
          @param_name=:FMTTYPE,
          @value="audio/basic">],
       @prop_name=:ATTACH,
       @value="http://example.com/pub/audio-files/ssbanner.aud">,
      #<Vobject::Property:0x007fa5711d7c70
       @group=nil,
       @prop_name=:REPEAT,
       @value=4>,
      #<Vobject::Property:0x007fa5711d77c0
       @group=nil,
       @prop_name=:DURATION,
       @value="PT1H">],
    @comp_name=:VALARM>],
 @comp_name=:VCALENDAR>
```

Running spec:
bundle exec rspec

## Implementation

This gem is implemented using [Rsec](https://github.com/luikore/rsec), a very fast PEG grammar based on StringScanner.

## Development

Some really simple specs have been written. Please make sure they still
pass after migrating into the grammar parser approach. Also, some other
specs such as some special characters as stated in RFC 5545 and 6350
should be tested as well.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/riboseinc/ruby-vobject. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

