# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
require 'sessionvoc-open'
require "sessionvoc-store/open/controller_methods"
require "rails"

module SessionvocStore
  class Railtie < Rails::Railtie
    rake_tasks do
      # not used at the moment
    end

    initializer "setup sessionvoc session store" do |app|
      ActionController::Base.send :include, ::ControllerMethods::InstanceMethods
    end
  end
end
