require 'mongoid'
require 'bson'
require 'mongo'

Mongoid.configure do |config|
  name = "navvy_test"
  config.allow_dynamic_fields = false
  config.connect_to(name)
end

require 'navvy/job/mongoid'
