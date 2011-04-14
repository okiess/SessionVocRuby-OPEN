# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
module Sessionvoc
  # The methods in this module handle all session related actions.
  module Session
    # Creates a new session in the SessionVOC server and returns a sid.
    def new_session
      response = get_response(:post, "/session")
      if response_ok?(response)
        return response.parsed_response["sid"]
      else
        raise Sessionvoc::SessionCreationFailureException
      end
    end

    # Deletes an existing session in the SessionVOC server.
    # === Parameters
    # * sid = Session Id
    def delete_session(sid)
      response = get_response(:delete, "/session/#{sid}")
      if response_ok?(response) and response.parsed_response["deleted"]
        return true
      else
        handle_exception(response.parsed_response["errorCode"], response.parsed_response["message"])
      end
    end

    # Updates the contents of the session in the SessionVOC server. Pass in a session_data hash containing the "transData" und "userData"
    # sections.
    # === Parameters
    # * sid = Session Id
    # * session_data = Session data hash
    # * options
    def update(sid, session_data, options = {})
      logger.debug("Session Data for sid #{sid}: #{session_data.inspect}")
      body = {}
      body['transData'] = session_data['transData'] if session_data['transData'] and not session_data['transData'].empty?
      body['userData'] = session_data['userData'] if session_data['userData'] and not session_data['userData'].empty?
      logger.debug("Body JSON: #{body.to_json}")
      response = get_response(:put, "/session/#{sid}", {:body => body.to_json})
      response_ok?(response) ? response.parsed_response : handle_exception(response.parsed_response["errorCode"], response.parsed_response["message"])
    end

    # Alias for get_session.
    # === Parameters
    # * sid
    def output(sid); get_session(sid); end
    
    # Retuns the contents of a session from the SessionVOC server as a hash.
    # === Parameters
    # * sid = Session Id
    def get_session(sid)
      response = get_response(:get, "/session/#{sid}")
      if response_ok?(response)
        return response.parsed_response
      else
        raise Sessionvoc::InvalidSidException
      end
    end
  end
end
