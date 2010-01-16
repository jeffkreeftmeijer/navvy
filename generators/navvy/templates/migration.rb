class CreateDelayedJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs, :force => true do |t|
      table.string  :object
      table.string  :method
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
 
  def self.down
    drop_table :jobs
  end
end
