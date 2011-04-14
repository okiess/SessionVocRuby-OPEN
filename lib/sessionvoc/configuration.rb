# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
module Sessionvoc
  # You can also provide a configuration file in the current directory of your client to avoid setting up the client within your code.
  # Checkout the config.yml.sample file as an example.
  # 
  # If this configuration file isn't found in the current directory, the client will look for a "global" configuration file in your 
  # home directory (~/.sessionvoc.yml).
  class Configuration
    attr_accessor :options

    # === Parameters
    # * host = Hostname (required)
    # * port = Port (required)
    # * protocol = "http"/"https", defaults to "http"
    # * auth = "none"/"simple"/"challenge"
    # * log_level = defaults to LOGGER::INFO
    def initialize(options = {})
      self.options = options
    end
  end
end
