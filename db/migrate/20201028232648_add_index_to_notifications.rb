class AddIndexToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_index :notifications, [:vendor_response_id], :unique => true
    add_index :notifications, [:job_id, :queue_id, :status]
  end
end
