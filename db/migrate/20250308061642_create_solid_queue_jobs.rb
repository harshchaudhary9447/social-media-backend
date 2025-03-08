class CreateSolidQueueJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :solid_queue_jobs do |t|
      t.string :job_class
      t.string :arguments
      t.string :queue_name
      t.datetime :scheduled_at
      t.datetime :completed_at
      t.timestamps
    end
  end
end
