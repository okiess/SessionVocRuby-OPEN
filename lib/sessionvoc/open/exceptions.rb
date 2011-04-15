# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
module Sessionvoc
  module Open
    # Raised when no SessionVOC client could be created due to a missing configuration.
    class ConfigurationMissingException < Exception; end
  
    # The SessionVOC server is not accessible with this configuration.
    class ConnectionRefusedException < Exception; end
  
    # Raised when the SessionVOC server could not create a new session.
    class SessionCreationFailureException < Exception; end
  
    # Raised when no or an invalid session id is used and it is unknown to SessionVOC.
    class InvalidSidException < Exception; end
  
    # Raised when the session identified by a sid could not be deleted.
    class SessionDeletionFailure < Exception; end
  
    # Raised when invalid JSON is passed to SessionVOC.
    class InvalidJSONException < Exception; end
  
    # Raised when an unidentified problem occured.
    class UnknownException < Exception; end
  
    # Raised when the given credentials are unknown to SessionVOC.
    class AuthentificationFailedException < Exception; end
  
    # Raised when an illegal user identifier is passed to SessionVOC.
    class IllegalUserIdentifierException < Exception; end
  
    # Raised when an illegal authentification request is passed to SessionVOC.
    class IllegalAuthentificationRequestException < Exception; end
  
    # Raised when an illegal request is passed to SessionVOC.
    class IllegalRequestException < Exception; end
  
    # Raised when an internal server error occurs in SessionVOC.
    class InternalServerErrorException < Exception; end
  
    # Raised when an unknown or invalid form id is passed to SessionVOC.
    class InvalidFidException < Exception; end
  
    # Raised when a form data problem occurred in SessionVOC.
    class FormDataCantBeDestroyedException < Exception; end
  
    # Raised when a form data problem occurred in SessionVOC.
    class FormDataCantBeModifiedException < Exception; end
  
    # Raised when an unsupported functionality in this ruby library was used.
    class NotSupportedException < Exception; end
  
    # Raised when the given data could not be converted to the data types expected by SessionVOC.
    class DataConversionException < Exception; end
  end
end
