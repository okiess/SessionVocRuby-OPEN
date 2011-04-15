# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
module Sessionvoc
  module Open
    # This Ruby library provides a Ruby on Rails session store for the SessionVOC. It can also be used outside of Rails to interact with SessionVOC
    # directly or within Sinatra and other webapplication frameworks in Ruby. 
    #
    # The SessionVOC is a noSQL database optimized for the management of user sessions. Additionally the SessionVOC establishes security mechanisms
    # that are difficult to implement with other session management systems. It depends on the actual scenario which of these functions
    # has the highest priority.
    class Base
      VERSION = '1.7.3'
      attr_accessor :configuration, :logger
    
      # SessionVOC Error Codes used by the server.
      ERROR_CODES = {
        1  => "Errorcode 1: Internal Server Error",
        2  => "Illegal request",
        3  => "Errorcode 3: Unknown session identifier",
        4  => "Errorcode 4: Authentification failed",
        5  => "Errorcode 5: Unknown form data",
        6  => "Errorcode 6: Temporary error",
        7  => "Errorcode 7: Illegal authentification request",
        8  => "Errorcode 8: Illegal user identifier",
        9  => "Errorcode 9: Session remove (delete) failure",
        10 => "Errorcode 10: Get request failure, can not output",
        11 => "Errorcode 11: Parser error, illegal Json",
        12 => "Errorcode 12: Error while attempting to create form data, internet server error",
        13 => "Errorcode 13: Error while attempting to delete form data, invalid form identifier or internal server error",
        14 => "Errorcode 14: Error while attempting to modify form data, invalid form identifier",
        15 => "Errorcode 15: Error while attempting to output form data, invalid form identifier",
        16 => "Errorcode 16: Internal Server Error while attempting to remove form data",
        17 => "Errorcode 17: Error while attempting to update form data, invalid session or form identifier"
      }

      # Existing hash types used by the server.
      HASH_TYPES = {
         :HASH_NONE => 0,
         :HASH_SHA1 => 1,
         :HASH_SHA224 => 2,
         :HASH_SHA256 => 3,
         :HASH_MD5 => 4
      }

      # Existing data types used by the server.
      DATA_TYPES = {
         0  => :DT_NULL,
         1  => :DT_BOOLEAN,
         2  => :DT_CHAR,
         3  => :DT_DOUBLE,
         4  => :DT_FLOAT,
         5  => :DT_INTEGER,
         6  => :DT_LONG_INTEGER,
         7  => :DT_STRING,
         8  => :DT_UNSIGNED_INTEGER,
         9  => :DT_UNSIGNED_LONG_INTEGER,
         10 => :DT_BLOB,
         11 => :DT_VARIANT,
         -1 => :DT_UNDEFINED
      }

      # Existing access types allowed by the server.
      DATA_ACCESS = {
         0  => :DA_READ_ONLY,
         1  => :DA_READ_WRITE,
         2  => :DA_WRITE_ONLY,
         -1 => :DA_UNDEFINED
      }

      # === Parameters
      # * host = Hostname (required)
      # * port = Port (required)
      # * protocol = "http"/"https", defaults to "http"
      # * log_level = defaults to LOGGER::INFO
      # * auth = Authentication method configured in SessionVOC server
      def initialize(options = {})
        default_options = {'host' => 'localhost', 'port' => '8208', 'protocol' => 'http', 'log_level' => Logger::INFO,
          'strict_mode' => true, 'auth' => 'none'}
        options = default_options.merge(options)
        options.empty? ? read_configuration : self.configuration = Sessionvoc::Open::Configuration.new(options)
        if defined?(Rails)
          self.logger = Rails.logger
        else
          self.logger = Logger.new(STDOUT)
          self.logger.level = options['log_level']
        end
        self.logger.info("SessionVOC Open Ruby Client Version: #{VERSION}")
      end

      protected
      # Reads the configuration from the current directory and when it doesn't find it falls back to the
      # global configuration in the home directory (~/.sessionvoc.yml) under which this ruby interpreter is run.
      def read_configuration
        if File.exists?("config.yml")
          logger.info("Using config in this directory")
          self.configuration = Sessionvoc::Open::Configuration.new(YAML.load(File.read("config.yml")))
        else
          begin
            logger.info("Using config in your home directory")
            self.configuration = Sessionvoc::Open::Configuration.new(YAML.load(File.read("#{ENV['HOME']}/.sessionvoc.yml")))
          rescue Errno::ENOENT
            raise Sessionvoc::Open::ConfigurationMissingException, "config.yml expected in current directory or ~/.sessionvoc.yml"
          end
        end
      end

      # Returns the HTTP base URL for the SessionVOC Rest Service.
      def base_url
        "#{self.configuration.options['protocol']}://#{self.configuration.options['host']}:#{self.configuration.options['port']}"
      end

      # Returns true/false whether to use the client in strict-mode or not.
      # In strict-mode exceptions are raised for the most common client operations.
      def use_strict_mode?
        self.configuration.options['strict_mode']
      end
    
      # Convenience method to access error codes from within this instance.
      def codes; ERROR_CODES; end
    
      # Internal method used to handle internal exceptions and map the error code to a human
      # readable message.
      # === Parameters
      # * errorCode = Errorcode number
      # * message = Optional message
      def handle_exception(errorCode, message = nil)
        case errorCode
          when 1
            raise Sessionvoc::Open::InternalServerErrorException, display_message(errorCode, message)
          when 2
            raise Sessionvoc::Open::IllegalRequestException, display_message(errorCode, message)
          when 3
            raise Sessionvoc::Open::InvalidSidException, display_message(errorCode, message)
          when 4
            raise Sessionvoc::Open::AuthentificationFailedException, display_message(errorCode, message)
          when 7
            raise Sessionvoc::Open::IllegalAuthentificationRequestException, display_message(errorCode, message)
          when 8
            raise Sessionvoc::Open::IllegalUserIdentifierException, display_message(errorCode, message)
          when 9
            raise Sessionvoc::Open::SessionDeletionFailure, display_message(errorCode, message)
          when 11
            raise Sessionvoc::Open::InvalidJSONException, display_message(errorCode, message)
          when 12
            raise Sessionvoc::Open::InternalServerErrorException, display_message(errorCode, message)
          when 13
            raise Sessionvoc::Open::InvalidFidException, display_message(errorCode, message)
          when 14
            raise Sessionvoc::Open::FormDataCantBeModifiedException, display_message(errorCode, message)
          when 15
            raise Sessionvoc::Open::InvalidFidException, display_message(errorCode, message)
          when 16
            raise Sessionvoc::Open::FormDataCantBeDestroyedException, display_message(errorCode, message)
          when 17
            raise Sessionvoc::Open::InvalidSidException, display_message(errorCode, message)
        end
      end

      # Displays a message if available.
      def display_message(errorCode, message)
        message ? "#{codes[errorCode]} - #{message}" : codes[errorCode]
      end
    end
  end
end
