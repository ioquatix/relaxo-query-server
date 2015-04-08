
require 'relaxo/query_server/library'

require 'bigdecimal'
require 'bigdecimal/util'

require_relative 'spec_helper'

RSpec.describe "Libraries" do
	before :all do
		@shell = Relaxo::QueryServer::MockShell.new
		@context = Relaxo::QueryServer::Context.new(@shell, safe: 2)
	end
	
	it "should load a library" do
		root = {
			'lib' => {
				'all' => %q{
					require 'bigdecimal'
					require 'bigdecimal/util'
				},
				'bar' => %q{
					load('lib/all')

					def bar
						"10".to_d
					end
				}
			}
		}
		
		object = Relaxo::QueryServer::Library.for(root, 'lib/bar')
		expect(object).to be_respond_to :bar
		expect(object.bar).to be == "10".to_d
		
		# For efficiency, the same object is returned both times
		same_object = Relaxo::QueryServer::Library.for(root, 'lib/bar')
		expect(same_object).to be object
	end
	
	it "should use library functions for map/reduce" do
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
		expect(response).to be true
		
		response = @context.run ['add_fun', map_function_code]
		expect(response).to be true
		
		response = @context.run ['map_doc', {'bar' => true}]
		expect(response).to be == [[[true, nil]]]
	end
end
