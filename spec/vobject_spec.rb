require 'spec_helper'
require 'pp'
require 'json'
require 'rsec'

describe Vobject do

=begin
  it 'should parse vCard properly' do
    vcf = File.read "spec/examples/example1.vcf"
    vobj_json = Vobject.parse(vcf).to_json
    exp_json = JSON.load(File.read "spec/examples/example1.json")
    expect(vobj_json).to include_json(exp_json)
  end
=end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/example2.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example2.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/example3.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example3.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/example4.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example4.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/example5.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example5.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/example6.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example6.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/example7.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should enforce proper Bin64 encoding' do
    ics = File.read "spec/examples/base64.ics"
    expect { Vobject.parse(ics)}.to raise_error(/Malformed binary coding for property ATTACH/)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/blank_description.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/blank_description.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should require at least one component' do
    ics = File.read "spec/examples/blank_line_end.ics"
    expect { Vobject.parse(ics)}.to raise_error(Rsec::SyntaxError)
  end

  it 'should reject blank lines' do
    ics = File.read "spec/examples/blank_line_mid.ics"
    expect { Vobject.parse(ics)}.to raise_error(Rsec::SyntaxError)
  end

=begin
  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/boolean.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
 puts vobj_json
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/component.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/daily_recur.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/dates.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/day_long_recur_yearly.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/duration_instead_of_dtend.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/float.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/forced_types.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/google_birthday.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/integer.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/minimal.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/multiple_root_components.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/multiple_rrules.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/multivalue.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/newline_junk.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/only_dtstart_date.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/only_dtstart_time.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/parserv2.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/period.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/property_params.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/quoted_params.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/recur.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/recur_instances.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/recur_instances_finite.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/rfc.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/single_empty_vcalendar.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/time.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/tzid_with_gmt.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/unfold_properties.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/utc_negative_zero.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/utc_offset.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/values.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/timezones/America/Atikokan.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/timezones/America/Denver.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/timezones/America/Los_Angeles.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/timezones/America/New_York.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/timezones/Makebelieve/RDATE_test.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/timezones/Makebelieve/RDATE_utc_test.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse iCalendar properly' do
    ics = File.read "spec/examples/timezones/Makebelieve/RRULE_UNTIL_test.ics"
    vobj_json = Vobject.parse(ics).to_json
    exp_json = JSON.load(File.read "spec/examples/example7.json")
    expect(vobj_json).to include_json(exp_json)
  end


=end

end
