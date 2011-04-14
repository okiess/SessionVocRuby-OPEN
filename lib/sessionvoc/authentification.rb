# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
module Sessionvoc
  module Authentification
    # Performs the simple authentification method against the SessionVOC server.
    # Currently not available.
    # === Parameters
    # * sid = Session Id
    # * uid = User
    # * options
    def simple(sid, uid, password, options = {})
      logger.debug("Authentification#simple for sid: #{sid} for uid: #{uid}")
      raise Sessionvoc::NotSupportedException, "Not supported at the moment. Use 'Challenge-Response' with comm-hash 'none' instead..."
      response = get_response(:put, "/session/#{sid}/authenticate",
        {:body => {'uid' => uid, 'password' => Digest::MD5.hexdigest(password)}.to_json})
      response_ok?(response) ? true :  handle_exception(response.parsed_response["errorCode"], response.parsed_response["message"])
    end

    # Performs the challenge-response authentification method against the SessionVOC
    # === Parameters
    # * sid = Session Id
    # * uid = User
    # * password = User Password
    # * options
    def challenge(sid, uid, password, options = {})
      logger.debug("Authentification#challenge for sid: #{sid} for uid: #{uid}")
      response = get_response(:put, "/session/#{sid}/authenticate",
        {:body => {'uid' => uid}.to_json})
      if response_ok?(response) and response.parsed_response["loginData"]
        return challenge_response(sid, uid, password, response.parsed_response["loginData"]['salt'],
          response.parsed_response["loginData"]['hash'], options)
      else
        if options[:no_exception]
          return nil
        else
          handle_exception(response.parsed_response["errorCode"], response.parsed_response["message"])
        end
      end
    end

    # Performs a user logout.
    # === Parameters
    # * sid = Session Id
    def logout(sid, options = {})
      logger.debug("Authentification#logout for sid: #{sid}")
      response = get_response(:put, "/session/#{sid}/authenticate", {:body => nil})
      response_ok?(response) ? true : handle_exception(response.parsed_response["errorCode"], response.parsed_response["message"])
    end

    # Create a (one time) usable nonce.
    # === Parameters
    # * ts = Timestamp (only used for testing)
    # * random_number = (only used for testing)
    # * options
    def create_nonce(ts = nil, random_number = nil, options = {})
      timestamp = ts ? ts.to_s : Time.now.to_i.to_s
      if options[:no_encode]
        "#{timestamp[0..3]}#{random_number ? random_number[4..11] : gen_64bit_id[4..11]}"
      else
        Base64.encode64("#{timestamp[0..3]}#{random_number ? random_number[4..11] : gen_64bit_id[4..11]}")
      end
    end

    # Checks if the previously created nonce was already used.
    # === Parameters
    # * nonce = Nonce string
    def get_nonce(nonce, options = {})
      response = get_response(:post, "/nonce/#{nonce}", {}, true)
      (response_ok?(response) and response.parsed_response["status"]) ? true : handle_exception(response.parsed_response["errorCode"], response.parsed_response["message"])
    end

    # Generates a 64bit random number as part of the nonce.
    def gen_64bit_id
      encode_id(rand(18446744073709551615))
    end

    private
    # The second part of the challenge response authentification method.
    # === Parameters
    # * sid = Session Id
    # * uid = User
    # * password = User password
    # * salt = Salt delivered by SessionVOC
    # * hash = Hash delivered by SessionVOC
    # * options
    def challenge_response(sid, uid, password, salt, hash, options = {})
      logger.debug("Authentification#challenge_response for sid: #{sid} for uid: #{uid}")
      response = get_response(:put, "/session/#{sid}/authenticate",
        {:body => {'uid' => uid, 'password' => encrypt_password(password, salt, hash)}.to_json})
      if response_ok?(response)
        response.parsed_response
      else
        if options[:no_exception]
          false
        else
          handle_exception(response.parsed_response["errorCode"], response.parsed_response["message"])
        end
      end
    end

    # Creates an encrypted and hashed password as required by the SessionVOC server.
    # === Parameters
    # * password = Password
    # * salt = Salt delivered by SessionVOC
    # * hash = Hash delivered by SessionVOc
    def encrypt_password(password, salt, hash)
      if hash.to_i == Sessionvoc::Base::HASH_TYPES[:HASH_NONE]
        return password
      elsif hash.to_i == Sessionvoc::Base::HASH_TYPES[:HASH_SHA1]
        return Digest::MD5.hexdigest(Digest::MD5.hexdigest(Digest::SHA1.hexdigest(password)) + salt)
      elsif hash.to_i == Sessionvoc::Base::HASH_TYPES[:HASH_SHA224]
        raise Sessionvoc::NotSupportedException, "SHA224 is not supported"
      elsif hash.to_i == Sessionvoc::Base::HASH_TYPES[:HASH_SHA256]
        raise Sessionvoc::NotSupportedException, "SHA256 is not supported"
      elsif hash.to_i == Sessionvoc::Base::HASH_TYPES[:HASH_MD5]
        return Digest::MD5.hexdigest(Digest::MD5.hexdigest(password) + salt)
      end
    end

    # Encodes the 64bit random number.
    # === Parameters
    # * n = Random number
    def encode_id(n)
      n.to_s(36).rjust(13, '0')
    end
  end
end
