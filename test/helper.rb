
$LOAD_PATH.unshift File.expand_path("../../lib/", __FILE__)

require 'rubygems'
require 'test/unit'
require 'stringio'

require "relaxo/json"
require "relaxo/query_server"

class Test::Unit::TestCase
	def self.abstract_test_case!
		self.class_eval do
			def test_default
			end
		end
	end
end

class ContextualTestCase < Test::Unit::TestCase
	abstract_test_case!
	
	def setup_context(options)
		@shell = Relaxo::QueryServer::MockShell.new
		@context = Relaxo::QueryServer::Context.new(@shell, options)
	end
	
	def create_design_document name, attributes
		@context.run ['ddoc', 'new', name, attributes]
	end
	
	def setup
		setup_context :safe => 2
	end
	
	def teardown
	end
end
