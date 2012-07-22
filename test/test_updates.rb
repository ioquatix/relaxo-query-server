
require 'context_test'

class UpdatesTest < ContextTest
	def test_compiles_functions
		create_design_document "test", {
			"updates" => {
				"bar" => %q{
					lambda{|doc, request| doc['updated'] = true; [doc, 'OK']}
				}
			}
		}
		
		document = {"foo" => "bar"}
		response = @context.run ['ddoc', 'test', ['updates', 'bar'], [document, {'method' => 'POST'}]]
		
		assert_equal ["up", document.update('updated' => true), {'body' => 'OK'}], response
	end
end
