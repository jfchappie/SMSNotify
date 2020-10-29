class ChangeNotification < ActiveRecord::Migration[5.2]
  def change
    rename_column :notifications, :recipient_id, :recipient
    change_column :notifications, :recipient, :string
  end
end
