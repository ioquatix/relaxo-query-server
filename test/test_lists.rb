
require 'context_test'

class ListsTest < ContextTest
	ENTIRE = <<-RUBY
		lambda{|head,request|
			send "<ul>"
			each do |row|
				send "<li>" + row['count'] + "</li>"
			end
			send "</ul>"
		}
	RUBY
	
	def setup
		super
		
		@rows = [
			["list_row", {"count"=>"Neko"}],
			["list_row", {"count"=>"Nezumi"}],
			["list_row", {"count"=>"Zoe"}],
			["list_end"]
		]
	end
	
	def test_lists_rows
		create_design_document "test", {
			'lists' => {
				'entire' => ENTIRE
			}
		}
		
		@rows.each {|row| @shell.input << row}
		
		result = @context.run ['ddoc', 'test', ['lists', 'entire'], [{}, {}]]
		
		assert_equal [
			["start", ["<ul>"], {:headers=>{}}],
			["chunks", ["<li>Neko</li>"]],
			["chunks", ["<li>Nezumi</li>"]],
			["chunks", ["<li>Zoe</li>"]]
			], @shell.output
			
		assert_equal ["end", ["</ul>"]], result
	end
end
