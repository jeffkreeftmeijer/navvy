require 'sequel'

Sequel.sqlite('/tmp/navvy_test.sqlite')

Sequel::DATABASES[0].create_table!(:jobs) do
  primary_key :id, :type => Integer
  String    :object
  String    :method_name
  String    :arguments, :text => true
  Integer   :priority, :default => 0
  String    :return
  String    :exception
  Integer   :parent_id
  DateTime  :created_at
  DateTime  :run_at
  DateTime  :started_at
  DateTime  :completed_at
  DateTime  :failed_at
end

require 'navvy/job/sequelhooks'
