require 'rubygems'
require 'sequel'
require 'yaml'

Sequel.sqlite('/tmp/navvy_test_s.sqlite')

Sequel::DATABASES[0].create_table!(:jobs) do
    primary_key :id, :type=>Integer
    String  :object
    String  :method_name
    String  :arguments, :text => true
    String  :return
    String  :exception
    Time    :created_at
    Time    :run_at
    Time    :started_at
    Time    :completed_at
    Time    :failed_at
end

require File.expand_path(File.dirname(__FILE__) + '/../../lib/navvy/job/sequel')
