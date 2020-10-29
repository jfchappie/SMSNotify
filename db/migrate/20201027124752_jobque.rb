class Jobque < ActiveRecord::Migration[5.2]
  def change
     create_table :jobqueues do |t|
      t.string :name
      t.string :url
      t.integer :percent
      t.integer :speed_factor
      t.integer :reliability
      t.integer :status
      t.timestamps
    end
  end
end
