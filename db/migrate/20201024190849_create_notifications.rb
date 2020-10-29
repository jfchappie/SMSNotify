class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.integer :job_id
      t.integer :recipient_id
      t.integer :queue_id
      t.integer :vendor_response_id
      t.string :status
      t.timestamps
    end
  end
end
