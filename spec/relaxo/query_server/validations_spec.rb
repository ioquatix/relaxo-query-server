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
	
	it "should validate document updates" do
		create_design_document "test", {
			"validate_doc_update" => %q{
				lambda{|new_document, old_document, user_context|
					raise ValidationError.new('forbidden' => "bad") if new_document['bad']
					
					true
				}
			}
		}
		
		response = @context.run ['ddoc', 'test', ['validate_doc_update'], [{'good' => true}, {'good' => true}, {}]]
		expect(response).to be == 1
		
		response = @context.run ['ddoc', 'test', ['validate_doc_update'], [{'bad' => true}, {'good' => true}, {}]]
		expect(response).to be == {'forbidden' => 'bad'}
	end
end
