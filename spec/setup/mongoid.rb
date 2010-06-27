require 'mongoid'

Mongoid.configure do |config|
  name = "navvy_test"
  config.allow_dynamic_fields = false
  config.master = Mongo::Connection.new.db(name)
end

require File.expand_path(File.dirname(__FILE__) + '/../../lib/navvy/job/mongoid')
