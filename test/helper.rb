# Copyright:: 2011 triAGENS GmbH
# Author:: Oliver Kiessler (mailto:kiessler@inceedo.com)
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'
require 'digest'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'sessionvoc-store'

class Test::Unit::TestCase
  def non_sid
    "473878374888888888888zfgiusdhfkhsdfz843z987843975893745897389#{rand(10)}#{Time.now.to_i}"
  end

  def non_fid
    "3748748#{rand(10)}#{Time.now.to_i}"
  end

  def client
    port = ENV['SESSIONVOC_PORT']
    host = ENV['SESSIONVOC_HOST']
    if host and port
      @client ||= Sessionvoc::Client.new('host' => host, 'port' => port, 'log_level' => Logger::DEBUG)
    else
      @client ||= Sessionvoc::Client.new('log_level' => Logger::DEBUG)
    end
  end
end
