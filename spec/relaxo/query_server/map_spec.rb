
require_relative 'spec_helper'

RSpec.describe "Map Functions" do
	before :all do
		@shell = Relaxo::QueryServer::MockShell.new
		@context = Relaxo::QueryServer::Context.new(@shell, safe: 2)
	end
	
	it "should map values using a function" do
		response = @context.run ["add_fun", "lambda{|doc| emit('foo', doc['a']); emit('bar', doc['a'])}"]
		expect(response).to be true
		
		response = @context.run ["add_fun", "lambda{|doc| emit('baz', doc['a'])}"]
		expect(response).to be true
		
		response = @context.run(["map_doc", {"a" => "b"}])
		expect(response).to be == [
			[["foo", "b"], ["bar", "b"]],
			[["baz", "b"]]
		]
	end
end
