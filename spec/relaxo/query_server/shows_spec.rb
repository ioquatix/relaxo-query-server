#!/usr/bin/env rspec

require_relative 'spec_helper'

RSpec.describe "Document Shows" do
	STRING = "lambda{|doc, req| [doc['title'], doc['body']].join(' - ') }"
	
	HASH = <<-EOF
		lambda{|doc, req|
			resp = {"code" => 200, "headers" => {"X-Foo" => "Bar"}}
			resp["body"] = [doc['title'], doc['body']].join(' - ')
			resp
		}
	EOF
	
	ERROR = "lambda{|doc,req| raise StandardError.new('error message') }"
	
	before :all do
		@shell = Relaxo::QueryServer::MockShell.new
		@context = Relaxo::QueryServer::Context.new(@shell, safe: 2)
		
		@context.run ["ddoc", "new", "foo", {
				"shows" => {
					"string" => STRING,
					"hash" => HASH,
					"error" => ERROR
				}
			}
		]
	end
	
	def run_show(opts={})
		opts[:doc] ||= {"title" => "foo", "body" => "bar"}
		opts[:req] ||= {}
		opts[:design] ||= "string"
		
		@context.run(["ddoc", "foo", ["shows", opts[:design]], [opts[:doc], opts[:req]]])
	end
	
	it "should process string" do
		result = run_show
		expect(result).to be == ["resp", {"body" => "foo - bar"}]
	end
	
	it "should process hash" do
		result = run_show({:design => "hash"})
		expect(result).to be == ["resp", {"body" => "foo - bar", "headers" => {"X-Foo" => "Bar"}, "code" => 200}]
	end
	
	it "should give an error" do
		result = run_show({:design => "error"})
		expect(result[0...3]).to be == ["error", "StandardError", "error message"]
	end
end
