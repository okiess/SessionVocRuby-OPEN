# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
require "sessionvoc-store/open/railtie"
require "sessionvoc-store/open/controller_methods"

ActionController::Base.send :include, ::ControllerMethods::InstanceMethods
