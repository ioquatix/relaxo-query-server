
require 'context_test'

class ValidationsTest < ContextTest
	def test_compiles_functions
		create_design_document "test", {
			"validate_doc_update" => %q{
				lambda{|new_document, old_document, user_context|
					raise ValidationError.new('forbidden' => "bad") if new_document['bad']
					
					true
				}
			}
		}
		
		response = @context.run ['ddoc', 'test', ['validate_doc_update'], [{'good' => true}, {'good' => true}, {}]]
		assert_equal true, response
		
		response = @context.run ['ddoc', 'test', ['validate_doc_update'], [{'bad' => true}, {'good' => true}, {}]]
		assert_equal({'forbidden' => 'bad'}, response)
	end
end
