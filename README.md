SessionVOC Session Store
========================

This Ruby library provides a Ruby on Rails session store for the SessionVOC. It can also be used outside of Rails to interact with SessionVOC directly or within Sinatra and other webapplication frameworks in Ruby. 

The SessionVOC is a noSQL database optimized for the management of user sessions. Additionally the SessionVOC establishes security mechanisms that are difficult to implement with other session management systems. It depends on the actual scenario which of these functions has the highest priority.

For more information, check out:
http://www.worldofvoc.com/products/sessionvoc/summary/


Installation
------------

Tested on Ruby 1.8.7 (Rubygems 1.5.2) and Rails 3.0.5 and higher.
	
	[sudo] gem install httparty
	[sudo] gem install json
    [sudo] gem install sessionvoc-store

Install Rails if you don't have it already:

	[sudo] gem install rails


Configuration
-------------

SessionVOC:

In order to use the Ruby library you need to have a working installation of SessionVOC. Example configurations for SessionVOC can be found in the "examples" directory. The "example.xml" is the configuration you need to run the tests and the "example.sql" contains the database schema.

Copy both files to the /tmp directory on your server or local machine and execute the following commands (as root):

 * cd /tmp
 * sevc example.xml
 * cp ./sessionvoc.so /usr/lib/sessionvoc/sessionvoc.so
 * /etc/init.d/sessionvoc restart
 * mysql -u root -p
   * create database sessionvoc;
   * exit
 * mysql -u root -p sessionvoc < example.sql

Checkout the SessionVOC Wiki for more information: http://www.worldofvoc.com/wiki/


Rails 3 Integration:

Please make sure that your SessionVOC installation configuration contains the `_csrf_token` attribute definition in "transData" (checkout example.xml).

Basic steps to perform within your Rails webapp:

 * Add the "sessionvoc-store" gem to your Gemfile
 * Create a "sessionvoc.yml" file in your config directory
 * Create a "session_store.rb" file in the "config/initializers" directory and add the following line (please fill in your app name):

	`{YOUR APP NAME}::Application.config.session_store :sessionvoc_store`
	
 * Add the following line to your application_controller.rb file:

	`before_filter :init_sessionvoc`

Please checkout the "sessionvoc-webapp" example for more information.


Outside of Rails:

You can setup the SessionVOC client by passing options into the constructor or by using a configuration file in YAML.

    client = SessionVOC::Client.new('host' => 'localhost', 'port' => 8208, 'auth' => 'challenge')

Possible configuration options:

* host (required)
* port (required)
* protocol ("http"/"https"), defaults to "http"
* log_level, defaults to `LOGGER::INFO`
* auth ("none", "challenge", "simple"), depending on your SessionVOC configuration

You can also provide a configuration file in the current directory of your client to avoid setting up the client within your code. Checkout the config.yml.sample file as an example.

If this configuration file isn't found in the current directory, the client will look for a "global" configuration file in your home directory (~/.sessionvoc.yml).


Usage
-----

Add the "sessionvoc-store" gem to your bundler Gemfile in Rails 3.x or require the sessionvoc-store gem manually.

    gem 'sessionvoc-store'
    require 'sessionvoc-store'


Examples
--------

Within Rails:

Working with sessions:

	Setting a key/value pair from inside your controller action:
	
	session.set_trans_data(session['sid'], 'message', 'Hello from Rails!')
	session.set_user_data(session['sid'], 'name', 'Tes')

Getting a value from "transData"/"userData":

	puts session['transData']['message']
	puts session['userData]['name']

Authentification:

	success = session.login(session['sid'], 'testuser', 'tester')
	session.logout(session['sid'])

Working with forms:

	fid = session.new_form
	sessionvoc_form_data = session.get_form_data(fid)
	session.set_form_data(fid, sessionvoc_form_data)
	session.delete_form_data(fid)


Please checkout the "sessionvoc-webapp" example for more information.


Outside of Rails:

Creating the client:

    gem 'sessionvoc-store'
    require 'sessionvoc-store'
    client = Sessionvoc::Client.new('host' => 'localhost', 'port' => 8208, 'log_level' => LOGGER::DEBUG, 'auth' => 'challenge')

Working with sessions:

	session_data = {'transData' => {'message' => 'Hello!'}}
	
	sid = client.new_session
	client.update(sid, session_data)
	sessionvoc_session_data = client.get_session(sid)
	client.delete_session(sid)

Authentification:

	sid = client.new_session
	sessionvoc_session_data = client.challenge(sid, 'testuser', 'tester')
	puts sessionvoc_session_data['userData']
	
	sessionvoc_session_data = client.challenge(sid, 'testuser', 'WRONG_PASSWORD')
	puts sessionvoc_session_data
	=> nil

	sessionvoc_session_data = {'transData' => {'message' => 'Hello!'}, 'userData' = {'name' => 'Tes'}}
	client.update(sid, sessionvoc_session_data)
	
	client.logout(sid)

Nonce:

	nonce = client.create_nonce
	still_valid = client.get_nonce(nonce)
	=> true/false

Working with forms:

	my_form_data = {'firstname' => 'Tes', 'lastname' => 'Tester'}

	sid = client.new_session
	fid = client.create_form_data(sid)
	success = client.update_form_data(sid, fid, my_form_data)
	sessionvoc_form_data = client.get_form_data(sid, fid)
	success = client.delete_form_data(sid, fid)


Documentation & Tests
---------------------

Checkout the rdoc Documentation for more information. Generate the docs with "rake rdoc".

Use "rake test" to run the unit tests. The unit tests expect the SimpleVOC server to be started on port 8208 on your localhost:

To run the tests against an existing SessionVOC installation on a different host or port, use the `SESSIONVOC_HOST` / `SESSIONVOC_PORT` environment variables. For example:

	SESSIONVOC_HOST=192.168.0.1 SESSIONVOC_PORT=8008 rake test


Copyright
---------

Copyright (c) 2011 triAGENS GmbH. See LICENSE.txt for further details.

Author: Oliver Kiessler (kiessler@inceedo.com)
