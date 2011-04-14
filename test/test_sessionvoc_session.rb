# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
require 'helper'

class TestSessionvocSession < Test::Unit::TestCase
  should "create a new session" do
    sid = client.new_session
    assert_not_nil sid
    assert sid.is_a?(String)
    assert sid.length > 0
  end

  should "get an existing session" do
    sid = client.new_session
    assert_not_nil sid
    session_data = client.get_session(sid)
    assert_not_nil session_data
    assert session_data.has_key?("urlSecret")
    assert session_data.has_key?("userData")
    assert session_data.has_key?("sid")
    assert session_data.has_key?("uid")
    assert session_data.has_key?("transData")
  end
  
  should "fail to get an existing due to a non-existing sid" do
    sid = client.new_session
    assert non_sid != sid
    assert_raise Sessionvoc::InvalidSidException do
      session_data = client.get_session(non_sid)
    end
  end
  
  should "delete an existing session" do
    sid = client.new_session
    assert_not_nil sid
    session_data = client.get_session(sid)
    assert_not_nil session_data
    client.delete_session(sid)
  end
  
  should "fail to delete a session due to a non-existing sid" do
    sid = client.new_session
    assert non_sid != sid
    assert_raise Sessionvoc::InvalidSidException do
      client.delete_session(non_sid)
    end
  end

  should "update a session with transdata" do
    sid = client.new_session
    assert_not_nil sid
    
    assert_not_nil client.update(sid, {'transData' => {'message' => 'Hello from RUnit!'}})
    session_data = client.get_session(sid)
    assert_not_nil session_data
    assert_not_nil session_data['transData']
    assert_equal session_data['transData']['message'], 'Hello from RUnit!'
    
    assert_not_nil client.update(sid, {'transData' => {'message' => ''}})
    session_data = client.get_session(sid)
    assert_not_nil session_data
    assert_not_nil session_data['transData']
    assert_equal session_data['transData']['message'], ''
  end
  
  should "fail to update a session due to a non-existing sid" do
    sid = client.new_session
    assert non_sid != sid
    assert_raise Sessionvoc::InvalidSidException do
      client.update(non_sid, {'transData' => {'message' => 'Hello from RUnit!'}})
    end
  end
end
