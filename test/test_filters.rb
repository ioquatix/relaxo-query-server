
require 'context_test'

class FiltersTest < ContextTest
	BASIC = "lambda{|doc, req| doc['good'] == true}"
	
	def run_filter(opts={})
		opts[:docs] ||= []
		opts[:req] ||= {}
		
		@context.run ["ddoc", "foo", ["filters", "basic"], [opts[:docs], opts[:req]]]
	end
	
	def test_filters_updated
		@context.run ["ddoc", "new", "foo", {"filters" => {"basic" => BASIC}}]
		
		docs = (1..3).map do |i|
			{"good" => i.odd?}
		end
		
		results = run_filter({:docs => docs})
		assert_equal [true, [true, false, true]], results
	end
end
