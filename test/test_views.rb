
require 'helper'

class ViewsTest < ContextualTestCase
	def test_compiles_functions
		response = @context.run ["add_fun", "lambda {|doc| emit(nil, nil)}"]
		assert_equal true, response
		
		response = @context.run ["add_fun", "lambda {"]
		assert_equal "error", response[0]
		assert_equal "SyntaxError", response[1]
		
		response = @context.run ["add_fun", "10"]
		assert_equal "error", response[0]
		assert_equal "Relaxo::QueryServer::CompilationError", response[1]
	end
end
