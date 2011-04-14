# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
module Sessionvoc
  # The methods in this module handle the data conversion and access permissions expected by the SessionVOC
  # server.
  module DataConversion
    # Forces session values to conform the data type the SessionVOC server expects. This method also
    # checks if the value is allowed to be changed.
    # === Parameters
    # * scope = "transData","userData","formData"
    # * key = Key
    # * value = Value
    # * session_data = Session object to work on
    def enforce_value_type(scope, key, value, session_data)
      if session_data and session_data[scope] and session_data['sid']
        meta_data = datainfo
        scope = "form" if scope == "formData"
        if meta_data and meta_data["access"] and meta_data["access"][scope] and [1, 2].include?(meta_data["access"][scope][key.to_s])
          if meta_data["types"] and meta_data["types"][scope] and meta_data["types"][scope][key.to_s]
            desired_type = Sessionvoc::Base::DATA_TYPES[meta_data["types"][scope][key.to_s]]
            if desired_type
              session_data[scope][key] = convert(key, value, desired_type)
            else
              raise Sessionvoc::DataConversionException, "Unknown type"
            end
          else
            raise Sessionvoc::DataConversionException, "Unknown attribute" 
          end
        else
          raise Sessionvoc::DataConversionException, "Scope '#{scope}' not found"
        end
        return session_data
      else
        if session_data.nil? or (session_data['sid'].nil? or session_data['sid'].blank?)
          raise Sessionvoc::InvalidSidException
        else
          raise Sessionvoc::DataConversionException
        end
      end
    end
    
    # Sets the meta data used by the SessionVOC server.
    def datainfo
      @@meta_data ||= nil
      @@meta_data = ActionDispatch::Session::SessionvocStore::Session.client.datainfo unless @@meta_data
      @@meta_data
    end

    # This methods performs the actual type conversion.
    # === Parameters
    # * key = Key
    # * value = value
    # * desired_type = Type expected by SessionVOC server
    def convert(key, value, desired_type)
      if key and value and desired_type
        begin
          case desired_type
            when :DT_NULL
              value = nil
            when :DT_BOOLEAN
              if value == "true" or value == "1"
                value = true
              elsif value == "false" or value == "0"
                value = false
              else
                value = false
              end
            when :DT_CHAR
              value = value.to_s[0..0]
            when :DT_STRING
              value = value.to_s
            when :DT_DOUBLE
              value = value.to_f
            when :DT_FLOAT
              value = value.to_f
            when :DT_INTEGER
              value = value.to_i
            when :DT_LONG_INTEGER
              value = value.to_i
            when :DT_UNSIGNED_INTEGER
              value = value.to_i
              value = nil if value < 0
            when :DT_UNSIGNED_LONG_INTEGER
              value = value.to_i
              value = nil if value < 0
            when :DT_BLOB
              value = Base64.encode64(value)
            else
              value = value.to_s
          end
        rescue => e
          return nil
        end
        value
      end
    end
  end
end
