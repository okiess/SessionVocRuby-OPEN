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

require File.dirname(__FILE__) + '/sessionvoc/configuration.rb'
require File.dirname(__FILE__) + '/sessionvoc/exceptions.rb'
require File.dirname(__FILE__) + '/sessionvoc/session.rb'
require File.dirname(__FILE__) + '/sessionvoc/authentification.rb'
require File.dirname(__FILE__) + '/sessionvoc/form_data.rb'
require File.dirname(__FILE__) + '/sessionvoc/meta_data.rb'
require File.dirname(__FILE__) + '/sessionvoc/data_conversion.rb'
require File.dirname(__FILE__) + '/sessionvoc/base.rb'
require File.dirname(__FILE__) + '/sessionvoc/client.rb'

if defined?(Rails)
  require File.dirname(__FILE__) + '/sessionvoc-store/railtie.rb'
  require File.dirname(__FILE__) + '/sessionvoc-store/sessionvoc_store.rb'
end
