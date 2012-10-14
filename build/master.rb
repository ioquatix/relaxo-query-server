
Dir.chdir("../") do
	require './lib/relaxo/query_server/version'

	Gem::Specification.new do |s|
		s.name = "relaxo-query-server"
		s.version = Relaxo::QueryServer::VERSION::STRING
		s.author = "Samuel Williams"
		s.email = "samuel.williams@oriontransfer.co.nz"
		s.homepage = "http://www.oriontransfer.co.nz/gems/relaxo"
		s.platform = Gem::Platform::RUBY
		s.summary = "Relaxo Query Server provides support for executing CouchDB functions using Ruby."
		s.files = FileList["{bin,lib,test}/**/*"] + ["rakefile.rb", "README.md"]

		s.executables << 'relaxo-query-server'

		s.add_dependency("relaxo", "~> 0.4.0")
		s.add_dependency("json", "~> 1.7.3")

		s.has_rdoc = "yard"
	end
end
