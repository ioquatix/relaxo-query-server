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

require 'relaxo/query_server/shell'
require 'relaxo/query_server/mapper'
require 'relaxo/query_server/reducer'
require 'relaxo/query_server/designer'

module Relaxo
	module QueryServer
		class CompilationError < StandardError
		end
		
		# A query server context includes all state required for implementing the query server protocol.
		class Context
			# Given a function as text, and an execution scope, return a callable object.
			def parse_function(text, scope, filename = 'query-server')
				safe_level = @options[:safe] || 0
			
				function = lambda { $SAFE = safe_level; eval(text, scope.send(:binding), filename) }.call
			
				unless function.respond_to? :call
					raise CompilationError.new('Expression does not evaluate to procedure!')
				end
				
				return function
			end
			
			def initialize(shell, options = {})
				@shell = shell
				@options = options
				
				@mapper = Mapper.new(self)
				@reducer = Reducer.new(self)
				@designer = Designer.new(self)
				
				@config = {}
			end
			
			attr :config
			attr :shell
			
			# Return an error structure from the given exception.
			def error_for_exception(exception)
				["error", exception.class.to_s, exception.message, exception.backtrace]
			end
			
			# Process a single command as per the query server protocol.
			def run(command)
				case command[0]
				# ** Map functionality
				when 'add_fun'
					@mapper.add_function command[1]; true
				when 'map_doc'
					@mapper.map command[1]
				when 'reset'
					@config = command[1] || {}
					@mapper = Mapper.new(self); true
				
				# ** Reduce functionality
				when 'reduce'
					@reducer.reduce command[1], command[2]
				when 'rereduce'
					@reducer.rereduce command[1], command[2]
				
				# ** Design document functionality
				when 'ddoc'
					if command[1] == 'new'
						@designer.create(command[2], command[3]); true
					else
						@designer.run(command[1], command[2], command[3])
					end
				end
			rescue Exception => exception
				error_for_exception(exception)
			end
			
			# Write a log message back to the shell.
			def log(message)
				@shell.write_object ['log', message]
			end
		end
	end
end
