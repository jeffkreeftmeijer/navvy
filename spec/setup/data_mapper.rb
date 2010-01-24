require File.expand_path(File.dirname(__FILE__) + '/../../lib/navvy/job/data_mapper')
DataMapper.setup(:default, "sqlite3:///tmp/navvy_test.sqlite")
Navvy::Job.auto_migrate!
