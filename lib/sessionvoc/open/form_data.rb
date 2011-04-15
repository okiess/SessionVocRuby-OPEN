# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
module Sessionvoc
  module Open
    # The methods in this module handle all form data relevant actions.
    module FormData    
      # Creates a new form context within a given session and returns a fid which identifies the form context.
      # === Parameters
      # * sid = Session Id
      # * options
      def create_form_data(sid, options = {})
        response = get_response(:post, "/formdata/#{sid}")
        if response_ok?(response)
          response.parsed_response["fid"]
        else
          handle_exception(response.parsed_response["errorCode"], response.parsed_response["message"])
        end
      end

      # Deletes a form context within a session.
      # === Parameters
      # * sid = Session Id
      # * fid = Form Id
      # * options
      def delete_form_data(sid, fid, options = {})
        response = get_response(:delete, "/formdata/#{sid}/#{fid}")
        if response_ok?(response)
          response.parsed_response["deleted"]
        else
          handle_exception(response.parsed_response["errorCode"], response.parsed_response["message"])
        end
      end

      # Returns the contents of a form context within a session.
      # === Parameters
      # * sid = Session Id
      # * fid = Form Id
      # * options
      def get_form_data(sid, fid, options = {})
        response = get_response(:get, "/formdata/#{sid}/#{fid}")
        if response and response.response.is_a?(Net::HTTPOK)
          response.parsed_response
        else
          handle_exception(response.parsed_response["errorCode"], response.parsed_response["message"])
        end
      end

      # Updates/replaces the form data in SessionVOC with the form_data passed to this method.
      # === Parameters
      # * sid = Session Id
      # * fid = Form Id
      # * form_data = Form data hash
      # * options
      def update_form_data(sid, fid, form_data, options = {})
        response = get_response(:put, "/formdata/#{sid}/#{fid}", {:body => form_data.to_json})
        if response_ok?(response)
          (response.parsed_response['sid'] and response.parsed_response['fid'])
        else
          handle_exception(response.parsed_response["errorCode"], response.parsed_response["message"])
        end
      end
    end
  end
end
