
require 'context_test'

class ShowsTest < ContextTest
	STRING = "lambda{|doc, req| [doc['title'], doc['body']].join(' - ') }"
	HASH = <<-EOF
      lambda{|doc, req|
        resp = {"code" => 200, "headers" => {"X-Foo" => "Bar"}}
        resp["body"] = [doc['title'], doc['body']].join(' - ')
        resp
      }
    EOF
	ERROR = "lambda{|doc,req| raise StandardError.new('error message') }"
	
	def setup
		super
		
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
	
	def test_string
		result = run_show
		expected = ["resp", {"body" => "foo - bar"}]
		assert_equal expected, result
	end
	
	def test_hash
		result = run_show({:design => "hash"})
		expected = ["resp", {"body" => "foo - bar", "headers" => {"X-Foo" => "Bar"}, "code" => 200}]
		assert_equal expected, result
	end
	
	def test_error
		result = run_show({:design => "error"})
		expected = ["error", "StandardError", "error message"]
		assert_equal expected, result[0...3]
	end
end
