require 'navvy/job/data_mapper'
DataMapper.setup(:default, "sqlite3:///tmp/navvy_test.sqlite")
DataMapper.finalize
Navvy::Job.auto_migrate!
