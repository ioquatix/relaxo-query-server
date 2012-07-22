
require 'context_test'
require 'relaxo/query_server/library'

class LibrariesTest < ContextTest
	def test_libraries
		root = {
			'lib' => {
				'all' => %q{
					require 'bigdecimal'
					require 'bigdecimal/util'
				},
				'bar' => %q{
					load('lib/all')

					def bar
						10.to_d
					end
				}
			}
		}
		
		object = Relaxo::QueryServer::Library.for(root, 'lib/bar')
		
		assert_not_nil object
		assert object.respond_to? :bar
		
		assert_equal 10.to_d, object.bar
		
		# For efficiency, the same object is returned both times
		same_object = Relaxo::QueryServer::Library.for(root, 'lib/bar')
		assert_equal object, same_object
	end
	
	def test_map_reduce_libraries
		library_code = %q{
			def check_bar(doc)
				yield doc if doc['bar'] == true
			end
		}
		
		map_function_code = %q{
			foo = load('foo')
			
			lambda {|doc|
				foo.check_bar(doc) {emit(true)}
			}
		}
		
		response = @context.run ['add_lib', {'foo' => library_code}]
		assert_equal true, response
		
		response = @context.run ['add_fun', map_function_code]
		assert_equal true, response
		
		response = @context.run ['map_doc', {'bar' => true}]
		assert_equal [[[true, nil]]], response
	end
end
