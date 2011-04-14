# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
require "sessionvoc-store/railtie"
require "sessionvoc-store/controller_methods"

ActionController::Base.send :include, ::ControllerMethods::InstanceMethods
