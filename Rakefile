require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "sessionvoc-store"
  gem.homepage = "http://www.worldofvoc.com/products/sessionvoc/summary/"
  gem.license = "Apache License Version 2.0, January 2004"
  gem.summary = %Q{The SessionVOC is a noSQL database optimized for the management of user sessions.}
  gem.description = %Q{Rails 3 Plugin to integrate with SessionVOC. In order to manage user sessions efficiently the SessionVOC provides the functions login, logout, read and write of a session. Furthermore it has the ability to synchronize with one or more persistent relational databases.}
  gem.email = "kiessler@inceedo.com"
  gem.authors = ["triAGENS GmbH", "Oliver Kiessler"]
  gem.add_dependency "httparty", ">= 0.7.4"
  gem.add_dependency "json", ">= 1.4.6"
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.rcov_opts = %w{--exclude osx\/objc,gems\/,spec\/}
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Rails SessionVOC Session Store #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
