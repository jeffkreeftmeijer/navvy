require 'rubygems'
require 'sequel'

Sequel.sqlite('/tmp/navvy_test.sqlite')

Sequel::DATABASES[0].create_table!(:jobs) do
  primary_key :id, :type => Integer
  String    :object
  String    :method_name
  String    :arguments, :text => true
  String    :return
  String    :exception
  DateTime  :created_at
  DateTime  :run_at
  DateTime  :started_at
  DateTime  :completed_at
  DateTime  :failed_at
end

require File.expand_path(File.dirname(__FILE__) + '/../../lib/navvy/job/sequel')
