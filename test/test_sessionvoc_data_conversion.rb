# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
require 'helper'

class TestSessionvocDataConversion < Test::Unit::TestCase
  should "perform type conversion on trans data" do
    sid = client.new_session
    assert_not_nil sid
    assert_not_nil client.datainfo

    mock_session_hash = {'transData' => {}, 'sid' => sid}
    session_data = client.enforce_value_type('transData', 'message', 'test', mock_session_hash)
    assert_not_nil session_data
    assert_equal session_data['transData']['message'], 'test'
  end
  
  should "fail to perform data conversion due to an unknown scope" do
    sid = client.new_session
    assert_not_nil sid
    mock_session_hash = {'transData' => {}, 'sid' => sid}
    assert_raise Sessionvoc::Open::DataConversionException do
      client.enforce_value_type('someData', 'message', 'test', mock_session_hash)
    end
  end
  
  should "fail to perform data conversion due to a missing sid" do
    mock_session_hash = {'transData' => {}, 'sid' => nil}
    assert_raise Sessionvoc::Open::InvalidSidException do
      client.enforce_value_type('transData', 'message', 'test', mock_session_hash)
    end
  end

  should "fail to perform data conversion due to an unknown attribute" do
    sid = client.new_session
    assert_not_nil sid
    mock_session_hash = {'transData' => {}, 'sid' => sid}
    assert_raise Sessionvoc::Open::DataConversionException do
      client.enforce_value_type('transData', 'foo', 'test', mock_session_hash)
    end
  end

  should "perform type conversion on user data" do
    sid = client.new_session
    assert_not_nil sid
    assert_not_nil client.datainfo

    mock_session_hash = {'userData' => {}, 'sid' => sid}
    session_data = client.enforce_value_type('userData', 'name', 'Kiessler', mock_session_hash)
    assert_not_nil session_data
    assert_equal session_data['userData']['name'], 'Kiessler'
  end
  
  should "perform DT_NULL conversions" do
    assert_nil client.convert("foo", "bar", :DT_NULL)
  end
  
  should "perform DT_BOOLEAN conversions" do
    assert client.convert("foo", "true", :DT_BOOLEAN)
    assert client.convert("foo", "1", :DT_BOOLEAN)
    assert !client.convert("foo", "false", :DT_BOOLEAN)
    assert !client.convert("foo", "0", :DT_BOOLEAN)
    assert !client.convert("foo", "bar", :DT_BOOLEAN)
  end
  
  should "perform DT_CHAR conversions" do
    assert_equal client.convert("foo", "bar", :DT_CHAR), "b"
  end

  should "perform DT_STRING conversions" do
    assert_equal client.convert("foo", "bar", :DT_STRING), "bar"
    assert_equal client.convert("foo", 1, :DT_STRING), "1"
    assert_equal client.convert("foo", 1.1, :DT_STRING), "1.1"
    assert_equal client.convert("foo", true, :DT_STRING), "true"
  end

  should "perform DT_INTEGER conversions" do
    assert_equal client.convert("foo", "433", :DT_INTEGER), 433
    assert_equal client.convert("foo", 43333, :DT_INTEGER), 43333
    assert_equal client.convert("foo", "34749857984", :DT_LONG_INTEGER), 34749857984
    assert_equal client.convert("foo", 34749857984, :DT_LONG_INTEGER), 34749857984
  end
  
  should "perform DT_FLOAT conversions" do
    assert_equal client.convert("foo", "43.3", :DT_FLOAT), 43.3
    assert_equal client.convert("foo", 4333.3, :DT_FLOAT), 4333.3
    assert_equal client.convert("foo", "34749857984.2", :DT_DOUBLE), 34749857984.2
    assert_equal client.convert("foo", 34749857984.2, :DT_DOUBLE), 34749857984.2
  end
  
  should "perform DT_UNSIGNED_INTEGER conversions" do
    assert_equal client.convert("foo", "433", :DT_UNSIGNED_INTEGER), 433
    assert_nil client.convert("foo", -43333, :DT_UNSIGNED_INTEGER)
    assert_equal client.convert("foo", "34749857984", :DT_UNSIGNED_LONG_INTEGER), 34749857984
    assert_nil client.convert("foo", -34749857984, :DT_UNSIGNED_LONG_INTEGER)
  end
end
