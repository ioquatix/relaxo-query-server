
require 'helper'

class MapTest < ContextualTestCase
	def test_map
		response = @context.run ["add_fun", "lambda{|doc| emit('foo', doc['a']); emit('bar', doc['a'])}"]
		assert_equal true, response
		
		response = @context.run ["add_fun", "lambda{|doc| emit('baz', doc['a'])}"]
		assert_equal true, response
		
		response = @context.run(["map_doc", {"a" => "b"}])
		expected = [
			[["foo", "b"], ["bar", "b"]],
			[["baz", "b"]]
		]
		
		assert_equal expected, response
	end
end
