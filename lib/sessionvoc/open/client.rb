# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
module Sessionvoc
  module Open
    # You can setup the client by passing options into the constructor or by using a configuration file in YAML.
    # client = Sessionvoc::Open::Client.new('host' => 'localhost', 'port' => 12345, 'auth' => 'challenge')
    class Client < Sessionvoc::Open::Base
      include Sessionvoc::Open::Session
      include Sessionvoc::Open::Authentification
      include Sessionvoc::Open::FormData
      include Sessionvoc::Open::DataConversion
      include Sessionvoc::Open::MetaData

      private
      # Internal method to create the httparty request and return the http response that is already parsed by httparty.
      # === Parameters
      # * http_verb = HTTP verb symbol (:get, :post, :put, :delete)
      # * endpoint = HTTP URL endpoint
      # * options = Optional options with body and headers
      def get_response(http_verb, endpoint, options = {}, no_uri_escape = false)
        begin
          if no_uri_escape
            endpoint_value = "#{base_url}#{endpoint}"
          else
            endpoint_value = "#{base_url}#{URI.escape(endpoint)}"
          end
          logger.debug "Using endpoint: #{endpoint_value}"
          body = {}; body.merge!(options) if options and options.any?
          response = (http_verb == :post or http_verb == :put) ? HTTParty.send(http_verb, endpoint_value, body) : HTTParty.send(http_verb, endpoint_value)
          logger.debug "Response: #{response.inspect}" if response
          response
        rescue => e
          logger.error("Could not connect to SessionVOC: #{e.message}")
          raise Sessionvoc::Open::ConnectionRefusedException
        end
      end

      # Internal method to check the statuscode of a response and its error message if available.
      # === Parameters
      # * response = HTTP response
      def response_ok?(response)
        response and response.parsed_response and response.response.is_a?(Net::HTTPOK) and not response.parsed_response["error"]
      end

      # Internal method to get meta data about the types and access permissions for the given SessionVOC server installation.
      def meta_data
        logger.debug("Client#meta_data")
        @@meta_data ||= nil
        @@meta_data = self.datainfo unless @@meta_data
        @@meta_data
      end
    end
  end
end
