# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
module Sessionvoc
  # The methods in this module handle all meta data related actions.
  module MetaData
    # Returns meta data info from the SessionVOC server. Includes types and access permissions.
    def datainfo
      response = get_response(:get, "/datainfo")
      if response_ok?(response)
        return response.parsed_response
      else
        raise Sessionvoc::UnknownException
      end
    end
  end
end
