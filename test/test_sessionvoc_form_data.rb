# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
require 'helper'

class TestSessionvocFormData < Test::Unit::TestCase
  should "create form data" do
    sid = client.new_session
    assert_not_nil sid
    fid = client.create_form_data(sid)
    assert_not_nil fid
    assert fid.is_a?(String)
    assert fid.length > 0
  end

  should "fail to create form data due to a non-existent sid" do
    sid = client.new_session
    assert non_sid != sid
    assert_raise Sessionvoc::Open::InternalServerErrorException do
      fid = client.create_form_data(non_sid)
    end
  end

  should "delete form data" do
    sid, fid = create_form
    assert client.delete_form_data(sid, fid)
  end
  
  should "fail to delete form data due to a non-existent fid" do
    sid, fid = create_form
    assert_raise Sessionvoc::Open::InvalidFidException do
      client.delete_form_data(sid, non_fid)
    end
  end

  should "get form data" do
    sid, fid = create_form
    
    form_data = client.get_form_data(sid, fid)
    assert_nil form_data
    
    form_data = {'foo' => 'bar', 'number' => 1, 'success' => false, 'subobject' => {'foo' => 'bar'}}
    client.update_form_data(sid, fid, form_data)
    
    form_data = client.get_form_data(sid, fid)
    assert_not_nil form_data
    assert_equal form_data['foo'], 'bar'
    assert_equal form_data['number'], 1
    assert !form_data['success']
    assert_not_nil form_data['subobject']
    assert form_data['subobject'].is_a?(Hash)
    assert_equal form_data['subobject']['foo'], 'bar'
  end

  should "fail to get form data due to a non-existent fid" do
    sid, fid = create_form
    assert_raise Sessionvoc::Open::InvalidFidException do
      client.get_form_data(sid, non_fid)
    end
  end

  should "update form data" do
    sid, fid = create_form

    form_data = {'foo' => 'bar'}
    client.update_form_data(sid, fid, form_data)
    
    form_data = client.get_form_data(sid, fid)
    assert_not_nil form_data
    assert_equal form_data['foo'], 'bar'
    
    form_data = {'foo' => 'bar2'}
    client.update_form_data(sid, fid, form_data)
    
    form_data = client.get_form_data(sid, fid)
    assert_not_nil form_data
    assert_equal form_data['foo'], 'bar2'
    
    form_data = {}
    client.update_form_data(sid, fid, form_data)

    form_data = client.get_form_data(sid, fid)
    assert_equal form_data, {}
    
    form_data = nil
    client.update_form_data(sid, fid, form_data)

    form_data = client.get_form_data(sid, fid)
    assert_nil form_data
  end

  should "create a form data by passing a self generated fid" do
    sid = client.new_session
    form_data = {'foo' => 'bar'}
    fid = non_fid
    client.update_form_data(sid, fid, form_data)
    
    form_data = client.get_form_data(sid, fid)
    assert_not_nil form_data
    assert_equal form_data['foo'], 'bar'
  end
  
  should "fail to update form data due to a non-existent sid" do
    form_data = {'foo' => 'bar'}
    fid = non_fid
    assert_raise Sessionvoc::Open::InvalidSidException do
      client.update_form_data(non_sid, fid, form_data)
    end
  end

  private
  def create_form
    sid = client.new_session
    assert_not_nil sid
    fid = client.create_form_data(sid)
    assert_not_nil fid
    [sid, fid]
  end
end
