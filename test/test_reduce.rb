
require 'helper'

class ReduceTest < ContextualTestCase
	SUM = "lambda{|k,v,r| v.inject &:+ }"
	CONCAT = "lambda{|k,v,r| r ? v.join('_') : v.join(':') }"
	
	def test_reduce
		response = @context.run ["reduce", [SUM, CONCAT], (0...10).map{|i|[i,i*2]}]
		assert_equal [true, [90, "0:2:4:6:8:10:12:14:16:18"]], response
		
		response = @context.run ["rereduce", [SUM, CONCAT], (0...10).map{|i|i}]
		assert_equal [true, [45, "0_1_2_3_4_5_6_7_8_9"]], response
	end
end
