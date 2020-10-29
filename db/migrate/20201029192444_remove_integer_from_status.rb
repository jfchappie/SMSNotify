class RemoveIntegerFromStatus < ActiveRecord::Migration[5.2]
  def change
    remove_column :statuses, :integer
  end
end
