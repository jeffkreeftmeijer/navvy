class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs, :force => true do |t|
      t.string    :object
      t.string    :method_name
      t.text      :arguments
      t.integer   :priority, :default => 0
      t.string    :return
      t.string    :exception
      t.integer   :parent_id
      t.datetime  :created_at
      t.datetime  :run_at
      t.datetime  :started_at
      t.datetime  :completed_at
      t.datetime  :failed_at
    end
  end

  def self.down
    drop_table :jobs
  end
end
