require 'spec_helper'
require 'pp'
require 'json'

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
end
