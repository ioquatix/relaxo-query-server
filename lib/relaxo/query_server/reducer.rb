# Copyright (c) 2012 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'relaxo/query_server/process'

module Relaxo
	module QueryServer
		# Call the reduction function, and if it fails, respond with an error message.
		class ReducingProcess < Process
			def evaluate(*args)
				begin
					call(*args)
				rescue Exception => exception
					# If the mapping function throws an error, report the error for this document:
					@context.error_for_exception(exception)
				end
			end
		end
		
		# Implements the `reduce` and `rereduce` functions along with all associated state.
		class Reducer
			# Create a reducer attached to the given context.
			def initialize(context)
				@context = context
			end
			
			# Apply the reduce function to a given list of items. Functions are typically in the form of:
			#     functions = [lambda{|keys,values,rereduce| ...}]
			#
			# such that:
			#     items = [[key1, value1], [key2, value2], [key3, value3]]
			#     functions.map{|function| function.call(all keys, all values, false)}
			#
			# @param [Array] functions 
			#     An array of functions to apply.
			# @param [Array] items
			#     A composite list of items.
			def reduce(functions, items)
				functions = functions.collect do |function_text|
					@context.parse_function(function_text, binding)
				end
				
				keys, values = [], []
				
				items.each do |value|
					keys << value[0]
					values << value[1]
				end
				
				result = functions.map do |function|
					ReducingProcess.new(self, function).run(keys, values, false)
				end
				
				return [true, result]
			end
			
			# Apply the rereduce functions to a given list of values.
			#     lambda{|keys,values,rereduce| ...}.call([], values, true)
			#
			# @param [Array] functions
			#     An array of functions to apply, in the form of:
			# @param [Array] values
			#     An array of values to reduce
			def rereduce(functions, values)
				functions = functions.collect do |function_text|
					@context.parse_function(function_text, binding)
				end
				
				result = functions.map do |function|
					ReducingProcess.new(self, function).run([], values, true)
				end
				
				return [true, result]
			end
		end
	end
end
