
$LOAD_PATH.unshift File.expand_path("../../lib/", __FILE__)

require 'test/unit'
require 'stringio'

require "relaxo/query_server"

class ContextTest < Test::Unit::TestCase
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
