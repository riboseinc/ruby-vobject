require 'spec_helper'
require 'pp'
require 'json'
require 'rsec'

# Some examples taken from https://github.com/mozilla-comm/ical.js/

# unfold lines, and capitalise in order to avoid discrepancies in logical capitalisation
def normalise(ics)
	ics.gsub(/\n /,'').upcase
end

describe Vobject do

=begin
  it 'should parse vCard properly' do
    vcf = File.read "spec/examples/example1.vcf"
    vobj_json = Vcalendar.parse(vcf).to_json
    exp_json = JSON.load(File.read "spec/examples/example1.json")
    expect(vobj_json).to include_json(exp_json)
  end
=end

  it 'should process RFC6868 caret parameters' do
    ics = File.read "spec/examples/caretparams.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/caretparams.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should recognise RFC7529 calendar recurrences' do
    ics = File.read "spec/examples/recur_RFC7529.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/recur_RFC7529.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD for RFC6868 caret parameters' do
    ics = File.read "spec/examples/recur_RFC7529.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end
  it 'should recognise VAVAILABILITY component' do
    ics = File.read "spec/examples/availability1.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/availability1.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD for VAVAILABILITY component' do
    ics = File.read "spec/examples/availability1.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end
  it 'should recognise VAVAILABILITY component' do
    ics = File.read "spec/examples/availability2.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/availability2.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD for VAVAILABILITY component' do
    ics = File.read "spec/examples/availability2.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end
  it 'should permit multiple VEVENT components' do
    ics = File.read "spec/examples/availability3.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/availability3.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD for multiple VEVENT components' do
    ics = File.read "spec/examples/availability3.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly 2' do
    ics = File.read "spec/examples/example2.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example2.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD 2' do
    ics = File.read "spec/examples/example2.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly 3' do
    ics = File.read "spec/examples/example3.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example3.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD 3' do
    ics = File.read "spec/examples/example3.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly 4' do
    ics = File.read "spec/examples/example4.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example4.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly 5' do
    ics = File.read "spec/examples/example5.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example5.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD 5' do
    ics = File.read "spec/examples/example5.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly 6' do
    ics = File.read "spec/examples/example6.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example6.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD 6' do
    ics = File.read "spec/examples/example6.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly 7' do
    ics = File.read "spec/examples/example7.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD 7' do
    ics = File.read "spec/examples/example7.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should enforce proper Bin64 encoding' do
    ics = File.read "spec/examples/base64.ics"
    expect { Vcalendar.parse(ics)}.to raise_error(/Malformed binary coding for property ATTACH/)
  end

  it 'should parse iCalendar properly with blank description' do
    ics = File.read "spec/examples/blank_description.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/blank_description.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with blank description' do
    ics = File.read "spec/examples/blank_description.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should require at least one component' do
    ics = File.read "spec/examples/blank_line_end.ics"
    expect { Vcalendar.parse(ics)}.to raise_error(Rsec::SyntaxError)
  end

  it 'should reject blank lines' do
    ics = File.read "spec/examples/blank_line_mid.ics"
    expect { Vcalendar.parse(ics)}.to raise_error(Rsec::SyntaxError)
  end

  it 'should reject spurious boolean value' do
    ics = File.read "spec/examples/boolean.ics"
    expect { Vcalendar.parse(ics)}.to raise_error(/Type mismatch for property X_MAYBE/)
  end

  it 'should process VALUE:BOOLEAN' do
    ics = File.read "spec/examples/boolean1.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/boolean1.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with VALUE:BOOLEAN' do
    ics = File.read "spec/examples/boolean1.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should allow repeated components' do
    ics = File.read "spec/examples/component.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/component.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with repeated components' do
    ics = File.read "spec/examples/component.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly with Daily Recur' do
    ics = File.read "spec/examples/daily_recur.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/daily_recur.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with Daily Recur' do
    ics = File.read "spec/examples/daily_recur.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly with Dates' do
    ics = File.read "spec/examples/dates.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/dates.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with Dates' do
    ics = File.read "spec/examples/dates.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly with Day Long Recur Yearly' do
    ics = File.read "spec/examples/day_long_recur_yearly.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/day_long_recur_yearly.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with Day Long Recur Yearly' do
    ics = File.read "spec/examples/day_long_recur_yearly.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly with Duration instead of DTEND' do
    ics = File.read "spec/examples/duration_instead_of_dtend.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/duration_instead_of_dtend.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with Duration instead of DTEND' do
    ics = File.read "spec/examples/duration_instead_of_dtend.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should process VALUE:FLOAT' do
    ics = File.read "spec/examples/float.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/float.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with VALUE:FLOAT' do
    ics = File.read "spec/examples/float.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should reject spurious float value' do
    ics = File.read "spec/examples/float1.ics"
    expect { Vcalendar.parse(ics)}.to raise_error(/Type mismatch for property X_INVALID_FLOAT/)
  end

  it 'should parse iCalendar properly with forced types' do
    ics = File.read "spec/examples/forced_types.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/forced_types.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with forced types' do
    ics = File.read "spec/examples/forced_types.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly with Google Birthdays' do
    ics = File.read "spec/examples/google_birthday.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/google_birthday.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with Google Birthdays' do
    ics = File.read "spec/examples/google_birthday.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly with Integers' do
    ics = File.read "spec/examples/integer.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/integer.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with Integers' do
    ics = File.read "spec/examples/integer.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should reject iCalendar Type mismatch for property X_INVALID' do
    ics = File.read "spec/examples/integer1.ics"
    expect { Vcalendar.parse(ics)}.to raise_error(/Type mismatch for property X_INVALID,/)
  end

  it 'should parse Minimal iCalendar properly' do
    ics = File.read "spec/examples/minimal.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/minimal.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with Minimal iCalendar' do
    ics = File.read "spec/examples/minimal.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should not accept concatenated iCal objects [likely to change]' do
    ics = File.read "spec/examples/multiple_root_components.ics"
    expect { Vcalendar.parse(ics)}.to raise_error(Rsec::SyntaxError)  
  end

  it 'should parse iCalendar properly with Multiple RRULE' do
    ics = File.read "spec/examples/multiple_rrules.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/multiple_rrules.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with Multiple RRULE' do
    ics = File.read "spec/examples/multiple_rrules.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly with multiple values' do
    ics = File.read "spec/examples/multivalue.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/multivalue.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly with only DTSTART date' do
    ics = File.read "spec/examples/only_dtstart_date.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/only_dtstart_date.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with only DTSTART date' do
    ics = File.read "spec/examples/only_dtstart_date.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly with only DTSTART time' do
    ics = File.read "spec/examples/only_dtstart_time.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/only_dtstart_time.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with only DTSTART time' do
    ics = File.read "spec/examples/only_dtstart_time.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/parserv2.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/parserv2.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD' do
    ics = File.read "spec/examples/parserv2.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly with periods' do
    ics = File.read "spec/examples/period.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/period.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with periods' do
    ics = File.read "spec/examples/period.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly with property params' do
    ics = File.read "spec/examples/property_params.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/property_params.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should reject quoted value as ROLE paramter value' do
    ics = File.read "spec/examples/property_params1.ics"
    expect { Vcalendar.parse(ics)}.to raise_error(Rsec::SyntaxError)  
  end

  it 'should parse iCalendar properly with quoted params' do
    ics = File.read "spec/examples/quoted_params.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/quoted_params.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with quoted params' do
    ics = File.read "spec/examples/quoted_params.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly with RECUR' do
    ics = File.read "spec/examples/recur.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/recur.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with RECUR' do
    ics = File.read "spec/examples/recur.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly with RECUR instances' do
    ics = File.read "spec/examples/recur_instances.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/recur_instances.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with RECUR instances' do
    ics = File.read "spec/examples/recur_instances.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly with finite RECUR instances' do
    ics = File.read "spec/examples/recur_instances_finite.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/recur_instances_finite.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with finite RECUR instances' do
    ics = File.read "spec/examples/recur_instances_finite.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/rfc.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/rfc.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD' do
    ics = File.read "spec/examples/rfc.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should reject an empty iCalendar' do
    ics = File.read "spec/examples/single_empty_vcalendar.ics"
    expect { Vcalendar.parse(ics)}.to raise_error(Rsec::SyntaxError)
  end

  it 'should parse iCalendar properly with TIME' do
    ics = File.read "spec/examples/time.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/time.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with TIME' do
    ics = File.read "spec/examples/time.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should reject quotation marks in TZID parameter' do
    ics = File.read "spec/examples/tzid_with_quoted_gmt.ics"
    expect { Vcalendar.parse(ics)}.to raise_error(Rsec::SyntaxError)
  end

  it 'should parse iCalendar properly with GMT TZID' do
    ics = File.read "spec/examples/tzid_with_gmt.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/tzid_with_gmt.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with GMT TZID' do
    ics = File.read "spec/examples/tzid_with_gmt.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should reject DTEND property with date that precedes DTBEGIN property' do
    ics = File.read "spec/examples/dtend_before_dtbegin.ics"
    expect { Vcalendar.parse(ics)}.to raise_error(Rsec::SyntaxError)
  end

  it 'should parse iCalendar properly with unfolding properties' do
    ics = File.read "spec/examples/unfold_properties.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/unfold_properties.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with unfolding properties' do
    ics = File.read "spec/examples/unfold_properties.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly with negative zero UTC' do
    ics = File.read "spec/examples/utc_negative_zero.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/utc_negative_zero.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with negative zero UTC' do
    ics = File.read "spec/examples/utc_negative_zero.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly with UTC offset' do
    ics = File.read "spec/examples/utc_offset.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/utc_offset.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD with UTC offset' do
    ics = File.read "spec/examples/utc_offset.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/values.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/values.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD' do
    ics = File.read "spec/examples/values.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should disallow UID in an ALARM component' do
    ics = File.read "spec/examples/spurious_property.ics"
    expect { Vcalendar.parse(ics)}.to raise_error(/Invalid property/)
  end

  it 'should disallow LANGUAGE parameter in a TRIGGER component' do
    ics = File.read "spec/examples/spurious_param.ics"
    expect { Vcalendar.parse(ics)}.to raise_error(/parameter given/)
  end

  it 'should parse iCalendar properly Atikokan.ics' do
    ics = File.read "spec/examples/timezones/America/Atikokan.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/timezones/America/Atikokan.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD Atikokan.ics' do
    ics = File.read "spec/examples/timezones/America/Atikokan.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly Denver' do
    ics = File.read "spec/examples/timezones/America/Denver.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/timezones/America/Denver.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly LA' do
    ics = File.read "spec/examples/timezones/America/Los_Angeles.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/timezones/America/Los_Angeles.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD LA' do
    ics = File.read "spec/examples/timezones/America/Los_Angeles.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly NYC' do
    ics = File.read "spec/examples/timezones/America/New_York.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/timezones/America/New_York.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD NYC' do
    ics = File.read "spec/examples/timezones/America/New_York.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly RDATE_test.ics' do
    ics = File.read "spec/examples/timezones/Makebelieve/RDATE_test.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/timezones/Makebelieve/RDATE_test.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD RDATE_test.ics' do
    ics = File.read "spec/examples/timezones/Makebelieve/RDATE_test.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly RDATE_utc_test.ics' do
    ics = File.read "spec/examples/timezones/Makebelieve/RDATE_utc_test.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/timezones/Makebelieve/RDATE_utc_test.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD RDATE_utc_test.ics' do
    ics = File.read "spec/examples/timezones/Makebelieve/RDATE_utc_test.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

  it 'should parse iCalendar properly RRULE_UNTIL_test.ics' do
    ics = File.read "spec/examples/timezones/Makebelieve/RRULE_UNTIL_test.ics"
    vobj_json = Vcalendar.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/timezones/Makebelieve/RRULE_UNTIL_test.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should roundtrip VCARD RRULE_UNTIL_test.ics' do
    ics = File.read "spec/examples/timezones/Makebelieve/RRULE_UNTIL_test.ics"
    roundtrip = Vcalendar.parse(ics).to_s
    expect(normalise(roundtrip)).to eql(normalise(ics))
  end

end
