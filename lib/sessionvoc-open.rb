# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
require 'rubygems'
gem 'httparty'
require 'httparty'
gem 'json'
require 'json'
require 'logger'
require 'yaml'
require 'digest'
require 'base64'

require File.dirname(__FILE__) + '/sessionvoc/open/configuration.rb'
require File.dirname(__FILE__) + '/sessionvoc/open/exceptions.rb'
require File.dirname(__FILE__) + '/sessionvoc/open/session.rb'
require File.dirname(__FILE__) + '/sessionvoc/open/authentification.rb'
require File.dirname(__FILE__) + '/sessionvoc/open/form_data.rb'
require File.dirname(__FILE__) + '/sessionvoc/open/meta_data.rb'
require File.dirname(__FILE__) + '/sessionvoc/open/data_conversion.rb'
require File.dirname(__FILE__) + '/sessionvoc/open/base.rb'
require File.dirname(__FILE__) + '/sessionvoc/open/client.rb'

if defined?(Rails)
  require File.dirname(__FILE__) + '/sessionvoc-store/open/railtie.rb'
  require File.dirname(__FILE__) + '/sessionvoc-store/open/sessionvoc_store.rb'
end
