class RemoveRecipients < ActiveRecord::Migration[5.2]
  def change
    drop_table :recipients
  end
end
