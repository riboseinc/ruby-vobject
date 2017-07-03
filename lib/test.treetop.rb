require 'rubygems'
require 'treetop'
base_path = File.expand_path(File.dirname(__FILE__))

def unfold(str)
         str.gsub(/[\n\r]+[ \t]+/, '')
end

Treetop.load (File.join(base_path, 'vobject.treetop'))
parser = VObjectGrammarParser.new
ics = File.read "../spec/examples/example2.ics"
#ics = File.read "./a"

	puts parser.parse(unfold(ics)).content

t1 = Time.now
for i in 0..1000
	parser.parse(unfold(ics))
end
t2 = Time.now - t1
puts t2
