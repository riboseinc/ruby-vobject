require 'spec_helper'
require 'pp'
require 'json'
require 'rsec'

# Some examples taken from https://github.com/mozilla-comm/ical.js/

describe Vobject do

=begin
  it 'should parse vCard properly' do
    vcf = File.read "spec/examples/example1.vcf"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(vcf).to_json
    exp_json = JSON.load(File.read "spec/examples/example1.json")
    expect(vobj_json).to include_json(exp_json)
  end
=end

  it 'should process RFC6868 caret parameters' do
    ics = File.read "spec/examples/caretparams.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/caretparams.json")
    expect(vobj_json).to include_json(exp_json)
  end
  it 'should recognise RFC7529 calendar recurrences' do
    ics = File.read "spec/examples/recur_RFC7529.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/recur_RFC7529.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should recognise VAVAILABILITY component' do
    ics = File.read "spec/examples/availability1.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/availability1.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should recognise VAVAILABILITY component' do
    ics = File.read "spec/examples/availability2.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/availability2.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/example2.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example2.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/example3.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example3.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/example4.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example4.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/example5.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example5.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/example6.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example6.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/example7.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should enforce proper Bin64 encoding' do
    ics = File.read "spec/examples/base64.ics"
    expect { Vobject::Vcalendar.new('2.0').parse(ics)}.to raise_error(/Malformed binary coding for property ATTACH/)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/blank_description.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/blank_description.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should require at least one component' do
    ics = File.read "spec/examples/blank_line_end.ics"
    expect { Vobject::Vcalendar.new('2.0').parse(ics)}.to raise_error(Rsec::SyntaxError)
  end

  it 'should reject blank lines' do
    ics = File.read "spec/examples/blank_line_mid.ics"
    expect { Vobject::Vcalendar.new('2.0').parse(ics)}.to raise_error(Rsec::SyntaxError)
  end

  it 'should reject spurious boolean value' do
    ics = File.read "spec/examples/boolean.ics"
    expect { Vobject::Vcalendar.new('2.0').parse(ics)}.to raise_error(/Type mismatch for property X_MAYBE/)
  end

  it 'should process VALUE:BOOLEAN' do
    ics = File.read "spec/examples/boolean1.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/boolean1.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should allow repeated components' do
    ics = File.read "spec/examples/component.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/component.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/daily_recur.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/daily_recur.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/dates.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/dates.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/day_long_recur_yearly.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/day_long_recur_yearly.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/duration_instead_of_dtend.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/duration_instead_of_dtend.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should process VALUE:FLOAT' do
    ics = File.read "spec/examples/float.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/float.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should reject spurious float value' do
    ics = File.read "spec/examples/float1.ics"
    expect { Vobject::Vcalendar.new('2.0').parse(ics)}.to raise_error(/Type mismatch for property X_INVALID_FLOAT/)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/forced_types.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/forced_types.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/google_birthday.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/google_birthday.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/integer.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/integer.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/integer1.ics"
    expect { Vobject::Vcalendar.new('2.0').parse(ics)}.to raise_error(/Type mismatch for property X_INVALID,/)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/minimal.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/minimal.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should not accept concatenated iCal objects [likely to change]' do
    ics = File.read "spec/examples/multiple_root_components.ics"
    expect { Vobject::Vcalendar.new('2.0').parse(ics)}.to raise_error(Rsec::SyntaxError)  
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/multiple_rrules.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/multiple_rrules.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/multivalue.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/multivalue.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should reject initial newlines' do
    ics = File.read "spec/examples/newline_junk.ics"
    expect { Vobject::Vcalendar.new('2.0').parse(ics)}.to raise_error(Rsec::SyntaxError)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/only_dtstart_date.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/only_dtstart_date.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/only_dtstart_time.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/only_dtstart_time.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/parserv2.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/parserv2.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/period.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/period.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/property_params.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/property_params.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should reject quoted value as ROLE paramter value' do
    ics = File.read "spec/examples/property_params1.ics"
    expect { Vobject::Vcalendar.new('2.0').parse(ics)}.to raise_error(Rsec::SyntaxError)  
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/quoted_params.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/quoted_params.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/recur.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/recur.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/recur_instances.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/recur_instances.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/recur_instances_finite.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/recur_instances_finite.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/rfc.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/rfc.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should reject an empty iCalendar' do
    ics = File.read "spec/examples/single_empty_vcalendar.ics"
    expect { Vobject::Vcalendar.new('2.0').parse(ics)}.to raise_error(Rsec::SyntaxError)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/time.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/time.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should reject quotation marks in TZID parameter' do
    ics = File.read "spec/examples/tzid_with_quoted_gmt.ics"
    expect { Vobject::Vcalendar.new('2.0').parse(ics)}.to raise_error(Rsec::SyntaxError)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/tzid_with_gmt.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/tzid_with_gmt.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should reject DTEND property with date that precedes DTBEGIN property' do
    ics = File.read "spec/examples/dtend_before_dtbegin.ics"
    expect { Vobject::Vcalendar.new('2.0').parse(ics)}.to raise_error(Rsec::SyntaxError)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/unfold_properties.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/unfold_properties.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/utc_negative_zero.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/utc_negative_zero.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/utc_offset.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/utc_offset.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/values.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/values.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should disallow UID in an ALARM component' do
    ics = File.read "spec/examples/spurious_property.ics"
    expect { Vobject::Vcalendar.new('2.0').parse(ics)}.to raise_error(/Invalid property/)
  end

  it 'should disallow LANGUAGE parameter in a TRIGGER component' do
    ics = File.read "spec/examples/spurious_param.ics"
    expect { Vobject::Vcalendar.new('2.0').parse(ics)}.to raise_error(/parameter given/)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/timezones/America/Atikokan.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/timezones/America/Atikokan.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/timezones/America/Denver.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/timezones/America/Denver.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/timezones/America/Los_Angeles.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/timezones/America/Los_Angeles.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/timezones/America/New_York.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/timezones/America/New_York.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/timezones/Makebelieve/RDATE_test.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/timezones/Makebelieve/RDATE_test.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/timezones/Makebelieve/RDATE_utc_test.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/timezones/Makebelieve/RDATE_utc_test.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/timezones/Makebelieve/RRULE_UNTIL_test.ics"
    vobj_json = Vobject::Vcalendar.new('2.0').parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/timezones/Makebelieve/RRULE_UNTIL_test.json")
    expect(vobj_json).to include_json(exp_json)
  end

end
