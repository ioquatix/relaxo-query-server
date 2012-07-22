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
		# Supports `Mapper` by providing a context with an `emit` method that collects the results from the mapping function.
		class MappingProcess < Process
			def initialize(context, function)
				super(context, function)
				@results = []
			end
			
			# Emit a result
			def emit(key, value = nil)
				@results << [key, value]
			end
			
			def run(*args)
				begin
					call(*args)
				rescue Exception => exception
					# If the mapping function throws an error, report the error for this document:
					return @context.error_for_exception(exception)
				end
				
				return @results
			end
		end
		
		class Mapper
			def initialize(context)
				@context = context
				@functions = []
			end
			
			# Adds a function by parsing the text, typically containing a textual representation of a lambda.
			def add_function text
				@functions << @context.parse_function(text, self)
			end
			
			# Map a document to a set of results by appling all functions.
			def map(document)
				@functions.map do |function|
					MappingProcess.new(@context, function).run(document)
				end
			end
		end
	end
end
