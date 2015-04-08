#!/usr/bin/env rspec

require_relative 'spec_helper'

RSpec.describe "Document Validations" do
	before :all do
		@shell = Relaxo::QueryServer::MockShell.new
		@context = Relaxo::QueryServer::Context.new(@shell, safe: 2)
	end
	
	def create_design_document name, attributes
		@context.run ['ddoc', 'new', name, attributes]
	end
	
	it "should run update function" do
		create_design_document "test", {
			"updates" => {
				"bar" => %q{
					lambda{|doc, request| doc['updated'] = true; [doc, 'OK']}
				}
			}
		}
		
		document = {"foo" => "bar"}
		response = @context.run ['ddoc', 'test', ['updates', 'bar'], [document, {'method' => 'POST'}]]
		
		expect(response).to be == ["up", document.update('updated' => true), {'body' => 'OK'}]
	end
end
