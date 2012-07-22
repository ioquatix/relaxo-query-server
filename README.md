Relaxo Query Server
===================

* Author: Samuel G. D. Williams (<http://www.oriontransfer.co.nz>)
* Copyright (C) 2012 Samuel G. D. Williams.
* Released under the MIT license.

The Relaxo Query Server implements the CouchDB Query Server protocol for CouchDB 1.1.0+. It provides a comprehensive Ruby-style view server along with full support for Design Document based processing.

*This software is currently under development and not ready for stable production usage.*

Installation
------------

Install the ruby gem as follows:

	sudo gem install relaxo-query-server

Edit your etc/couchdb/local.ini and add the following:

	[query_servers]
	relaxo-ruby = relaxo-query-server

Make sure the `relaxo-query-server` executable is accessible from `$PATH`.

To build and install the gem from source:

	cd build/
	sudo GEM=gem1.9 rake1.9 install_gem

Usage
-----

### Mapping Function ###

Select documents of `type == 'user'`:

	lambda do |document|
		if document['type'] == 'user'
			emit(document['_id'])
		end
	end

### Reduction Function ###

Calculate the sum:

	lambda do |keys,values,rereduce|
		values.inject &:+
	end

### Design Document ###

A simple application:

	# design.yaml
	-   _id: "_design/users"
	    language: 'relaxo-ruby'
	    views:
	        service:
	            map: |
	                lambda do |doc|
	                    emit(doc['_id']) if doc['type'] == 'user'
	                end
	    validate_doc_update: |
	        lambda do |new_document, old_document, user_context|
	            if !user_context.admin && new_document['admin'] == true
	                raise ValidationError.new(:forbidden => "Cannot create admin user!")
	            end
	        end
	    updates:
	        user: |
	            lambda do |doc, request|
	                doc['updated_date'] = Date.today.iso8061; [doc, 'OK']
	            end
	    lists:
	        user: |
	            lambda do |head, request|
	                send "<ul>"
	                each do |user|
	                    send "<li>" + user['name'] + "</li>"
	                end
	                send "</ul>"
	            end
	    filters:
	        regular_users: |
	            lambda do |doc, request|
	                doc['admin'] == false
	            end
	    shows:
	        user: |
	            lambda do |doc, request|
	                {
	                    :code => 200,
	                    :headers => {"Content-Type" => "text/html"}},
	                    :body => "User: #{doc['name']}"
	                }
	            end

The previous `design.yaml` document can be loaded using the `relaxo` client command:

	relaxo http://localhost:5984/test design.yaml

To Do
-----

- Improve documentation, including better sample code.
- More tests, including performance benchmarks.
- Explore `parse_function` to improve performance of code execution by caching functions.
- Helper methods for commonly used mapping functions.

License
-------

Copyright (c) 2010, 2011 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.