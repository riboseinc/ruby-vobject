require "spec_helper"
require "pp"
require "json"
require "rsec"

# Some examples taken from https://github.com/mozilla-comm/ical.js/

# unfold lines, && capitalise in order to avoid discrepancies in
# logical capitalisation
def norm_vcal(ics)
  ics.gsub(/\n /, "").upcase
end

def norm_vcard(ics)
  ics.gsub(/\n[ \t]/, "").gsub(/;+\n/, "\n").gsub(/(\\;)+\\n/, "\\n").upcase.
    gsub(/;TYPE=([^;,\n]+);TYPE=([^;,\n]+);TYPE=([^;,\n]+):/,
         ";TYPE=\\1,\\2,\\3:").
    gsub(/;TYPE=([^,;\n]+);TYPE=([^,;\n]+):/, ";TYPE=\\1,\\2:").
    gsub(/;TYPE="([^"]+)"/, ";TYPE=\\1").split("\n").sort.join("\n")
end

# rubocop:disable LineLength
describe Vobject do
  it "should process RFC6868 caret parameters" do
    ics = File.read "spec/examples/vcalendar/caretparams.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/caretparams.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should normalise iCalendar for RFC6868 caret parameters" do
    ics = File.read "spec/examples/vcalendar/caretparams.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/caretparams.norm.ics"
    expect(vobj_json).to eql(ics2)
  end
  it "should recognise RFC7529 calendar recurrences" do
    ics = File.read "spec/examples/vcalendar/recur_RFC7529.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/recur_RFC7529.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar for RFC7529 calendar recurrences" do
    ics = File.read "spec/examples/vcalendar/recur_RFC7529.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar for RFC7529 calendar recurrences" do
    ics = File.read "spec/examples/vcalendar/recur_RFC7529.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/recur_RFC7529.norm.ics"
    expect(vobj_json).to eql(ics2)
  end
  it "should recognise VAVAILABILITY component" do
    ics = File.read "spec/examples/vcalendar/availability1.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/availability1.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar for VAVAILABILITY component" do
    ics = File.read "spec/examples/vcalendar/availability1.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar for RFC7529 calendar recurrences" do
    ics = File.read "spec/examples/vcalendar/availability1.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/availability1.norm.ics"
    expect(vobj_json).to eql(ics2)
  end
  it "should recognise VAVAILABILITY component" do
    ics = File.read "spec/examples/vcalendar/availability2.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/availability2.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar for VAVAILABILITY component" do
    ics = File.read "spec/examples/vcalendar/availability2.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar for VAVAILABILITY component" do
    ics = File.read "spec/examples/vcalendar/availability2.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/availability2.norm.ics"
    expect(vobj_json).to eql(ics2)
  end
  it "should permit multiple VEVENT components" do
    ics = File.read "spec/examples/vcalendar/availability3.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/availability3.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar for multiple VEVENT components" do
    ics = File.read "spec/examples/vcalendar/availability3.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar for VAVAILABILITY component" do
    ics = File.read "spec/examples/vcalendar/availability3.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/availability3.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly 2" do
    ics = File.read "spec/examples/vcalendar/example2.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/example2.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar 2" do
    ics = File.read "spec/examples/vcalendar/example2.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar 2" do
    ics = File.read "spec/examples/vcalendar/example2.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/example2.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly 3" do
    ics = File.read "spec/examples/vcalendar/example3.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/example3.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar 3" do
    ics = File.read "spec/examples/vcalendar/example3.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar 3" do
    ics = File.read "spec/examples/vcalendar/example3.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/example3.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly 4" do
    ics = File.read "spec/examples/vcalendar/example4.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/example4.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should normalise iCalendar 4" do
    ics = File.read "spec/examples/vcalendar/example4.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/example4.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly 5" do
    ics = File.read "spec/examples/vcalendar/example5.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/example5.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar 5" do
    ics = File.read "spec/examples/vcalendar/example5.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar 5" do
    ics = File.read "spec/examples/vcalendar/example5.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/example5.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly 6" do
    ics = File.read "spec/examples/vcalendar/example6.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/example6.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar 6" do
    ics = File.read "spec/examples/vcalendar/example6.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar 6" do
    ics = File.read "spec/examples/vcalendar/example6.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/example6.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly 7" do
    ics = File.read "spec/examples/vcalendar/example7.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/example7.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar 7" do
    ics = File.read "spec/examples/vcalendar/example7.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar 7" do
    ics = File.read "spec/examples/vcalendar/example7.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/example7.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should enforce proper Bin64 encoding" do
    ics = File.read "spec/examples/vcalendar/base64.ics"
    expect { Vcalendar.parse(ics, true) }.to raise_error(/Malformed binary coding for property ATTACH/)
  end

  it "should parse iCalendar properly with blank description" do
    ics = File.read "spec/examples/vcalendar/blank_description.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/blank_description.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with blank description" do
    ics = File.read "spec/examples/vcalendar/blank_description.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with blank description" do
    ics = File.read "spec/examples/vcalendar/blank_description.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/blank_description.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should require at least one component" do
    ics = File.read "spec/examples/vcalendar/blank_line_end.ics"
    expect { Vcalendar.parse(ics, true) }.to raise_error(Rsec::SyntaxError)
  end

  it "should reject blank lines" do
    ics = File.read "spec/examples/vcalendar/blank_line_mid.ics"
    expect { Vcalendar.parse(ics, true) }.to raise_error(Rsec::SyntaxError)
  end

  it "should reject spurious boolean value" do
    ics = File.read "spec/examples/vcalendar/boolean.ics"
    expect { Vcalendar.parse(ics, true) }.to raise_error(/Type mismatch for property X_MAYBE/)
  end

  it "should process VALUE:BOOLEAN" do
    ics = File.read "spec/examples/vcalendar/boolean1.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/boolean1.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with VALUE:BOOLEAN" do
    ics = File.read "spec/examples/vcalendar/boolean1.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with VALUE:BOOLEAN" do
    ics = File.read "spec/examples/vcalendar/boolean1.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/boolean1.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should allow repeated components" do
    ics = File.read "spec/examples/vcalendar/component.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/component.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with repeated components" do
    ics = File.read "spec/examples/vcalendar/component.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with repeated components" do
    ics = File.read "spec/examples/vcalendar/component.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/component.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly with Daily Recur" do
    ics = File.read "spec/examples/vcalendar/daily_recur.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/daily_recur.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with Daily Recur" do
    ics = File.read "spec/examples/vcalendar/daily_recur.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with Daily Recur" do
    ics = File.read "spec/examples/vcalendar/daily_recur.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/daily_recur.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly with Dates" do
    ics = File.read "spec/examples/vcalendar/dates.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/dates.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with Dates" do
    ics = File.read "spec/examples/vcalendar/dates.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with Dates" do
    ics = File.read "spec/examples/vcalendar/dates.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/dates.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly with Day Long Recur Yearly" do
    ics = File.read "spec/examples/vcalendar/day_long_recur_yearly.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/day_long_recur_yearly.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with Day Long Recur Yearly" do
    ics = File.read "spec/examples/vcalendar/day_long_recur_yearly.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with Day Long Recur Yearly" do
    ics = File.read "spec/examples/vcalendar/day_long_recur_yearly.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/day_long_recur_yearly.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly with Duration instead of DTEND" do
    ics = File.read "spec/examples/vcalendar/duration_instead_of_dtend.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/duration_instead_of_dtend.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with Duration instead of DTEND" do
    ics = File.read "spec/examples/vcalendar/duration_instead_of_dtend.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with Duration instead of DTEND" do
    ics = File.read "spec/examples/vcalendar/duration_instead_of_dtend.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/duration_instead_of_dtend.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should process VALUE:FLOAT" do
    ics = File.read "spec/examples/vcalendar/float.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/float.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with VALUE:FLOAT" do
    ics = File.read "spec/examples/vcalendar/float.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with VALUE:FLOAT" do
    ics = File.read "spec/examples/vcalendar/float.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/float.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should reject spurious float value" do
    ics = File.read "spec/examples/vcalendar/float1.ics"
    expect { Vcalendar.parse(ics, true) }.to raise_error(/Type mismatch for property X_INVALID_FLOAT/)
  end

  it "should parse iCalendar properly with forced types" do
    ics = File.read "spec/examples/vcalendar/forced_types.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/forced_types.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with forced types" do
    ics = File.read "spec/examples/vcalendar/forced_types.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with forced types" do
    ics = File.read "spec/examples/vcalendar/forced_types.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/forced_types.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly with Google Birthdays" do
    ics = File.read "spec/examples/vcalendar/google_birthday.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/google_birthday.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with Google Birthdays" do
    ics = File.read "spec/examples/vcalendar/google_birthday.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with Google Birthdays" do
    ics = File.read "spec/examples/vcalendar/google_birthday.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/google_birthday.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly with Integers" do
    ics = File.read "spec/examples/vcalendar/integer.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/integer.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with Integers" do
    ics = File.read "spec/examples/vcalendar/integer.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with Integers" do
    ics = File.read "spec/examples/vcalendar/integer.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/integer.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should reject iCalendar Type mismatch for property X_INVALID" do
    ics = File.read "spec/examples/vcalendar/integer1.ics"
    expect { Vcalendar.parse(ics, true) }.to raise_error(/Type mismatch for property X_INVALID,/)
  end

  it "should parse Minimal iCalendar properly" do
    ics = File.read "spec/examples/vcalendar/minimal.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/minimal.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with Minimal iCalendar" do
    ics = File.read "spec/examples/vcalendar/minimal.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with Minimal iCalendar" do
    ics = File.read "spec/examples/vcalendar/minimal.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/minimal.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should not accept concatenated iCal objects" do
    ics = File.read "spec/examples/vcalendar/multiple_root_components.ics"
    expect { Vcalendar.parse(ics, true) }.to raise_error(Rsec::SyntaxError)
  end

  it "should parse iCalendar properly with Multiple RRULE" do
    ics = File.read "spec/examples/vcalendar/multiple_rrules.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/multiple_rrules.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with Multiple RRULE" do
    ics = File.read "spec/examples/vcalendar/multiple_rrules.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with Multiple RRULE" do
    ics = File.read "spec/examples/vcalendar/multiple_rrules.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/multiple_rrules.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly with multiple values" do
    ics = File.read "spec/examples/vcalendar/multivalue.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/multivalue.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should normalise iCalendar with multiple values" do
    ics = File.read "spec/examples/vcalendar/multivalue.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/multivalue.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly with only DTSTART date" do
    ics = File.read "spec/examples/vcalendar/only_dtstart_date.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/only_dtstart_date.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with only DTSTART date" do
    ics = File.read "spec/examples/vcalendar/only_dtstart_date.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with only DTSTART date" do
    ics = File.read "spec/examples/vcalendar/only_dtstart_date.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/only_dtstart_date.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly with only DTSTART time" do
    ics = File.read "spec/examples/vcalendar/only_dtstart_time.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/only_dtstart_time.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with only DTSTART time" do
    ics = File.read "spec/examples/vcalendar/only_dtstart_time.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with only DTSTART time" do
    ics = File.read "spec/examples/vcalendar/only_dtstart_time.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/only_dtstart_time.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly" do
    ics = File.read "spec/examples/vcalendar/parserv2.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/parserv2.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar" do
    ics = File.read "spec/examples/vcalendar/parserv2.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with only DTSTART time" do
    ics = File.read "spec/examples/vcalendar/only_dtstart_time.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/only_dtstart_time.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly with periods" do
    ics = File.read "spec/examples/vcalendar/period.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/period.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with periods" do
    ics = File.read "spec/examples/vcalendar/period.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with periods" do
    ics = File.read "spec/examples/vcalendar/period.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/period.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should not allow non-Text characters in xname property with default value of text" do
    ics = File.read "spec/examples/vcalendar/property_params.1.ics"
    expect { Vcalendar.parse(ics, true) }.to raise_error(/Type mismatch for property X_BAZ2, value BAZ;BAR/)
  end
  it "should parse iCalendar properly with property params" do
    ics = File.read "spec/examples/vcalendar/property_params.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/property_params.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should normalise iCalendar with property params" do
    ics = File.read "spec/examples/vcalendar/property_params.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/property_params.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should reject quoted value as ROLE paramter value" do
    ics = File.read "spec/examples/vcalendar/property_params1.ics"
    expect { Vcalendar.parse(ics, true) }.to raise_error(Rsec::SyntaxError)
  end

  it "should parse iCalendar properly with quoted params" do
    ics = File.read "spec/examples/vcalendar/quoted_params.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/quoted_params.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with quoted params" do
    ics = File.read "spec/examples/vcalendar/quoted_params.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with quoted params" do
    ics = File.read "spec/examples/vcalendar/quoted_params.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/quoted_params.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly with RECUR" do
    ics = File.read "spec/examples/vcalendar/recur.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/recur.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with RECUR" do
    ics = File.read "spec/examples/vcalendar/recur.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with RECUR" do
    ics = File.read "spec/examples/vcalendar/recur.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/recur.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly with RECUR instances" do
    ics = File.read "spec/examples/vcalendar/recur_instances.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/recur_instances.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with RECUR instances" do
    ics = File.read "spec/examples/vcalendar/recur_instances.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with RECUR instances" do
    ics = File.read "spec/examples/vcalendar/recur_instances.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/recur_instances.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly with finite RECUR instances" do
    ics = File.read "spec/examples/vcalendar/recur_instances_finite.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/recur_instances_finite.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with finite RECUR instances" do
    ics = File.read "spec/examples/vcalendar/recur_instances_finite.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with finite RECUR instances" do
    ics = File.read "spec/examples/vcalendar/recur_instances_finite.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/recur_instances_finite.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly" do
    ics = File.read "spec/examples/vcalendar/rfc.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/rfc.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar" do
    ics = File.read "spec/examples/vcalendar/rfc.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar" do
    ics = File.read "spec/examples/vcalendar/rfc.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/rfc.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should reject an empty iCalendar" do
    ics = File.read "spec/examples/vcalendar/single_empty_vcalendar.ics"
    expect { Vcalendar.parse(ics, true) }.to raise_error(Rsec::SyntaxError)
  end

  it "should parse iCalendar properly with TIME" do
    ics = File.read "spec/examples/vcalendar/time.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/time.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with TIME" do
    ics = File.read "spec/examples/vcalendar/time.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with TIME" do
    ics = File.read "spec/examples/vcalendar/time.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/time.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should reject quotation marks in TZID parameter" do
    ics = File.read "spec/examples/vcalendar/tzid_with_quoted_gmt.ics"
    expect { Vcalendar.parse(ics, true) }.to raise_error(Rsec::SyntaxError)
  end

  it "should parse iCalendar properly with GMT TZID" do
    ics = File.read "spec/examples/vcalendar/tzid_with_gmt.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/tzid_with_gmt.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with GMT TZID" do
    ics = File.read "spec/examples/vcalendar/tzid_with_gmt.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with GMT TZID" do
    ics = File.read "spec/examples/vcalendar/tzid_with_gmt.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/tzid_with_gmt.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should reject DTEND property with date that precedes DTBEGIN property" do
    ics = File.read "spec/examples/vcalendar/dtend_before_dtbegin.ics"
    expect { Vcalendar.parse(ics, true) }.to raise_error(Rsec::SyntaxError)
  end

  it "should parse iCalendar properly with unfolding properties" do
    ics = File.read "spec/examples/vcalendar/unfold_properties.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/unfold_properties.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with unfolding properties" do
    ics = File.read "spec/examples/vcalendar/unfold_properties.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with unfolding properties" do
    ics = File.read "spec/examples/vcalendar/unfold_properties.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/unfold_properties.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly with negative zero UTC" do
    ics = File.read "spec/examples/vcalendar/utc_negative_zero.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/utc_negative_zero.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with negative zero UTC" do
    ics = File.read "spec/examples/vcalendar/utc_negative_zero.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with negative zero UTC" do
    ics = File.read "spec/examples/vcalendar/utc_negative_zero.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/utc_negative_zero.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly with UTC offset" do
    ics = File.read "spec/examples/vcalendar/utc_offset.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/utc_offset.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar with UTC offset" do
    ics = File.read "spec/examples/vcalendar/utc_offset.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar with UTC offset" do
    ics = File.read "spec/examples/vcalendar/utc_offset.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/utc_offset.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly" do
    ics = File.read "spec/examples/vcalendar/values.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/values.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar" do
    ics = File.read "spec/examples/vcalendar/values.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar" do
    ics = File.read "spec/examples/vcalendar/values.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/values.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should disallow UID in an ALARM component" do
    ics = File.read "spec/examples/vcalendar/spurious_property.ics"
    expect { Vcalendar.parse(ics, true) }.to raise_error(/Invalid property/)
  end

  it "should disallow LANGUAGE parameter in a TRIGGER component" do
    ics = File.read "spec/examples/vcalendar/spurious_param.ics"
    expect { Vcalendar.parse(ics, true) }.to raise_error(/parameter given/)
  end

  it "should parse iCalendar properly Atikokan.ics" do
    ics = File.read "spec/examples/vcalendar/timezones/America/Atikokan.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/timezones/America/Atikokan.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar Atikokan.ics" do
    ics = File.read "spec/examples/vcalendar/timezones/America/Atikokan.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar Atikokan.ics" do
    ics = File.read "spec/examples/vcalendar/timezones/America/Atikokan.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/timezones/America/Atikokan.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly Denver" do
    ics = File.read "spec/examples/vcalendar/timezones/America/Denver.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/timezones/America/Denver.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should normalise iCalendar Denver" do
    ics = File.read "spec/examples/vcalendar/timezones/America/Denver.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/timezones/America/Denver.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly LA" do
    ics = File.read "spec/examples/vcalendar/timezones/America/Los_Angeles.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/timezones/America/Los_Angeles.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar LA" do
    ics = File.read "spec/examples/vcalendar/timezones/America/Los_Angeles.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar LA" do
    ics = File.read "spec/examples/vcalendar/timezones/America/Los_Angeles.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/timezones/America/Los_Angeles.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly NYC" do
    ics = File.read "spec/examples/vcalendar/timezones/America/New_York.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/timezones/America/New_York.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar NYC" do
    ics = File.read "spec/examples/vcalendar/timezones/America/New_York.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar NYC" do
    ics = File.read "spec/examples/vcalendar/timezones/America/New_York.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/timezones/America/New_York.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly RDATE_test.ics" do
    ics = File.read "spec/examples/vcalendar/timezones/Makebelieve/RDATE_test.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/timezones/Makebelieve/RDATE_test.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar RDATE_test.ics" do
    ics = File.read "spec/examples/vcalendar/timezones/Makebelieve/RDATE_test.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar RDATE_test.ics" do
    ics = File.read "spec/examples/vcalendar/timezones/Makebelieve/RDATE_test.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/timezones/Makebelieve/RDATE_test.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly RDATE_utc_test.ics" do
    ics = File.read "spec/examples/vcalendar/timezones/Makebelieve/RDATE_utc_test.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/timezones/Makebelieve/RDATE_utc_test.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar RDATE_utc_test.ics" do
    ics = File.read "spec/examples/vcalendar/timezones/Makebelieve/RDATE_utc_test.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar RDATE_utc_test.ics" do
    ics = File.read "spec/examples/vcalendar/timezones/Makebelieve/RDATE_utc_test.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/timezones/Makebelieve/RDATE_utc_test.norm.ics"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse iCalendar properly RRULE_UNTIL_test.ics" do
    ics = File.read "spec/examples/vcalendar/timezones/Makebelieve/RRULE_UNTIL_test.ics"
    vobj_json = Vcalendar.parse(ics, true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcalendar/timezones/Makebelieve/RRULE_UNTIL_test.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip iCalendar RRULE_UNTIL_test.ics" do
    ics = File.read "spec/examples/vcalendar/timezones/Makebelieve/RRULE_UNTIL_test.ics"
    roundtrip = Vcalendar.parse(ics, true).to_s
    expect(norm_vcal(roundtrip)).to eql(norm_vcal(ics))
  end
  it "should normalise iCalendar RRULE_UNTIL_test.ics" do
    ics = File.read "spec/examples/vcalendar/timezones/Makebelieve/RRULE_UNTIL_test.ics"
    vobj_json = Vcalendar.parse(ics, true).to_norm
    ics2 = File.read "spec/examples/vcalendar/timezones/Makebelieve/RRULE_UNTIL_test.norm.ics"
    expect(vobj_json).to eql(ics2)
  end
end

describe Vcard do
  it "should parse VCF properly" do
    ics = File.read "spec/examples/vcard/example1.vcf"
    vobj_json = Vcard.parse(ics, "4.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/example1.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF" do
    ics = File.read "spec/examples/vcard/example1.vcf"
    roundtrip = Vcard.parse(ics, "4.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics))
  end
  it "should normalise VCF" do
    ics = File.read "spec/examples/vcard/example1.vcf"
    vobj_json = Vcard.parse(ics, "4.0", true).to_norm
    ics2 = File.read "spec/examples/vcard/example1.norm.vcf"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse VCF properly" do
    ics = File.read "spec/examples/vcard/example2.vcf"
    vobj_json = Vcard.parse(ics, "4.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/example2.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF" do
    ics = File.read "spec/examples/vcard/example2.vcf"
    roundtrip = Vcard.parse(ics, "4.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics))
  end
  it "should normalise VCF" do
    ics = File.read "spec/examples/vcard/example2.vcf"
    vobj_json = Vcard.parse(ics, "4.0", true).to_norm
    ics2 = File.read "spec/examples/vcard/example2.norm.vcf"
    expect(vobj_json).to eql(ics2)
  end

  it "should parse VCF with binary photo properly" do
    ics = File.read "spec/examples/vcard/example3.vcf"
    vobj_json = Vcard.parse(ics, "3.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/example3.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF with binary photo properly" do
    ics = File.read "spec/examples/vcard/example3.vcf"
    roundtrip = Vcard.parse(ics, "3.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics))
  end

  it "should parse VCF properly" do
    ics = File.read "spec/examples/vcard/example4.vcf"
    vobj_json = Vcard.parse(ics, "3.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/example4.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF" do
    ics = File.read "spec/examples/vcard/example4.vcf"
    roundtrip = Vcard.parse(ics, "3.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics))
  end

  it "should parse VCF from Apple" do
    ics = File.read "spec/examples/vcard/apple.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/apple.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF from Apple" do
    ics = File.read "spec/examples/vcard/apple.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end

  it "should reject TYPE on iana-token property" do
    ics = File.read "spec/examples/vcard/apple1.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true) }.to raise_error(Rsec::SyntaxError)
  end

  it "should reject URL without http prefix per RFC 1738" do
    ics = File.read "spec/examples/vcard/apple2.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true) }.to raise_error(Rsec::SyntaxError)
  end

  it "should reject type parameters on URL" do
    ics = File.read "spec/examples/vcard/apple3.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true) }.to raise_error(Rsec::SyntaxError)
  end

  it "should reject X-parameters on IMPP in v3" do
    ics = File.read "spec/examples/vcard/apple4.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true) }.to raise_error(Rsec::SyntaxError)
  end

  it "should not reject X-parameters on IMPP in v4" do
    ics = File.read "spec/examples/vcard/apple5.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/apple5.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF that does not reject X-parameters on IMPP in v4" do
    ics = File.read "spec/examples/vcard/apple5.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end
  it "should normalise VCF that does not reject X-parameters on IMPP in v4" do
    ics = File.read "spec/examples/vcard/apple5.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_norm
    ics2 = File.read "spec/examples/vcard/apple5.norm.vcf"
    expect(vobj_json).to eql(ics2)
  end

  it "should process VCF from Apple" do
    ics = File.read "spec/examples/vcard/ujb.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/ujb.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF from Apple" do
    ics = File.read "spec/examples/vcard/ujb.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end

  it "should reject CHARSET parameter" do
    ics = File.read "spec/examples/vcard/ujb1.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true) }.to raise_error(Rsec::SyntaxError)
  end

  it "should reject TYPE parameter on X-property in v3" do
    ics = File.read "spec/examples/vcard/ujb2.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true) }.to raise_error(Rsec::SyntaxError)
  end

  it "should not reject TYPE parameter on X-property in v4" do
    ics = File.read "spec/examples/vcard/ujb3.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/ujb3.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF that does not reject TYPE parameter on X-property in v4" do
    ics = File.read "spec/examples/vcard/ujb3.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end
  it "should normalise VCF that does not reject TYPE parameter on X-property in v4" do
    ics = File.read "spec/examples/vcard/ujb3.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_norm
    ics2 = File.read "spec/examples/vcard/ujb3.norm.vcf"
    expect(vobj_json).to eql(ics2)
  end

  it "should reject VCF with FN but no N in v3" do
    ics = File.read "spec/examples/vcard/example51.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true) }.to raise_error(Rsec::SyntaxError)
  end

  it "should reject VCF with FN but no N in v3" do
    ics = File.read "spec/examples/vcard/example61.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true) }.to raise_error(Rsec::SyntaxError)
  end

  it "should process VCF from Apple" do
    ics = File.read "spec/examples/vcard/example5.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/example5.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF from Apple" do
    ics = File.read "spec/examples/vcard/example5.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end

  it "should process VCF from Apple" do
    ics = File.read "spec/examples/vcard/example6.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/example6.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF from Apple" do
    ics = File.read "spec/examples/vcard/example6.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end

  it "should process VCF v4" do
    ics = File.read "spec/examples/vcard/vcard4.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/vcard4.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF v4" do
    ics = File.read "spec/examples/vcard/vcard4.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end
  it "should normalise VCF v4" do
    ics = File.read "spec/examples/vcard/vcard4.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_norm
    ics2 = File.read "spec/examples/vcard/vcard4.norm.vcf"
    expect(vobj_json).to eql(ics2)
  end

  it "should process VCF v4" do
    ics = File.read "spec/examples/vcard/vcard4author.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/vcard4author.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF v4" do
    ics = File.read "spec/examples/vcard/vcard4author.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end
  it "should normalise VCF v4" do
    ics = File.read "spec/examples/vcard/vcard4author.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_norm
    ics2 = File.read "spec/examples/vcard/vcard4author.norm.vcf"
    expect(vobj_json).to eql(ics2)
  end

  it "should process VCF v3" do
    ics = File.read "spec/examples/vcard/vcard3.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/vcard3.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF v3" do
    ics = File.read "spec/examples/vcard/vcard3.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end

  it "should process VCF v3" do
    ics = File.read "spec/examples/vcard/bubba.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/bubba.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF v3" do
    ics = File.read "spec/examples/vcard/bubba.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end

  it "should process VCF v4" do
    ics = File.read "spec/examples/vcard/bubba4.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/bubba4.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF v4" do
    ics = File.read "spec/examples/vcard/bubba4.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end
  it "should normalise VCF v4" do
    ics = File.read "spec/examples/vcard/bubba4.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_norm
    ics2 = File.read "spec/examples/vcard/bubba4.norm.vcf"
    expect(vobj_json).to eql(ics2)
  end

  it "should reject VCF4 with LABEL property" do
    ics = File.read "spec/examples/vcard/example61.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true) }.to raise_error(Rsec::SyntaxError)
  end

  it "should reject TYPE param on X-name property in v3" do
    ics = File.read "spec/examples/vcard/John_Doe_EVOLUTION.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true) }.to raise_error(Rsec::SyntaxError)
  end
  it "should process EVOLUTION VCF v3" do
    ics = File.read "spec/examples/vcard/John_Doe_EVOLUTION.1.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/John_Doe_EVOLUTION.1.json"))
    expect(vobj_json).to include_json(exp_json)
  end

  it "should reject unescaped comma in FN property, v3" do
    ics = File.read "spec/examples/vcard/John_Doe_GMAIL.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true) }.to raise_error(Rsec::SyntaxError)
  end
  it "should reject escaped colon in URI property, v3" do
    ics = File.read "spec/examples/vcard/John_Doe_GMAIL.1.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true) }.to raise_error(Rsec::SyntaxError)
  end
  it "should process GMAIL VCF v3" do
    ics = File.read "spec/examples/vcard/John_Doe_GMAIL.2.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/John_Doe_GMAIL.3.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip GMAIL VCF v3" do
    ics = File.read "spec/examples/vcard/John_Doe_GMAIL.2.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end

  it "should process IPHONE VCF v3" do
    ics = File.read "spec/examples/vcard/John_Doe_IPHONE.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r+\n?/, "\n"), "3.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/John_Doe_IPHONE.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip IPHONE VCF v3" do
    ics = File.read "spec/examples/vcard/John_Doe_IPHONE.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r+\n?/, "\n"), "3.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r+\n?/, "\n")))
  end

  it "should reject double quotation mark in NOTE value, unescaped" do
    ics = File.read "spec/examples/vcard/John_Doe_LOTUS_NOTES.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true) }.to raise_error(Rsec::SyntaxError)
  end
  it "should reject TZ value without sign && double digit hour" do
    ics = File.read "spec/examples/vcard/John_Doe_LOTUS_NOTES.1.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true) }.to raise_error(Rsec::SyntaxError)
  end
  it "should reject SOURCE value which is not URI" do
    ics = File.read "spec/examples/vcard/John_Doe_LOTUS_NOTES.2.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true) }.to raise_error(Rsec::SyntaxError)
  end
  it "should process LOTUS VCF v3" do
    ics = File.read "spec/examples/vcard/John_Doe_LOTUS_NOTES.3.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/John_Doe_LOTUS_NOTES.3.json"))
    expect(vobj_json).to include_json(exp_json)
  end

  it "should reject BASE64 parameter VCF v3" do
    ics = File.read "spec/examples/vcard/John_Doe_MAC_ADDRESS_BOOK.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true) }.to raise_error(Rsec::SyntaxError)
  end
  it "should reject two spaces for folded lines in VCF v3" do
    ics = File.read "spec/examples/vcard/John_Doe_MAC_ADDRESS_BOOK.2.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true) }.to raise_error(Rsec::SyntaxError)
  end
  it "should reject unescaped commas in xname values" do
    ics = File.read "spec/examples/vcard/John_Doe_MAC_ADDRESS_BOOK.3.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true) }.to raise_error(Rsec::SyntaxError)
  end
  it "should process MAC ADDRRESS BOOK VCF v3" do
    ics = File.read "spec/examples/vcard/John_Doe_MAC_ADDRESS_BOOK.1.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r+\n?/, "\n"), "3.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/John_Doe_MAC_ADDRESS_BOOK.1.json"))
    expect(vobj_json).to include_json(exp_json)
  end

  it "should process VCF v4" do
    ics = File.read "spec/examples/vcard/fullcontact.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/fullcontact.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF v4" do
    ics = File.read "spec/examples/vcard/fullcontact.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end
  it "should normalise VCF v4" do
    ics = File.read "spec/examples/vcard/fullcontact.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_norm
    ics2 = File.read "spec/examples/vcard/fullcontact.norm.vcf"
    expect(vobj_json).to eql(ics2)
  end

  it "should process GMAIL VCF v3" do
    ics = File.read "spec/examples/vcard/gmail-single.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/gmail-single.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip GMAIL VCF v3" do
    ics = File.read "spec/examples/vcard/gmail-single.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end

  it "should process GMAIL VCF v3" do
    ics = File.read "spec/examples/vcard/gmail-single2.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/gmail-single2.json"))
    expect(vobj_json).to include_json(exp_json)
  end

  it "should reject obsolete CHARSET parameter VCF v3" do
    ics = File.read "spec/examples/vcard/thunderbird-MoreFunctionsForAddressBook-extension.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true) }.to raise_error(Rsec::SyntaxError)
  end
  it "should process THUNDERBIRD VCF v3" do
    ics = File.read "spec/examples/vcard/thunderbird-MoreFunctionsForAddressBook-extension.1.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/thunderbird-MoreFunctionsForAddressBook-extension.1.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip THUNDERBIRD VCF v3" do
    ics = File.read "spec/examples/vcard/thunderbird-MoreFunctionsForAddressBook-extension.1.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end

  it "should reject mispositioned VERSION property, v3" do
    ics = File.read "spec/examples/vcard/stenerson.vcf"
    expect { Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true) }.to raise_error(Rsec::SyntaxError)
  end
  it "should process VCF v3" do
    ics = File.read "spec/examples/vcard/stenerson.1.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/stenerson.1.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF v3" do
    ics = File.read "spec/examples/vcard/stenerson.1.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end

  it "should process RFC2739 additions to VCF v3" do
    ics = File.read "spec/examples/vcard/rfc2739.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "3.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/rfc2739.json"))
    expect(vobj_json).to include_json(exp_json)
  end

  it "should process VCF v4" do
    ics = File.read "spec/examples/vcard/trafalgar.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/trafalgar.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should normalise VCF v4" do
    ics = File.read "spec/examples/vcard/trafalgar.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_norm
    ics2 = File.read "spec/examples/vcard/trafalgar.norm.vcf"
    expect(vobj_json).to eql(ics2)
  end

  it "should process VCF v4 additions from RFC 6474" do
    ics = File.read "spec/examples/vcard/rfc6474.1.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/rfc6474.1.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF v4 additions from RFC 6474" do
    ics = File.read "spec/examples/vcard/rfc6474.1.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end
  it "should normalise VCF v4 additions from RFC 6474" do
    ics = File.read "spec/examples/vcard/rfc6474.1.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_norm
    ics2 = File.read "spec/examples/vcard/rfc6474.1.norm.vcf"
    expect(vobj_json).to eql(ics2)
  end

  it "should process VCF v4 additions from RFC 6474" do
    ics = File.read "spec/examples/vcard/rfc6474.2.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/rfc6474.2.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF v4 additions from RFC 6474" do
    ics = File.read "spec/examples/vcard/rfc6474.2.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end
  it "should normalise VCF v4 additions from RFC 6474" do
    ics = File.read "spec/examples/vcard/rfc6474.2.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_norm
    ics2 = File.read "spec/examples/vcard/rfc6474.2.norm.vcf"
    expect(vobj_json).to eql(ics2)
  end

  it "should process VCF v4 additions from RFC 6474" do
    ics = File.read "spec/examples/vcard/rfc6474.3.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/rfc6474.3.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF v4 additions from RFC 6474" do
    ics = File.read "spec/examples/vcard/rfc6474.3.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end
  it "should normalise VCF v4 additions from RFC 6474" do
    ics = File.read "spec/examples/vcard/rfc6474.3.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_norm
    ics2 = File.read "spec/examples/vcard/rfc6474.3.norm.vcf"
    expect(vobj_json).to eql(ics2)
  end

  it "should process VCF v4 additions from RFC 6715" do
    ics = File.read "spec/examples/vcard/rfc6715.1.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/rfc6715.1.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF v4 additions from RFC 6715" do
    ics = File.read "spec/examples/vcard/rfc6715.1.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end
  it "should normalise VCF v4 additions from RFC 6715" do
    ics = File.read "spec/examples/vcard/rfc6715.1.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_norm
    ics2 = File.read "spec/examples/vcard/rfc6715.1.norm.vcf"
    expect(vobj_json).to eql(ics2)
  end

  it "should process VCF v4 additions from RFC 6473" do
    ics = File.read "spec/examples/vcard/rfc6473.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_json
    exp_json = JSON.parse(File.read("spec/examples/vcard/rfc6473.json"))
    expect(vobj_json).to include_json(exp_json)
  end
  it "should roundtrip VCF v4 additions from RFC 6473" do
    ics = File.read "spec/examples/vcard/rfc6473.vcf"
    roundtrip = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_s
    expect(norm_vcard(roundtrip)).to eql(norm_vcard(ics.gsub(/\r\n?/, "\n")))
  end
  it "should normalise VCF v4 additions from RFC 6715" do
    ics = File.read "spec/examples/vcard/rfc6473.vcf"
    vobj_json = Vcard.parse(ics.gsub(/\r\n?/, "\n"), "4.0", true).to_norm
    ics2 = File.read "spec/examples/vcard/rfc6473.norm.vcf"
    expect(vobj_json).to eql(ics2)
  end
end
# rubocop:enable LineLength
