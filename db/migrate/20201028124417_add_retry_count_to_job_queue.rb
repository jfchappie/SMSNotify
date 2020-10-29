class AddRetryCountToJobQueue < ActiveRecord::Migration[5.2]
  def change
    add_column :jobqueues, :retry_count, :integer
  end
end
