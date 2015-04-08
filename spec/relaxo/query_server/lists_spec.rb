
require_relative 'spec_helper'

RSpec.describe "Lists" do
	before :all do
		@shell = Relaxo::QueryServer::MockShell.new
		@context = Relaxo::QueryServer::Context.new(@shell, safe: 2)
	end
	
	def create_design_document name, attributes
		@context.run ['ddoc', 'new', name, attributes]
	end
	
	it "should list all items" do
		create_design_document "test", {
			'lists' => {
				'entire' => <<-EOF
					lambda{|head,request|
						send "<ul>"
						each do |row|
							send "<li>" + row['count'] + "</li>"
						end
						send "</ul>"
					}
				EOF
			}
		}
		
		rows = [
			["list_row", {"count"=>"Neko"}],
			["list_row", {"count"=>"Nezumi"}],
			["list_row", {"count"=>"Zoe"}],
			["list_end"]
		]
		
		rows.each {|row| @shell.input << row}
		
		result = @context.run ['ddoc', 'test', ['lists', 'entire'], [{}, {}]]
		
		expect(@shell.output).to be == [
			["start", ["<ul>"], {:headers=>{}}],
			["chunks", ["<li>Neko</li>"]],
			["chunks", ["<li>Nezumi</li>"]],
			["chunks", ["<li>Zoe</li>"]]
		]
			
		expect(result).to be == ["end", ["</ul>"]]
	end
end
