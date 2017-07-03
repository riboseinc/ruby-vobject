require 'rubygems'
require './vobject.rsec.rb'
base_path = File.expand_path(File.dirname(__FILE__))

def unfold(str)
         str.gsub(/[\n\r]+[ \t]+/, '')
end

ics = File.read "../spec/examples/example2.ics"
#ics = File.read "./a"
puts ics
	puts vobject.parse(unfold(ics)).inspect

t1 = Time.now
for i in 0..1000
	vobject.parse(unfold(ics))
	Rsec::Fail.reset
end
t2 = Time.now - t1
puts t2
