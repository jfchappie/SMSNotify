
class AddRetryThresholdToJobQueue < ActiveRecord::Migration[5.2]
  def change
        add_column :jobqueues, :retry_threshold, :integer
  end
end
