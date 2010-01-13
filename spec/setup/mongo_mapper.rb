Navvy::Job = Class.new # ugly hack to forget about any active_record presets

require File.expand_path(File.dirname(__FILE__) + '/../../lib/navvy/job/mongo_mapper')
MongoMapper.database = 'navvy_test'
