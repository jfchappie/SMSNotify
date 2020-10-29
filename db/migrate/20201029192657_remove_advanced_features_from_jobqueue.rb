class RemoveAdvancedFeaturesFromJobqueue < ActiveRecord::Migration[5.2]
  def change
    remove_column :jobqueues, :speed_factor
    remove_column :jobqueues, :reliability
  end
end
