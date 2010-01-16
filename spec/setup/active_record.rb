require File.expand_path(File.dirname(__FILE__) + '/../../lib/navvy/job/active_record')
require 'rubygems'
require 'yaml'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => '/tmp/navvy_test.sqlite')

ActiveRecord::Schema.define do
  create_table :jobs, :force => true do |table|
    table.string  :object
    table.string  :method_name
    table.text    :arguments
    table.string  :return
    table.string  :exception
    table.time    :created_at
    table.time    :run_at
    table.time    :started_at
    table.time    :completed_at
    table.time    :failed_at
  end
end
