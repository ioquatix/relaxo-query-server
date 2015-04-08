
require_relative 'spec_helper'

RSpec.describe "Relaxo Filters" do
	before :all do
		@shell = Relaxo::QueryServer::MockShell.new
		@context = Relaxo::QueryServer::Context.new(@shell, safe: 2)
	end
	
	def run_filter(opts={})
		opts[:docs] ||= []
		opts[:req] ||= {}
		
		@context.run ["ddoc", "foo", ["filters", "basic"], [opts[:docs], opts[:req]]]
	end
	
	it "should apply filters" do
		basic = "lambda{|doc, req| doc['good'] == true}"
		@context.run ["ddoc", "new", "foo", {"filters" => {"basic" => basic}}]
		
		docs = (1..3).map do |i|
			{"good" => i.odd?}
		end
		
		results = run_filter({:docs => docs})
		expect(results).to be == [true, [true, false, true]]
	end
end
