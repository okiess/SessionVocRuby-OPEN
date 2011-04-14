# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
require 'helper'

class TestSessionvocMetaData < Test::Unit::TestCase
  should "read the data info" do
    meta_data = client.datainfo
    assert_not_nil meta_data
    assert meta_data.has_key?("types")
    assert meta_data.has_key?("access")
    assert meta_data["access"].has_key?("form")
    assert meta_data["access"].has_key?("transData")
    assert meta_data["access"].has_key?("session")
    assert meta_data["access"].has_key?("form")
    assert meta_data["access"].has_key?("login")
  end
end
