class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs, :force => true do |t|
      t.string  :object
      t.string  :method_name
      t.text    :arguments
      t.string  :return
      t.string  :exception
      t.time    :created_at
      t.time    :run_at
      t.time    :started_at
      t.time    :completed_at
      t.time    :failed_at
    end
  end
 
  def self.down
    drop_table :jobs
  end
end
