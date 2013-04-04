# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'relaxo/query_server/version'

Gem::Specification.new do |spec|
	spec.name          = "relaxo-query-server"
	spec.version       = Relaxo::QueryServer::VERSION
	spec.authors       = ["Samuel Williams"]
	spec.email         = ["samuel.williams@oriontransfer.co.nz"]
	spec.description   = <<-EOF
	Relaxo Query Server is a query server for CouchDB which provides full
	support for map/reduce functionality using Ruby code. It's main purpose
	is to provide a consistent backend for Ruby based clients to CouchDB.
	In practice, it allows code to be shared between Ruby based client 
	applications and CouchDB servers.
	EOF
	spec.summary       = %q{Relaxo Query Server provides support for executing CouchDB functions using Ruby.}
	spec.homepage      = ""
	spec.license       = "MIT"

	spec.files         = `git ls-files`.split($/)
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]

	spec.add_development_dependency "bundler", "~> 1.3"
	spec.add_development_dependency "rake"
	
	spec.add_dependency "relaxo", "~> 0.4.0"
	spec.add_dependency "json", "~> 1.7.3"
	spec.add_dependency "rest-client"
end
