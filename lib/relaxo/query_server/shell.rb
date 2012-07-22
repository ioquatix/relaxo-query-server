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

require 'json'
require 'logger'

module Relaxo
	module QueryServer
		# A simple wrapper that reads and writes objects using JSON serialization to the given `input` and `output` `IO`s.
		class Shell
			def initialize(input, output)
				@input = input
				@output = output
			end
			
			attr :input
			attr :output
			
			# Read a JSON serialised object from `input`.
			def read_object
				JSON.parse @input.readline
			end

			# Write a JSON serialized object to `output`.
			def write_object object
				@output.puts object.to_json
				@output.flush
			end

			# Read commands from `input`, execute them and then write out the results.
			def run
				begin
					while true
						command = read_object

						result = yield command

						write_object(result)
					end
				rescue EOFError
					# Finish...
				end
			end
		end
		
		# Used primarily for testing, allows the input and output of the server to be provided directly.
		class MockShell < Shell
			def initialize
				super [], []
			end

			def read_object
				if @input.size > 0
					@input.shift
				else
					raise EOFError.new("No more objects")
				end
			end

			def write_object object
				@output << object
			end
		end
	end
end
