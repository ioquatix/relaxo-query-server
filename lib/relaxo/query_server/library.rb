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

module Relaxo
	module QueryServer
		class Library
			def self.for(root, path)
				parent = root

				path = path.split('/') unless Array === path

				library = path.inject(parent) do |current, name|
					return nil if current == nil

					parent = current

					current[name]
				end

				return nil if library == nil

				unless Library === library
					library = parent[path.last] = Library.new(root, path, library)
				end

				return library.instance
			end

			def initialize(root, path, code)
				@root = root
				@path = path
				@code = code

				@klass = nil
				@instance = nil
			end

			def instance
				unless @klass
					@klass = Class.new

					# Not sure if this is the best way to implement the `load` function
					@klass.const_set('ROOT', @root)
					@klass.class_exec(@root) do |root|
						@@root = root

						def self.load(path)
							Library.for(@@root, path)
						end

						def load(path)
							self.class.load(path)
						end
					end

					@klass.class_eval @code, @path.join('/')
				end

				@instance ||= @klass.new
			end
		end
	end
end
