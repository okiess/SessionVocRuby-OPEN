# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
module ActionDispatch
  module Session
    # Monkey patch to include SessionVOC specific methods into the session context.
    # Convenience methods for the SessionVOC client.
    class AbstractStore::SessionHash 
      include Sessionvoc::DataConversion
      
      # Overriden method to incept session hash access.
      # === Parameters
      # * key = Session key
      def [](key)
        if key == :_csrf_token
          self['transData']['_csrf_token'] if self['transData']
        else
          load_for_read!
          super(key.to_s)
        end
      end

      # Overriden method to incept session hash access.
      # === Parameters
      # * key = Session key
      # * value = Value
      def []=(key, value)
        if key == :_csrf_token
          self['transData'] = {} unless self['transData']
          self['transData']['_csrf_token'] = value
          ActionDispatch::Session::SessionvocStore::Session.client.update(self['sid'], self)
        else
          load_for_write!
          super(key.to_s, value)
        end
      end

      # Adds a key/value pair to the transData context of a SessionVOC session.
      # === Parameters
      # * sid = Session Id
      # * key = Key
      # * value = Value
      # * options
      def set_trans_data(sid, key, value, options = {})
        Rails.logger.debug("AbstractStore::SessionHash#set_trans_data")
        enforce_value_type("transData", key.to_s, value, self)
        ActionDispatch::Session::SessionvocStore::Session.client.update(sid, self)
      end

      # Adds a key/value pair to the userData context of a SessionVOC session.
      # === Parameters
      # * sid = Session Id
      # * key = Key
      # * value = Value
      # * options
      def set_user_data(sid, key, value, options = {})
        Rails.logger.debug("AbstractStore::SessionHash#set_user_data")
        enforce_value_type("userData", key.to_s, value, self)
        ActionDispatch::Session::SessionvocStore::Session.client.update(sid, self)
      end

      # Creates a new form context within this session.
      def new_form
        Rails.logger.debug("AbstractStore::SessionHash#new_form")
        ActionDispatch::Session::SessionvocStore::Session.client.create_form_data(self['sid'])
      end

      # Updates/replaces the form data identified by a sid in SessionVOC.
      # === Parameters
      # * fid = Form Id
      # * data = Form data hash
      # * options
      def set_form_data(fid, data, options = {})
        Rails.logger.debug("Sessionvoc#set_form_data")
        ActionDispatch::Session::SessionvocStore::Session.client.update_form_data(self['sid'], fid, data, options)
      end

      # Returns a form context from SessionVOC identified by a fid.
      # === Parameters
      # * fid = Form Id
      # * options
      def get_form_data(fid, options = {})
        Rails.logger.debug("Sessionvoc#get_form_data")
        ActionDispatch::Session::SessionvocStore::Session.client.get_form_data(self['sid'], fid, options)
      end
      
      # Deletes a form context in SessionVOC
      # === Parameters
      # * fid = Form Id
      # * options
      def delete_form_data(fid, options = {})
        Rails.logger.debug("Sessionvoc#delete_form_data")
        ActionDispatch::Session::SessionvocStore::Session.client.delete_form_data(self['sid'], fid, options)
      end

      # Performs an authentification against SessionVOC.
      # === Parameters
      # * sid = Session Id
      # * uid = User
      # * password = User password
      # * options
      def login(sid, uid, password, options = {})
        Rails.logger.debug("Sessionvoc#login")
        client = ActionDispatch::Session::SessionvocStore::Session.client
        if client.configuration.options["auth"] == 'simple'
          response = client.simple(sid, uid, password, options)
        elsif client.configuration.options["auth"] == 'challenge'
          response = client.challenge(sid, uid, password, options.merge(:no_exception => true))
          if response and response['userData']
            self['userData'] = response['userData']
          else
            return false
          end
        elsif client.configuration.options["auth"] == 'nonce'
          nonce = client.create_nonce(options)
          success = client.get_nonce(nonce, options)
        end
        true
      end

      # Performs a user logout.
      # === Parameters
      # * sid = Session Id
      # * options
      def logout(sid, options = {})
        Rails.logger.debug("Sessionvoc#logout")
        ActionDispatch::Session::SessionvocStore::Session.client.logout(sid, options)
      end

      # Creates a one time use nonce.
      # === Parameters
      # * options
      def create_nonce(options = {})
        nonce = ActionDispatch::Session::SessionvocStore::Session.client.create_nonce(nil, nil, :no_encode => true)
        Base64.encode64(nonce)
      end

      # Checks if the nonce is still valid and has not been used yet.
      # === Parameters
      # * nonce = Nonce string
      # * options
      def nonce_still_valid?(nonce, options = {})
        ActionDispatch::Session::SessionvocStore::Session.client.get_nonce(nonce, options)
      end
    end

    # Wrapper class for holding the SessionVOC session data.
    class SessionvocStore < AbstractStore
      class Session
        attr_accessor :data, :sid, :options

        # Creates a new session data wrapper.
        # === Parameters
        # * sid = Session Id
        # * data = SessionVOC data
        # * options
        def initialize(sid, data, options = {})
          self.sid = sid; self.data = data; self.options = options
        end

        # Creates a new session id returned from SessionVOC.
        def self.generate_sid
          svoc_session_sid = client.new_session
          Rails.logger.debug("SessionVOC Sid: #{svoc_session_sid}")
          svoc_session_sid
        end

        # Returns session data from SessionVOC.
        # === Parameters
        # * sid = Session Id
        def self.get(sid)
          session_data = nil
          begin
            session_data = client.get_session(sid)
          rescue Sessionvoc::InvalidSidException
            sid = client.new_session
            session_data = client.get_session(sid)
          end
          if sid and session_data
            return Session.new(sid, session_data)
          else
            raise "Could not get the session!"
          end
        end

        # Updates session data in SessionVOC.
        # === Parameters
        # * session_data = Session data
        # * options
        def set(session_data, options)
          Rails.logger.debug("Session#set")
          self.data = session_data
          Session.client.update(sid, session_data)
          sid
        end

        # Destroy the SessionVOC session.
        def destroy
          Rails.logger.debug("Session#destroy")
          Session.client.delete_session(self.sid)
        end

        # Returns the SessionVOC client.
        def self.client
          return @@sessionvoc_client if defined?(@@sessionvoc_client) and @@sessionvoc_client

          if File.exists?("#{Rails.root.to_s}/config/sessionvoc.yml")
            Rails.logger.info("Using configuration from config/sessionvoc.yml")
            @@sessionvoc_client = Sessionvoc::Client.new(YAML.load(File.read("#{Rails.root.to_s}/config/sessionvoc.yml")))
          else
            Rails.logger.warn("No configuration file found in Rails. Trying global configuration files...")
            @@sessionvoc_client = Sessionvoc::Client.new
          end
        end

        # Custom to string method.
        def to_s
          "#{self.sid} => #{self.data.inspect}"
        end
      end

      cattr_accessor :session_class
      self.session_class = Session

      ### Abstract rack session method implementations

      # Creates a new rack session.
      # === Parameters
      # * app
      # * options
      def initialize(app, options = {})
        super
        Rails.logger.info("Initializing SessionVOC Session Store...")
      end

      private
      # Finder method for a session.
      # === Parameters
      # * id = Session Id
      def find_session(id)
        @@session_class.get(id)
      end

      # Getter for session.
      # === Parameters
      # * env = Rack environment
      # * sid = Session Id
      def get_session(env, sid)
        Rails.logger.debug("SessionvocStore#get_session")
        sid = @@session_class.generate_sid unless sid
        session = find_session(sid).data
        [sid, session]
      end

      # Setter for session
      # === Parameters
      # * env = Rack environment
      # * sid = Session Id
      # * session_data = Session data to be updated
      def set_session(env, sid, session_data)
        Rails.logger.debug("SessionvocStore#set_session")
        options = env['rack.session.options']
        find_session(sid).set(session_data, options)
      end

      # Destroy rack session.
      # === Parameters
      # * env = Rack environment
      def destroy(env)
        Rails.logger.debug("SessionvocStore#destroy")
        if sid = current_session_id(env)
          return find_session(sid).destroy
        end
        false
      end

      # Returns meta data from SessionVOC.
      def self.meta_data
        @@meta_data ||= nil
        @@meta_data = client.datainfo unless @@meta_data
        @@meta_data
      end

      private
      # Returns the SessionVOC client.
      def self.client
        @@sessionvoc_client ||= nil
        unless @@sessionvoc_client
          if File.exists?("#{Rails.root.to_s}/config/sessionvoc.yml")
            Rails.logger.info("Using configuration from config/sessionvoc.yml")
            @@sessionvoc_client = Sessionvoc::Client.new(YAML.load(File.read("#{Rails.root.to_s}/config/sessionvoc.yml")))
          else
            Rails.logger.warn("No configuration file found in Rails. Trying global configuration files...")
            @@sessionvoc_client = Sessionvoc::Client.new
          end
          meta_data
        end
        @@sessionvoc_client
      end
    end
  end
end
