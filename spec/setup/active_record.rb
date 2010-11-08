require 'navvy/job/active_record'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => '/tmp/navvy_test.sqlite')

ActiveRecord::Schema.define do
  create_table :jobs, :force => true do |table|
    table.string    :object
    table.string    :method_name
    table.text      :arguments
    table.integer   :priority, :default => 0
    table.string    :return
    table.string    :exception
    table.integer   :parent_id
    table.datetime  :created_at
    table.datetime  :run_at
    table.datetime  :started_at
    table.datetime  :completed_at
    table.datetime  :failed_at
  end
end
