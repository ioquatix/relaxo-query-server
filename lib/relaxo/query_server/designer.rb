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

module Relaxo
	module QueryServer
		# Indicates that a validation error has occured.
		class ValidationError < StandardError
			def initialize(details)
				super "Validation failed!"
				
				@details = details
			end
			
			# The details of the validation error, typically:
			#     {:forbidden => "Message"}
			# or
			#     {:unauthorized => "Message"}
			attr :details
		end
		
		# Indicates that the request was invalid for some reason (e.g. lacking appropriate authentication)
		class InvalidRequestError < StandardError
			def initilize(message, code = 400, details = {})
				super message
				
				@code = 400
				@details = details
			end
			
			# Returns a response suitable for passing back to the client.
			def to_response
				@details.merge(:code => @code)
			end
		end
		
		# Supports the `list` action which consumes rows and outputs encoded text in chunks.
		class ListRenderer < Process
			def initialize(context, function)
				super(context, function)
				
				@started = false
				@fetched_row = false
				@start_response = {:headers => {}}
				@chunks = []
			end
			
			def run(head, request)
				super(head, request)
				
				# Ensure that at least one row is read from input:
				get_row unless @fetched_row
				
				return ["end", @chunks]
			end

			def send(chunk)
				@chunks << chunk
				false
			end

			def each
				while row = get_row
					yield row
				end
			end

			def get_row
				flush
				
				row = @context.shell.read_object
				@fetched_row = true
				
				case command = row[0]
				when "list_row"
					row[1]
				when "list_end"
					false
				else
					raise RuntimeError.new("Input is not a row!")
				end
			end

			def start(response)
				raise RuntimeError.new("List already started!") if @started
				
				@start_response = response
			end

			def flush
				if @started
					@context.shell.write_object ["chunks", @chunks]
				else
					@context.shell.write_object ["start", @chunks, @start_response]
					
					@started = true
				end
				
				@chunks = []
			end
		end
		
		# Represents a design document which includes a variety of functionality for processing documents.
		class DesignDocument
			VALIDATED = 1
			
			def initialize(context, name, attributes = {})
				@context = context

				@name = name
				@attributes = attributes
			end

			# Lookup the given key in the design document's attributes.
			def [] key
				@attributes[key]
			end

			# Runs the given function with the given arguments.
			def run(function, arguments)
				action = function[0]
				function = function_for(function)

				self.send(action, function, *arguments)
			end

			# Implements the `filters` action.
			def filters(function, documents, request)
				results = documents.map{|document| !!function.call(document, request)}

				return [true, results]
			end

			# Implements the `shows` action.
			def shows(function, document, request)
				response = function.call(document, request)

				return ["resp", wrap_response(response)]
			end

			# Implements the `updates` action.
			def updates(function, document, request)
				raise InvalidRequestError.new("Unsupported method #{request['method']}") unless request['method'] == 'POST'

				document, response = function.call(document, request)

				return ["up", document, wrap_response(response)]
			rescue InvalidRequestError => error
				return ["up", null, error.to_response]
			end

			# Implements the `lists` action.
			def lists(function, head, request)
				ListRenderer.new(@context, function).run(head, request)
			end

			# Implements the `validates_doc_update` action.
			def validates(function, new_document, old_document, user_context)
				Process.new(@context, function).run(new_document, old_document, user_context)
				
				# Unless ValidationError was raised, we are okay.
				return VALIDATED
			rescue ValidationError => error
				error.details
			end

			alias validate_doc_update validates

			# Ensures that the response is the correct form.
			def wrap_response(response)
				String === response ? {"body" => response} : response
			end

			# Looks a up a function given a key path into the design document.
			def function_for(path)
				parent = @attributes

				function = path.inject(parent) do |current, key|
					parent = current

					throw ArgumentError.new("Invalid function name #{path.join(".")}") unless current

					current[key]
				end

				# Compile the function if required:
				if String === function
					parent[path.last] = @context.parse_function(function, self, 'design-document')
				else
					function
				end
			end
		end
		
		# Implements the design document state and interface.
		class Designer
			def initialize(context)
				@context = context
				@documents = {}
			end
			
			# Create a new design document.
			#
			# @param [String] name
			#     The name of the design document.
			# @param [Hash] attributes
			#     The contents of the design document.
			def create(name, attributes)
				@documents[name] = DesignDocument.new(@context, name, attributes)
			end
			
			# Run a function on a given design document.
			#
			# @param [String] name
			#     The name of the design document.
			# @param [Array] function
			#     A key path to the function to execute.
			# @param [Array] arguments
			#     The arguments to provide to the function.
			def run(name, function, arguments)
				document = @documents[name]
				
				raise ArgumentError.new("Invalid document name #{name}") unless document
				
				document.run(function, arguments)
			end
		end
	end
end
