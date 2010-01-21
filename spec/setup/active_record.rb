require File.expand_path(File.dirname(__FILE__) + '/../../lib/navvy/job/active_record')
require 'rubygems'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => '/tmp/navvy_test.sqlite')

ActiveRecord::Schema.define do
  create_table :jobs, :force => true do |table|
    table.string    :object
    table.string    :method_name
    table.text      :arguments
    table.string    :return
    table.string    :exception
    table.datetime  :created_at
    table.datetime  :run_at
    table.datetime  :started_at
    table.datetime  :completed_at
    table.datetime  :failed_at
  end
end
