#!/usr/bin/env rspec

require_relative 'spec_helper'

RSpec.describe "View Functions" do
	before :all do
		@shell = Relaxo::QueryServer::MockShell.new
		@context = Relaxo::QueryServer::Context.new(@shell, safe: 2)
	end
	
	it "should compile function" do
		response = @context.run ["add_fun", "lambda {|doc| emit(nil, nil)}"]
		expect(response).to be true
	end
	
	it "should have syntax error" do
		response = @context.run ["add_fun", "lambda {"]
		expect(response[0]).to be == "error"
		expect(response[1]).to be == "SyntaxError"
	end
	
	it "should fail on non-function" do
		response = @context.run ["add_fun", "10"]
		expect(response[0]).to be == "error"
		expect(response[1]).to be == "Relaxo::QueryServer::CompilationError"
	end
end
