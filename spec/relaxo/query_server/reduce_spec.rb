
require_relative 'spec_helper'

RSpec.describe "Reduce Functions" do
	before :all do
		@shell = Relaxo::QueryServer::MockShell.new
		@context = Relaxo::QueryServer::Context.new(@shell, safe: 2)
	end
	
	it "should reduce values" do
		sum = "lambda{|k,v,r| v.inject &:+ }"
		concat = "lambda{|k,v,r| r ? v.join('_') : v.join(':') }"
		
		response = @context.run ["reduce", [sum, concat], (0...10).map{|i|[i,i*2]}]
		expect(response).to be == [true, [90, "0:2:4:6:8:10:12:14:16:18"]]
		
		response = @context.run ["rereduce", [sum, concat], (0...10).map{|i|i}]
		expect(response).to be == [true, [45, "0_1_2_3_4_5_6_7_8_9"]]
	end
	
	it "should reduce using library functions" do
		library_code = %q{
			def sum(values)
				values.inject(&:+)
			end
		}
		
		reduce_function = %q{
			foo = load('foo')
			
			lambda {|k,v,r|
				foo.sum(v)
			}
		}
		
		response = @context.run ['add_lib', {'foo' => library_code}]
		expect(response).to be true
		
		response = @context.run ['reduce', [reduce_function], (0...10).map{|i|[i,i]}]
		expect(response).to be == [true, [45]]
	end
end
