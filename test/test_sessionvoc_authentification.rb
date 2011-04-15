# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
require 'helper'

class TestSessionvocAuthentification < Test::Unit::TestCase
  should "fail to perform a simple authentification due to a non-existing sid" do
    sid = client.new_session
    assert non_sid != sid
    assert_raise Sessionvoc::Open::NotSupportedException do
      client.simple(non_sid, 'testuser', 'tester')
    end
  end
 
  should "perform a challenge response authentification" do
    sid = client.new_session
    assert client.challenge(sid, 'testuser', 'tester')
  end
 
  should "fail to perform a challenge response authentification due to a non-existing sid - part 1" do
    sid = client.new_session
    assert non_sid != sid
    assert_raise Sessionvoc::Open::InvalidSidException do
      login_data = client.challenge(non_sid, 'testuser', 'tester')
    end
  end
  
  should "perform a challenge response authentification" do
    sid = client.new_session
    assert !client.challenge(sid, 'testuser', '', {:no_exception => true})
  end
 
  should "perform a logout" do
    sid = client.new_session
    assert client.challenge(sid, 'testuser', 'tester')
    assert client.logout(sid)
  end
  
  should "perform the correct encryption and hashing" do
    assert_equal client.send(:encrypt_password, 'tester', 'abcdef', Sessionvoc::Open::Base::HASH_TYPES[:HASH_NONE]), 'tester'
    assert_equal client.send(:encrypt_password, 'tester', 'abcdef', Sessionvoc::Open::Base::HASH_TYPES[:HASH_SHA1]), 'db1e80e88bdeb3182c368f2b9d798431'
    assert_equal client.send(:encrypt_password, 'tester', 'abcdef', Sessionvoc::Open::Base::HASH_TYPES[:HASH_MD5]), '8310a7f94396ec64c9221227ba5c667e'
    
    assert_raise Sessionvoc::Open::NotSupportedException do
      client.send(:encrypt_password, 'tester', 'abcdef', Sessionvoc::Open::Base::HASH_TYPES[:HASH_SHA224])
    end
    
    assert_raise Sessionvoc::Open::NotSupportedException do
      client.send(:encrypt_password, 'tester', 'abcdef', Sessionvoc::Open::Base::HASH_TYPES[:HASH_SHA256])
    end
  end

  should "create a nonce" do
    nonce = client.create_nonce
    assert_not_nil nonce
    assert_equal nonce.length, 17
    timestamp = Time.now.to_i
    random_number = client.gen_64bit_id
    local_nonce = Base64.encode64("#{timestamp.to_s[0..3]}#{random_number[4..11]}")
    nonce = client.create_nonce(timestamp, random_number)
    assert_not_nil nonce
    assert_equal nonce.length, 17
    assert_equal nonce, local_nonce
    
    nonce = client.create_nonce(timestamp, random_number, {:no_encode => true})
    assert_equal nonce, "#{timestamp.to_s[0..3]}#{random_number[4..11]}"
  end

  should "check the status of a nonce" do
    10.times do
      nonce = client.create_nonce
      assert client.get_nonce(nonce)
      assert !client.get_nonce(nonce)
    end
  end
end
